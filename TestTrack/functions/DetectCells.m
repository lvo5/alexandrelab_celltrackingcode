function [DataPosition] = DetectCells(dt,ObjRadius,Inoise,maskradius, ...
 PixTresh,AdpFiltLength,StartFrame,FrameSkip,Ftype,VideoName,Vtype,...
 Method,FramePath)
%%
% Extract Background of the video by calculating mean (or mode, median) 
% value of the whole movie, then subtract the background from each frame 
% in order to get rid of all noise and non moving particles. 
% INPUTS:
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
%       ObjRadius is object radius 
%
%       Inoise is image noise ratio
%
%       maskradius is masradius for masking
%
%       PixTresh is pixel treshold
%
%       AdpFiltLength is length of window for filtering
%
%       dt is frame per second
%
% OUTPUTS:
%
%       DataPosition is position of cells
%
% USE: 
%       
%       [DataPosition] = DetectCells(ObjRadius,Inoise,maskradius, ...
%       PixTresh,AdpFiltLength,StartFrame,FrameSkip,Ftype,VideoName,Vtype,...
%       Method,FramePath);
% 
%
% Mustafa Elmas
% University of Tennessee - Knoxville
% melmas at utk dot edu
% September 15 2017 
% Written and tested in Matlab R2017a
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Call BackgroundExtraction function to estimate background
disp('<-- EXTRACT The BACKGROUND -->');
[Background] = BackgroundExtraction(VideoName,Vtype,...
                FrameSkip, StartFrame, Method);


% % Load frames
ImgPath = strcat(FramePath, '/');
FrameType = strcat('*.', Ftype);
FramesDir  = dir([ImgPath FrameType]);

% Frame Number
NumFrames = length(FramesDir);

% Check images
if( ~exist(ImgPath, 'dir') || NumFrames<1 )
        disp('Directory not found or no matching images found.');
end

%% OBJECT DETECTION
disp('<-- DETECT OBJECTS -->');
DataPosition = [];
for ii = StartFrame:NumFrames
    % Read frames
    Image = im2double(imread([ImgPath FramesDir(ii).name]));
    
    % % Call BackgroundSubtraction to get Fground of the image
    [ Fground ] = BackgroundSubtraction(AdpFiltLength,Background,Image);

    % Call ObjectDetection to detect objects and find centroids of them
    [position] = ObjectDetection(PixTresh,ii,Fground,ObjRadius,...
                   Inoise,maskradius);
    DataPosition = [DataPosition, position'];
end
DataPosition = DataPosition';
DataPosition(:,6) = (DataPosition(:,6)-1)*dt;

end

