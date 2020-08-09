function [VelData, Vel] = CellVelocity(dt,dataCLEAN)
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function calculates velocity of each cell
% It also returns average velocity of all cells
%
% INPUTS:
%       
%       dataCLEAN is the clean data
%
%       dt is the time step between frames
%
% OUTPUTS:
%
%       Vel is the array of velocity of each track
%
%       VelData is the velocity data for all tracks over time
%       
% USE: 
%       
%       [VelData, Vel] = CellVelocity2(dt,dataCLEAN);
% 
% Mustafa Elmas
% University of Tennessee - Knoxville
% melmas at utk dot edu
% September 15 2017 
% Written and tested in Matlab R2017a
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% Allocate memory for Average velocity, Accelration, angular velocy 
% angular accelration of each cell trajectory
   IDcol = size(dataCLEAN,2);   % ID column number
 TIMEcol = IDcol -1;            % TIME column number 

NgoodCell = max(dataCLEAN(:,IDcol));
Vel = zeros(NgoodCell,1);
 
% Number of rows in Velocity data file
nrv = length(dataCLEAN); 

% Store Velocity and angular velocities of each trajectory
 VelData = zeros(nrv, 3);

%% Calculate VELOCITY, ACCELERATION
for m=1:NgoodCell
%for m=1:1
    
    % Index of frames in m th trajectory 
    ind = find(dataCLEAN(:,IDcol) == m);
    
    % The length of the m th trajectory
    TotalFrames = length(ind);
    
    Vi = zeros(TotalFrames,1);  % Velocity
    
    x = dataCLEAN(ind,1)';               % x axis
    y = dataCLEAN(ind,2)';               % y axis
    T = dataCLEAN(ind,TIMEcol);          % Time

    dx = diff(x);           % Difference between consecutive x's
    dy = diff(y);           % Difference between consecutive y's

    % Velocity
    Vi(1:TotalFrames-1) = sqrt(dx.^2 + dy.^2)/dt;
        
    % Average VELOCITY for m th trajectory
    Vel(m) = sum(Vi(:))/TotalFrames;   % it must be TotalFrames-1
    
    % Store Velocity of each trajectories for calculating TUMBLING
    VelData(ind,1) = Vi; 
    VelData(ind,2) = m;
    VelData(ind,3) = T;
    
end % END FOR

end % END FUNCTION 

