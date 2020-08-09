function [ AngVdata, Avel ] = CellAngVelocity( AngleType, dt, dataCLEAN )
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This Function Returns Angle for each cell
%
% INPUTS:
%
%       dataCLEAN is the data without angle of each cells
%
%       dt is frame per second
%
% OUTPUTS:
%
%       Avel is average angular velocity for each cell
%
%       AngVdata is Angular velocity data
%
% USE: 
%       
%       [ OUTdata ] = CellAngle( dt, dataCLEAN );
% 
% Mustafa Elmas
% University of Tennessee - Knoxville
% melmas at utk dot edu
% September 15 2017 
% Written and tested in Matlab R2017a
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Angular velocity
    Ncol = size(dataCLEAN,2);    % ID column
 TIMEcol = Ncol -1;              % TIME column number 
ANGLEcol = Ncol -2;              % ANGLE column number

NtrackedCell = max(dataCLEAN(:,Ncol)); % Number of cells

% Allocate memory for angular velocity of each cell trajectory
Avel = zeros(NtrackedCell,1);

% Number of rows in Velocity data file
nrv = length(dataCLEAN); 

% Store Velocity and angular velocities of each trajectory
AngVdata = zeros(nrv, 3);

for j=1:NtrackedCell
    
    % Number of previous rows in Data file
    ind = find(dataCLEAN(:,Ncol) == j);
    
    % The length of the m th trajectory
    TotalFrames = length(ind);
    
    Av = zeros(TotalFrames,1);  % Angular Velocity
    
    Theta = dataCLEAN(ind,ANGLEcol);        % Angle
        T = dataCLEAN(ind,TIMEcol);         % Time
        
    % Difference between consecutive Theta's    
    dTheta = diff(Theta);
    
    % Correction Angle Change
    if(AngleType == 'deg')
        dTheta = dTheta + (dTheta > 180)*(- 360); % Correction    
    else
        dTheta = dTheta + (dTheta > pi)*(- 2*pi); % Correction
    end
    
    % Angular velocity
    Av(2:TotalFrames-1) = dTheta(2:end)/dt;
    
    % Average Angular velocity for m th trajectory
    Avel(j) = sum(Av(:))/TotalFrames;   % divide by TotalFrames-2
    
    % Store Angular Velocity of each trajectories for calculating TUMBLING
    AngVdata(ind,1) = Av; 
    AngVdata(ind,2) = j;
    AngVdata(ind,3) = T;
    
end % END FOR

end % END FUNCTION

