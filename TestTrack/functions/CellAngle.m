function [ dataANGLE ] = CellAngle( dataCLEAN )
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This Function Returns Angle for each cell
%
% INPUTS:
%
%       dataCLEAN is the data without angle of each cells
%
% OUTPUTS:
%
%       dataANGLE is the data with angle of each cells
%
% USE: 
%       
%       [ OUTdata ] = CellAngle( dataCLEAN );
% 
% Mustafa Elmas
% University of Tennessee - Knoxville
% melmas at utk dot edu
% September 15 2017 
% Written and tested in Matlab R2017a
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Angle of Bacteria
dataANGLE = zeros(length(dataCLEAN),3);

% ID column number
Ncol = size(dataCLEAN,2);    

% Number of cells
NtrackedCell = max(dataCLEAN(:,Ncol));

for j=1:NtrackedCell
    
    % Number of previous rows in Data file
    ind = find(dataCLEAN(:,Ncol) == j);
    
    % x and y positions
    x = dataCLEAN(ind,1);
    y = dataCLEAN(ind,2);
    
    % Difference between consecutive x's and y's
    dx = diff(x);
    dy = diff(y); 
    
    % Angle Cell
    angleCell = atan2(dy,dx);
    
    % >>>>>>>>>> CALCULATE ANGLES <<<<<<<<<<<<<<<<<<
    % in degrees
    angleDegre = angleCell*(180/pi);

    % Convert negative angle to positive angle by adding 360 degree
    angleDegre = angleDegre + (angleDegre<0)*360;

    % Record it
    dataANGLE(ind(2:end), 2) = angleDegre;
    
    % in radians
    angleRadian = angleCell;

    % Convert negative angle to positive angle by adding 2*pi
    angleRadian = angleRadian + (angleRadian<0)*2*pi; % Correction
    
    % Record it
    dataANGLE(ind(2:end), 1) = angleRadian;        

    % ID
    dataANGLE(ind, 3) = j;
end 

end

