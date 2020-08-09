function [VelData,Vel,OUTdata] = DeleteSlowCells(Vel,VelData,...
    MinVel,OUTdata)
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function deletes information about dead and slow cells
%
% INPUTS:
%       
%       OUTdata is data to be processed
%
%       MinVel is the minimum velocity value for analysis
%
%       VelData is velocity data
%
%       Vel is average velocity for tracks
%
% OUTPUTS:
%
%       Vel is the array of velocity of each track
%
%       VelData is the velocity data for all tracks over time
%
%       dataCLEAN is clean data after deleting dead cell 
%
% USE: 
%       
%  [VelData,Vel,dataCLEAN] = DeleteSlowCells(Vel,VelData,MinVel,dataCLEAN);
% 
% Mustafa Elmas
% University of Tennessee - Knoxville
% melmas at utk dot edu
% September 15 2017 
% Written and tested in Matlab R2017a
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Clean Data
Ncol = size(OUTdata,2);    % ID column

% Identify which cell swim faster than 15 µ/s
TmpVel = Vel > MinVel;

% Extract Cells which swim faster than 15 µ/s
Vel = Vel(TmpVel);

% Zero ID indicates bad (dead or flooding) cells 
IDdel = find(TmpVel == 0);

% Number of bad cells
NidDEL = length(IDdel);

% Extract velocity of each trajectories of GOOD cells
for t=1:NidDEL
    % mark ID of bad cells as ZERO
    ind = find(VelData(:,2) == IDdel(t));
    VelData(ind,2) = 0;
    OUTdata(ind,Ncol) = 0;    
end

%% ------- dataCLEAN CLEANING --------
% Get rid of the cell swim less than 15 µ/s
OUTdata(~any(OUTdata(:,Ncol),2),:)=[];
[out4,idx4] = sort( unique(OUTdata(:,Ncol)));

% ID numbers start from 1
OUTdata(:,Ncol) = changem(OUTdata(:,Ncol),idx4,out4);

%% ------- Velocity --------
% % Get rid of the cell swim less than 15 µ/s
VelData(~any(VelData(:,2),2),:)=[];
[out2,idx2] = sort( unique(VelData(:,2)));
 
% ID numbers start from 1
VelData(:,2) = changem(VelData(:,2),idx2,out2);

end % END FUNCTION

