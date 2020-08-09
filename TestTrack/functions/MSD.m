function [MSDdata] = MSD(dataTracks,dt)
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function calculates Mean Square Displacement of Trajectories 
%
% INPUTS:
%
%       dataTracks is the tracks data
%       Trajectory data of the 4-column format:
%       x-pos  y-pos  Max-axis  Min-axis  Angle Time  particle ID
%
% OUTPUTS:
%       MSDdata: will have three columns:
%       Column 1: lag time (in frames)
%       Column 2: MSD (in pixels)
%       Column 3: number of observations in average
%
% USE: 
%       
%       [MSDdata] = MSD(dataTracks,dt);
% 
% Mustafa Elmas
% University of Tennessee - Knoxville
% melmas at utk dot edu
% September 15 2017 
% Written and tested in Matlab R2017a
%
% Modified version of  ERIC M. FURST MSD.m, based on the IDL code 
% by John Crocker and Eric Weeks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Number of columns in dataTracks
Ncol = size(dataTracks,2);

% Time column
Tcol = Ncol - 1;

% Convert time to frame number
dataTracks(:,Tcol) = dataTracks(:,Tcol)*(1/dt);

% List for all MSD in tracks
MSDList = [];

% Number of Trajectories
NumTraj = max(dataTracks(:,Ncol));

% Step through all particles in the tracked data set
for particleid=1:NumTraj
 
    % Find index of ii th trajectory in the dataTracks
    ind=find(dataTracks(:,Ncol)==particleid,1);
    
    % Number of frames in ii th trajectory
    iiFrame = sum(dataTracks(:,Ncol)==particleid);
    
    % The maximum frame separation
    MAXstep = iiFrame - 1;
    
    % Only analyze if there is more than one frame to calculate MSD
    if MAXstep >= 1
%         disp(['Particle ', num2str(particleid),' of ',...
%         num2str(max(dataTracks(:,Ncol))),'. Total frames: ',...
%         num2str(iiFrame)]);
    
        % Step through all frame separations starting from 1 up to MAXstep
        for step=1:MAXstep
            
            % Time lag
            for j=1:(floor(MAXstep/step))
                
                % Caculate lag time 
                deltaT = dataTracks(ind+j*step,Tcol)...
                    - dataTracks(ind+(j-1)*step,Tcol);
                
                % Caculate mean-squared displacement between steps
                MSDr2 = (dataTracks(ind+j*step,1)...
                    - dataTracks(ind+(j-1)*step,1))^2 ...
                    + (dataTracks(ind+j*step,2)...
                    -  dataTracks(ind+(j-1)*step,2))^2;
                
                    % Update MSD list
                    MSDList = [MSDList, [deltaT, MSDr2]'];
            end
        end
    end
end

MSDList = MSDList';

% MSD data
MSDdata = [];

% Min and Max lag time
MINlag = min(MSDList(:,1));
MAXlag = max(MSDList(:,1));

% Step through min lag to max lag
for lag=MINlag:MAXlag
    NumObs = sum(MSDList(:,1)==lag);
    
    % Calculate MSD if Number observation is greater than one
    if(NumObs>=1)
        ind = find(MSDList(:,1)==lag);
        MSDdata = [MSDdata, [lag mean(MSDList(ind,2)) NumObs]'];
    end
end

% Output
MSDdata = MSDdata';

% Run with 
% [MSDdata] = MSD(result)

% Plot with 
% loglog(MSDdata(:,1),MSDdata(:,2:3))
% plot(MSDdata(:,1),MSDdata(:,2:3))


end

