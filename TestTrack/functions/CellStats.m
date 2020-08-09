function [ RunTimeBR, AvgVelWR, ReverseAngle, RatioSpeedReverse ] = CellStats(factorP2M, ...
    Vel,VelData,TumbleSpeed,TumbleAngle )

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This Function calculates mean run time, distribution of swimming speed, 
% Distribution of run times, ratio of speed before and after reversal
% event, Turning angle Distribution
%
% INPUTS:
%
%       dataCLEAN is the clean data
%
%       factorP2M is the factor from pixel to micron
%
%       TumbleSpeed
%
%       TumbleAngle
%
%       VelData
%
%       Vel
%
% OUTPUTS:
%
%
% USE: 
%       
%       
% 
% Mustafa Elmas
% University of Tennessee - Knoxville
% melmas at utk dot edu
% September 15 2017 
% Written and tested in Matlab R2017a
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Number of Tracks
NtrackedCell = length(TumbleAngle);

ReverseAngle = [];      % Reverse Angle
RatioSpeedReverse = []; % Ration of speed before and after reversal 
RunTimeBR = [];         % Run Time

% Data for each track
for ii = 1:NtrackedCell
% for ii = 1:3
    % Number of Tumbles
    Ntumbles = length(TumbleAngle(ii).LocalTumble);

    % Angle Change
    AngleChange = [];
    RatioSpeedBA = [];
    if (Ntumbles > 0)
        % Reverse Angle
        AngleChange(1:Ntumbles) = [TumbleAngle(ii).LocalTumble(1:Ntumbles).angle];
        
        % Reverse  Index
        indT = [TumbleAngle(ii).LocalTumble(1:Ntumbles).index]; 
    
        % Ratio of Speed before and after reversing
        indT1 = indT+1;
        indT2 = indT-1;
        RatioSpeedBA = (VelData(indT1) - VelData(indT2))./(VelData(indT1) + VelData(indT2));
        
        % Run Time between reversal event
        RunTime = diff(indT);
        
    % Track with no reverse    
    else
        % Set average speed of track with no reverse to zero
        Vel(ii) = 0;
    end
    
    % Append Angle change
    ReverseAngle = [ReverseAngle; AngleChange']; 
    
    % Append Speed ratio before and after
    RatioSpeedReverse = [RatioSpeedReverse; RatioSpeedBA'];
    
    RunTimeBR = [RunTimeBR; RunTime'];
    
%     % Number of Stops
%     Nstops = length(TumbleSpeed(ii).LocalTumble);
% 
%     % Stops
%     if (Nstops > 0)
%         % Stop Index
%         indS = [TumbleSpeed(TrackNum).LocalTumble(1:end).index]; 
%     end
%     
%     TumbleSpeed(s).LocalTumble(StructINDvel).speed = LocMinVEL;
end

% Average velocities of tracks with reversal event 
Vel(Vel(:)==0) = [];
AvgVelWR = Vel*factorP2M;

end

