function [VideoName,Vtype,Ftype,StartFrame,FrameSkip,OriginalSubfolder,...
BinarySubfolder,TestTrackFrames,PixTresh,Method,factorP2M,dt,MAXdisp,param, ...
RotDiff,Gama,AngCutOff,VelDepthFactor,VelCutOff,MinVel,VelThresh,...
CellinFrames,ObjRadius,Inoise,maskradius,AdpFiltLength,AngleType,windowWidth,...
SmoothMETHOD] = InitValues()
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This Function Returns initial values for cell tracking
%
% OUTPUTS:
%
%       VideoName is the name of video. 
%
%       FSubfolder is name of subfolder, Original frames are saved.
%
%       BSubfolder is name of subfolder, Binarized frames will be saved.
%
%       Ftype is the type of frames.
%
%       PixTresh is the treshold value
%       
%       VideoName is the videoreader. 
%
%       Vtype is the type of video
%
%       StartFrame is the index of frame where to start analyzing the video 
%
%       FrameSkip is the downsample factor for frame averaging.
%
%       Method is the method is used for extracting background:
%           'mode', 'mean' or 'median'. The default is mean.
%
%       factorP2M is the factor from pixel to micron
%
%       dt is the time step between frames
%
%       MAXdisp is the maximum displacement between frames
%
%       param 
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
%       CellinFrames least number of frames that cells in for analysis
%
%       feature is expected size of the particle (diameter)
%
%       Inoise is characteristic lengthscale of noise in pixels.
%       Additive noise averaged over this length should vanish. May assume 
%       any positive floating value. May be set to 0 or false, in which 
%       case only the highpass "background subtraction" operation is 
%       performed. the noise correlation
%
%       masradius: If an image is vignetted, this is the radius
%       of the image to use in calculations. Otherwise, this defaults to a value
%       1200. A maskradius equal to -1 will ignore the vignette.
%
%       AdpFiltLength is the adaptive filter size like 
%       AdpFiltLength x AdpFiltLength matrix
%
%       windowWidth is the window length for smoothing the tracks
%
% USE: 
%       
%       [VideoName, Vtype, Ftype, StartFrame, FrameSkip, OriginalSubfolder,...
%       BinarySubfolder, PixTresh, Method, factorP2M, dt, MAXdisp, param, ...
%       RotDiff, Gama, AngCutOff, VelDepthFactor, VelCutOff, MinVel, ...
%       CellinFrames] = InitValues();
% 
% Mustafa Elmas
% University of Tennessee - Knoxville
% melmas at utk dot edu
% September 15 2017 
% Written and tested in Matlab R2017a
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subfolders name
OriginalSubfolder = 'OriginalFrames';
BinarySubfolder = 'BinaryFrames';
TestTrackFrames = 'TestFrames';

% Type the video that you want to analyze
% It must be in the same directory that you work in
% Change the name for different videos
VideoName = 'SP7 01OD'; 
Vtype = 'avi';
Ftype = 'tif';

% Which Frame to start with.
% First some frames could be solid black due to the recording
StartFrame = 1; 

% Set the thresh hold, Noisy data if it decreases
PixTresh = 0.15;

% Every how many original frames to estimate
FrameSkip = 1;

% Method to Estimate background: mean or median or mode
Method = 'mean';

% Pixel size or conversion factor from pixel to microns
% if you change this, you should change MinVel, as well!
factorP2M = 0.166; 

% Time step
dt = 1/30;

% Expected size of the particle (diameter)
ObjRadius = 15;

% Image noise ratio
Inoise = 2.5;

% If an image is vignetted, this is the radius of the image 
% to use in calculations. Otherwise, this defaults to a value 1200. 
% A maskradius equal to -1 will ignore the vignette.
maskradius = -1;

% Adaptive filter size, AdpFiltLength must be an odd integer greater than 1.
AdpFiltLength = 3;

% Angle Type radian (rad) or degree (deg)
AngleType = 'rad';
% AngleType = 'deg';

% Maximum Displacement of a cell in between 2 frames
% increasing this will increase the number of trajectories
MAXdisp = 20;

% Create a structure 
param.mem = 0;      % How many frames the cell can be lost
param.good = 30;    % cell must be in certain number of frames for analysis
param.dim = 2;      % x, y dimension
param.quiet = 0;
% param.minDisplacement = 0;
% param.toMaxDisplacement = 20;
% imsz = size(Background);
%combTol = 10;
%avgSz = 10;

% Minimum velocity for analyzing cell. Ignore cells swim less than MinVel
MinVel = 90; %1.5*factorP2M; 

% A cell must be in certain number of frames for analysis
CellinFrames = 30;

% VELOCITY CUTOFF
% Increasing will cause less reversal frequency
VelCutOff = 3.5;

% VELOCITY DEPTH FACTOR
% decreasing will cause less reversal frequency
VelDepthFactor = 0.9;

% Velocity thresold for indicating where bacteria slows down on its track
VelThresh = 0.2;

% ANGULAR CUTOFF
% Increasing will cause increasing reversal frequency
AngCutOff = 0.9;

% Gamma for ANGULAR VELOCITY CUTOFF
% Increasing will cause less reversal frequency
Gama = 7.3;

% Rotational Diffusivity
% Increasing will cause increasing reversal frequency
if(strcmp(AngleType,'deg'))
    RotDiff = 0.1*(180/pi)^2; %in degrees
else
    RotDiff = 0.1; % in radians
end

% Windows Length for smoothing the tracks: odd number
windowWidth = 3;

% Method for smoothing tracks: MovAverage, MovMedian, Sgolay, loess, rloess
SmoothMETHOD = 'MovAverage';

end % END FUNCTION

