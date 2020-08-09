function [AvgVelocity,VelData,Vel,AngVdata,Avel,dataCLEAN,AvgRfreq,...
    TumbleSpeed,TumbleAngle] = CellAnalysis(dt,OUTdata,MinVel,factorP2M,...
    AngleType,windowWidth,SmoothMETHOD,VelDepthFactor,VelCutOff,...
    AngCutOff,Gama,RotDiff)
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This Function Returns Velocity and Reversal frequency for each cell
%
% INPUTS:
%       
%       NgoodCell is the number of good trajectories
%
%       dataCLEAN is the clean data
%
%       NumIDS is the number of frames fore each cell live
%
%       factorP2M is the factor from pixel to micron
%
%       dt is the time step between frames
%
%       RotDiff is the rotational diffusivity
%
%       Gama is the parameter in tumbling formula
%
%       AngCutOff is the angular velocity cuttoff
%
%       VelDepthFactor is the parameter in velocity formula
%
%       VelCutOff is the velocity cuttoff
%
%       MinVel is the minimum velocity value for analysis
%
% OUTPUTS:
%
%       NtrackedCell
%
%       NumIDs
%
%       Vel
%
%       Acc
%
%       Avel
%
%       Aace
%
%       VelData
%       
%       AngvData
%
%       dataCLEAN
%
%       dataTumble
%
% USE: 
%       
%       [ NtrackedCell, NumIDs, Vel, Acc, Avel, Aace, VelData, ...
%       AngvData, TmpVel, dataCLEAN, dataTumble, indxAng, indxVEL ] = ...
%       CellAnalysis(dt,MinVel,NgoodCell,NumIDs,dataCLEAN,VelDepthFactor,...
%       VelCutOff,AngCutOff,Gama,RotDiff)
% 
% Mustafa Elmas
% University of Tennessee - Knoxville
% melmas at utk dot edu
% September 15 2017 
% Written and tested in Matlab R2017a
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Ncol = size(OUTdata,2);    % ID column
 TIMEcol = Ncol -1;              % TIME column number 
ANGLEcol = Ncol -2;              % ANGLE column number

%% Calculate Velocity for each tracked bacteria
[VelData2, Vel2] = CellVelocity(dt,OUTdata);

%% Delete information about dead and slow cells
[VelData,Vel,dataCLEAN] = DeleteSlowCells(Vel2,VelData2,MinVel,OUTdata);

%% Calculate average velocity
AvgVelocity = sum(Vel)/length(Vel)*factorP2M;

%% Angle of Bacteria
[ dataANGLE ] = CellAngle( dataCLEAN );
if(AngleType == 'rad')
      dataCLEAN(:,ANGLEcol) = dataANGLE(:,1);
elseif(AngleType == 'deg')
      dataCLEAN(:,ANGLEcol) = dataANGLE(:,2);
end

%% Calculate Angular Velocity for each tracked bacteria
[ AngVdata, Avel ] = CellAngVelocity( AngleType,dt,dataCLEAN );


%% Calculate TUMBLING Frequency for each tracked bacteria
[ dataTumble, TumbleSpeed, TumbleAngle ] = CellReversal(AngleType,...
    factorP2M,VelData,AngVdata,dataCLEAN,dt,VelDepthFactor,VelCutOff,...
    AngCutOff,Gama,RotDiff);

% Number of cells
NtrackedCell = max(dataCLEAN(:,Ncol));

% Allocate memory for Reversal frequency of Cells
Rfreq = zeros(NtrackedCell,1);

% Reversal frequency of cells
for z = 1:NtrackedCell
    
    % Index of frames in m th trajectory 
    ind = find(dataCLEAN(:,Ncol) == z);
    
    % The length of the m th trajectory
    TotalFrames = length(ind);
    
    % Save reversal frequency for each cell
    Rfreq(z) = dataTumble(z,4)/(TotalFrames*dt);    
 
end

% Average Reversal frequency of cells
AvgRfreq = sum(Rfreq(:))/NtrackedCell;


end % END FUNCTION

