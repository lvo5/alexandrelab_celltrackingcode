%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%
% FOR MOR INFORMATION -->
% http://www.math.utk.edu/~elmas/research.html 
%
%
% AUTHOR: Mustafa Elmas
% 
% DATE: 08/01/2017
%
% AFFILIATION: University of Tennessee - Knoxville
% 
%
% PURPOSE:
%
% To analyze bacterial motility videos and find 
% I)   Cell speed (micron/s)
% II)  Cell reversal frequency (/s)
% III) Mean square displacement (MSD) 
% 
% 1. Split a recorded video into certain number of frames
%
% 2. Convert the frames into binary frames
%
% 3. Calculate Centroid, Major and Minor axis length and angle
% by MATLAB built-in function, regiongroup.
%
% 4. Constructs n-dimensional trajectories from a scrambled 
% list of particle coordinates determined at discrete times 
% in consecutive video frames by MATLAB version of cell-tracking 
% algorithm by Crocker and Grier.
% 
% 5. Trajectories slower than 10 microns/second and shorter than 1 s were 
% excluded from the analysis. This ensures that we restrict our 
% analysis mostly to trajectories that lie in a narrow zone around 
% the focal plane.
% 
% 6. Calculate velocity, reversal frequency, acceleration, angular
% acceleration, velocity autocorrelation, Mean Square Displacement
% 
% 
% CATEGORY: Image Processing
% 
%
% CALLING SEQUENCE:
%
%       1. InitValues
%       2. Video2Frames
%           2.1. ReadVideo
%       3. BackgroundExtraction  
%           3.1. ReadVideo
%       4. BackgroundSubtraction
%           4.1. adpmedian
%       5. ObjectDetection
%           5.1. bpass
%           5.2. pkfnd
%           5.3. cntrd
%       6. Track
%       7. RemoveBadCell
%       8. CellAnalysis
%           8.1 LocalMinMax
%
% CAUTIOUS: 
% 
% Please adjust the parameters below to suit your video.
%
% OUTPUTS:
%
% # of Good Cells |  # of Good Trajectories | # of Bad Trajectories
% Mean Speed (micron/s)   		
% Mean Reversal Frequency   (/s)    	
% Mean Square Displacement MSD
% 
% MODIFICATION HISTORY:
%
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Add folder with subscripts
addpath('functions');

% %% 
% clc;    % Clear the command window.
% close all;  % Close all figures (except those of imtool.)
% imtool close all;  % Close all imtool figures.
% clear;  % Erase all existing variables.
% workspace;  % Make sure the workspace panel is showing.
% fontSize = 20; % Set Font Size
% format long;    % Set format long
% 
% %% Ask a user to check initial values
% cntrl = 1;
% while(cntrl==1)
% % Ask a user to check initial values in InitValues.m
% ck=input('Did you check initial values in InitValues.m?, Y/N [Y]:','s');
%     if ck=='Y'
%         disp('Awesome, you can continue now :)');
%         break
%     elseif ck=='N'
%         disp('You have to check initial values in InitValues.m !!');
%        	cntrl = cntrl +1;
%     end
% end
 
%% >>>>>>>>>>>>>>>> INITIAL VALUES <<<<<<<<<<<<<<<<<<
% Run each sub-cells one by one so it's easier to see what is
%happening.
disp('<-- INITIALIZE VARIABLES -->');
[VideoName, Vtype, Ftype, StartFrame, FrameSkip, OriginalSubfolder,...
BinarySubfolder, TestTrackFrames, PixTresh, Method, factorP2M, dt, MAXdisp, param, ...
RotDiff, Gama, AngCutOff, VelDepthFactor, VelCutOff, MinVel, VelThresh,...
CellinFrames,ObjRadius,Inoise,maskradius,AdpFiltLength,AngleType,windowWidth,...
SmoothMETHOD] = InitValues();

%Manually change for your camera: scale and FPS
dt = 1/30; %dt = 1/FPS
factorP2M = 0.1660; % scale from pixel to microns = microns/pixel

%% We initialize the variable manually here!
VideoName = 'TM000437'; %Put the video name here
Vtype = 'MP4';%type of video
windowWidth = 10; %change the window of track seperation to have shorter or longer tracks
%% Add track Videos folder
Tvideos = strcat('TrackVideos',VideoName);
if ~exist(Tvideos, 'dir')
    mkdir(Tvideos)
    addpath(Tvideos); 
end

%% Add Frame Folder the Path
FolderPath = what(strcat(OriginalSubfolder,VideoName));
FramePath = '/Users/lvo5/Desktop/TestTrack/TM000437';
%Manually add the framepath that has the video 

 %% >>>>>>>>>>>>>>>> EXTRACT FRAMES FROM THE VIDEO <<<<<<<<<<<
 disp('<-- EXTRACT FRAMES -->');
 OriginalSubfolder = '/Users/lvo5/Desktop/TestTrack';
 Video2Frames( 'TM000437', Vtype, Ftype, StartFrame, FramePath);

 %% >>>>>>>>>>>>>>>> DETECT CELLS <<<<<<<<<<<<<<<<<<<
 disp('<-- DETECT CELLS -->');
 [DataPosition] = DetectCells(dt,ObjRadius,Inoise,maskradius, ...
 PixTresh,AdpFiltLength,StartFrame,FrameSkip,Ftype,VideoName,Vtype,...
  Method,FramePath); 
%This takes a while - you know when it is done when you see
%DataPosition dataframe in the workspace
 %% >>>>>>>>>>>>>>>> CELL TRACKING <<<<<<<<<<<<<<<<<<<<<
disp('<-- TRACKING CELLS IN EACH FRAMES -->');
OUTdata = trackmem(DataPosition, MAXdisp, param);
OUTdata = Track(DataPosition, MAXdisp, param);
%This takes a while - you know when it is done when you see
%OUTdata dataframe in the workspace
 %% SMOOTH TRACKS via METHOD SmoothMETHOD
 disp('<-- SMOOTH TRACKS -->');
 [ smoothDATA ] = SmoothTracks( OUTdata, windowWidth, SmoothMETHOD );

%% >>>>>>>>> CELL ANALYSIS BEFORE DELETING BAD TRACKS <<<<<<<<<<<<<<<<<
 disp('<-- CALCULATING VELOCITY & TUMBLING FREQUENCY OF CELLS -->');
 [AvgVelocity,VelData,Vel,AngVdata,Avel,dataCLEAN,AvgRfreq,TumbleSpeed,TumbleAngle] = ...
     CellAnalysis(dt,smoothDATA,MinVel,factorP2M,AngleType,windowWidth,...
     SmoothMETHOD,VelDepthFactor,VelCutOff,AngCutOff,Gama,RotDiff);

 %% >>>>>>>>>> PLOT TRACKS BEFORE DELETION <<<<<<<<<<<<<<<<<<<<
 PLOTtracks( 'BeforeDeletion', VideoName, smoothDATA );
 
% You now need to select the tracks that are representing cells
%That are actually moving. I suggest that you export the smoothed
%dataset out and start analyzing. This is how we did it for the 
%paper. You can select the tracks by looking at the average velocity
%profiles of the tracks (histogram) and select the tracks above a certain threshold.
%The threshold is solely dependent of the velcities of the 
%population of cells, you might have to play around.
%You can easily do this is in Python, it will be easier.

%Another thing you can do is look at the track pictures and select
%the number. This is more labor intensive, but you can qualitatively
%judge the swimming patterns.
 %% >>>>>>>>>> DELETE UNWANTED TRACKS <<<<<<<<<<<<<
disp('<-- DELETE TRACKS -->');
[ dataCLEAN ] = TrackUPDATE( dataCLEAN);

%  %% >>>>>>>>>>>> MERGE TRACKS <<<<<<<<<<<<<<<<
% disp('<-- MERGE TRACKS -->');
% [ dataCLEAN ] = MergeTrack( dataCLEAN, dt );

%% >>>>>>>>> CELL ANALYSIS AFTER DELETING BAD TRACKS <<<<<<<<<<<<<<<<<
disp('<-- CALCULATING VELOCITY & TUMBLING FREQUENCY OF CELLS -->');
[AvgVelocity,VelData,Vel,AngVdata,Avel,dataCLEAN,AvgRfreq,TumbleSpeed,TumbleAngle] = ...
    CellAnalysis(dt,dataCLEAN,MinVel,factorP2M,AngleType,windowWidth,...
    SmoothMETHOD,VelDepthFactor,VelCutOff,AngCutOff,Gama,RotDiff);

%% >>>>>>>>>> PLOT TRACKS AFTER DELETION <<<<<<<<<<<<<<<<<<<<
disp('<-- PLOT TRACKS AFTER DELETION -->');
PLOTtracks( 'AfterDeletion', VideoName, dataCLEAN );

%% Save dataCLEAN
 save('CLEANdata.mat','dataCLEAN');

%% Load the data
dataMAT = load('CLEANdata.mat');
dataCLEAN = dataMAT.dataCLEAN;

%% Write in Excel
col_header = ['X-coordinate', 'Y-coordinate', 'Time (s)', 'Cell ID'];
X_coordinate= dataCLEAN(:,1);
Y_coordinate= dataCLEAN(:,2);
Time_s = dataCLEAN(:,4);
Cell_ID  = dataCLEAN(:,5);
writetable(table(X_coordinate,Y_coordinate, Time_s, Cell_ID), '/Users/lvo5/Desktop/TestTrack/CLEANdata.xlsx');
%% Read an Excel file
dataCLEAN = xlsread('CLEANdata.xlsx',1);

%% >>>>>>>>>>> PRODUCE INDIVIDUAL TRACKS <<<<<<<<<<
disp('<-- PRODUCE INDIVIDUAL TRACKS -->');
Ncol = size(dataCLEAN,2); % ID column
NtrackedCell = max(dataCLEAN(:,Ncol));
%TrackVideosPath = what('TM000437.MP4');
TvideosPath = '/Users/lvo5/Desktop/TestTrack/TM000437.MP4';
% for ii = 1:NtrackedCell  
%for ii = 5:5
%% >>>>>>>>>>>> IMPOSED TRACK ON FRAMES <<<<<<<<<<<<
disp('<-- SUPER-IMPOSED CERTAIN TRACKS on FRAMES -->');
TrackNum = 3; %input('Enter Track Number as single digit Cell ID ')
Track2Frames(dt,VelThresh, VelData, dataCLEAN, VideoName, ...
    TestTrackFrames,FramePath,Ftype,TrackNum,TumbleSpeed,TumbleAngle);
            
%% VIDEO OF INDIVIDUAL TRACK 
% Add Frame Folder Path
%FolderTestPath = what(strcat(TestTrackFrames));
FrameTestPath = '/Users/lvo5/Desktop/TestTrack/TestFrames';
disp('<-- MOVIE OF fRAMES OF CERTAIN TRACKS -->');
%Frames2Movie( TrackNum, FrameTestPath, TvideosPath, Ftype );

ImgPath = strcat(FrameTestPath, '/');
FrameType = strcat('*.', Ftype);
FramesDir  = dir([ImgPath FrameType]);
numberOfFrames = length(FramesDir);

% Image parameters
[vidHeight, vidWidth, numChanls] = size(imread([ImgPath FramesDir(1).name]));

% ID column 
Ncol = size(dataCLEAN,2);

% Crop image, specifying crop rectangle, imcrop(I,rect)
% rect is a four-element position vector of the form [xmin ymin width height]
indtrack = find(dataCLEAN(:,Ncol) == TrackNum);
Xdata=dataCLEAN(indtrack,1);
Ydata=dataCLEAN(indtrack,2);
    
minX = min(Xdata);
maxX = max(Xdata);
minY = min(Ydata);
maxY = max(Ydata);

% IMresize
IMresize = 720/1080;

% Flags for padding
FlagPadding1 = 0;
FlagPadding2 = 0;
FlagPadding3 = 0;
FlagPadding4 = 0;

% Padding parameters
xpadding = 150*IMresize; 
ypadding = 150*IMresize; 

% Time Stamp parameter
FontSizeText = 18;
BoxColorText = 'black';
BoxTransText = 0.2;
TextColorText = 'white';

% Track parameters
if (minX*IMresize >= xpadding)
    
    % Flag
    FlagPadding1 = 1;
    
    % Min X
    Xmin = minX*IMresize-xpadding;
elseif (minX*IMresize < xpadding)
    Xmin = 0;
end

if (minY*IMresize >= ypadding)
    
    % Flag
    FlagPadding3 = 1;
    
    % Min Y
    Ymin = minY*IMresize-ypadding;
elseif(minY*IMresize < ypadding)
    Ymin = 0;
end

if(maxX*IMresize+xpadding <= 1280)
    
    % Flag
    FlagPadding2 = 1;
    
    % Width
    Iwidth = (maxX-minX)*IMresize+2*xpadding;
elseif(maxX*IMresize+xpadding/2 <= 1280)
    % Flag
    FlagPadding2 = 1;
    
    % Width
    Iwidth = (maxX-minX)*IMresize+3/2*xpadding;    
else
    Iwidth = (maxY-minY)*IMresize+xpadding;
end

if(maxY*IMresize + ypadding<= 720)
    
    % Flag
    FlagPadding4 = 1;
    
    % Height
    Iheight = (maxY-minY)*IMresize+2*ypadding;
    
elseif(maxY*IMresize + ypadding/2<= 720)  
    % Flag
    FlagPadding4 = 1;
    
    % Height
    Iheight = (maxY-minY)*IMresize+3/2*ypadding;
else
    Iheight = (maxY-minY)*IMresize+ypadding;
end

% Time stamp location
% Left Top
if(FlagPadding1 == 1 && FlagPadding3 == 1)
    location = [10 10];

% Left Bottom
elseif(FlagPadding4 == 1 && FlagPadding1 == 1)
    location = [10 Iheight-40];
    
% Right Top    
elseif(FlagPadding3 == 1 && FlagPadding4 == 1)
    location = [Iwidth-120 10];

% Right Bottom    
elseif(FlagPadding2 == 1 && FlagPadding4 == 1)
    location = [Iwidth-120 Iheight-40];

% Bottom Middle    
else
    location = [Iwidth-30 Iheight-40];
end

% Create a VideoWriter object to write the video out t a new, different file.
NewVideo = strcat('VideoTrack', num2str(TrackNum),'.avi');
writerObj = VideoWriter(NewVideo);
writerObj.FrameRate = 30;  % Default 30
open(writerObj);
	
% Read the frames back in from disk, and convert them to a movie.
% Preallocate recalledMovie, which will be an array of structures.
% First get a cell array with all the frames.
allTheFrames = cell(numberOfFrames,1);
allTheFrames(:) = {zeros(vidHeight, vidWidth, numChanls, 'uint8')};

% Next get a cell array with all the colormaps.
allTheColorMaps = cell(numberOfFrames,1);
allTheColorMaps(:) = {zeros(256, 3)};

% Now combine these to make the array of structures.
recalledMovie = struct('cdata', allTheFrames, 'colormap', allTheColorMaps);
for frame = 1 : numberOfFrames

    % Time Stamp
    TimeStamp = [num2str((frame-1)*dt,'%0.4f') ' sec'];
    
	% Read the image in from disk.
    thisFrame = imread([ImgPath FramesDir(frame).name]);
        
    % Image Crop
    %thisFrame = imcrop(thisFrame,[Xmin Ymin Iwidth Iheight]);
    
%     thisFrame = insertText(thisFrame, location, TimeStamp,'FontSize',...
%         FontSizeText,'BoxColor',BoxColorText,'BoxOpacity',BoxTransText,...
%         'TextColor',TextColorText);
    
	% Convert the image into a "movie frame" structure.
	recalledMovie(frame) = im2frame(thisFrame);
	
    % Write this frame out to a new video file.
	writeVideo(writerObj, thisFrame);
    
end % END FOR LOOP

% Close writing
close(writerObj);
 %% >>>>>>>>> CELL TRACK STATISTIC <<<<<<<<<<
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
%     TumbleSpeed(indS).LocalTumble(StructINDvel).speed = LocMinVEL;
end

% Average velocities of tracks with reversal event 
Vel(Vel(:)==0) = [];
AvgVelWR = Vel*factorP2M;

%% >>>>>>>>>>>>>>>>>EXPORTING STATISTICS<<<<<<<<<<<<<<<<<<<<<<<<

%Exporting ReverseAngle, RatioSpeedReverse, RunTimeBR, ANGULAR VEL, AVERAGE
%VEL, REVERSAL FREQUENCY, REVERSAL DURATIONS, and MEAN SQUARE DISTANCE table (MSD).
%Dont forgot to multiply pixel velocity with factor 0.1660
ReverseAngle_rad = ReverseAngle;
RatioSpeedReverseAngle = RatioSpeedReverse;
RunTimeBeforeReversal_s = RunTimeBR;
Angular_velocity_degsec = Avel;
[VelData, Vel] = CellVelocity(dt,dataCLEAN);
Average_velocity_micronpersec = Vel*factorP2M;
Reversalfrequency_countpersec = dataTumble(:,4)./dataTumble(:,2);
Tumble_duration_sec =dataTumble(:,2);

writetable(table(ReverseAngle_rad), '/Users/lvo5/Desktop/TestTrack/trackingstatistics.xlsx', 'sheet', 1);
writetable(table(RatioSpeedReverseAngle), '/Users/lvo5/Desktop/TestTrack/trackingstatistics.xlsx', 'sheet', 2);
writetable(table(RunTimeBeforeReversal_s), '/Users/lvo5/Desktop/TestTrack/trackingstatistics.xlsx', 'sheet', 3);
writetable(table(Angular_velocity_degsec), '/Users/lvo5/Desktop/TestTrack/trackingstatistics.xlsx', 'sheet', 4);
writetable(table(Average_velocity_micronpersec), '/Users/lvo5/Desktop/TestTrack/trackingstatistics.xlsx', 'sheet', 5);
writetable(table(Reversalfrequency_countpersec), '/Users/lvo5/Desktop/TestTrack/trackingstatistics.xlsx', 'sheet', 6);
writetable(table(Tumble_duration_sec), '/Users/lvo5/Desktop/TestTrack/trackingstatistics.xlsx', 'sheet', 7);

MSD_data = MSD(smoothDATA, dt);
lag_time_MSD_sec = MSD_data(:,1);
MSD = MSD_data(:,2);
numberofobservationonaverage = MSD_data(:,3);

writetable(table(lag_time_MSD_sec, MSD, numberofobservationonaverage), '/Users/lvo5/Desktop/TestTrack/trackingstatistics.xlsx', 'sheet', 8);

