function [Background] = BackgroundExtraction(VideoName,...
            Vtype, FrameSkip, StartFrame, Method)
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
% OUTPUTS:
%
%       Background is the average frame that is extracted from each frame
%       to get rid of non moving particles and noise
%
%       maxV and minV are the maximum and minimum intensity values of the
%           video after substracting the background and adding the mean
%           limits of the de-backgrounded images for histogram equalization
%
% USE: 
%       
%       [Background,maxVideo,minVideo] = BackgroundExtraction(VideoName,...
%            Vtype, FrameSkip, StartFrame, Method);
% 
%
% Mustafa Elmas
% University of Tennessee - Knoxville
% melmas at utk dot edu
% September 15 2017 
% Written and tested in Matlab R2017a
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Add video path
folder1 = fileparts(which(strcat(VideoName,Vtype))); % Videos
addpath(genpath(folder1));

%% Call ReadVideo function to produce information about the video
[VideoObject] = ReadVideo( VideoName, Vtype );

% Frames' Height
VidHeight = VideoObject.Height;

% Frames' Width
VidWidth = VideoObject.Width;

% The number of frames
NumFrames = VideoObject.NumberOfFrames;

%% The default method
if isempty(Method)
    Method = 'mean';
end

%% mode method
if strcmp(Method,'mode')
        disp('Extracting Background by MODE approach ...')   
        % Read Video
        IM = im2double(read(VideoObject));
        
        % Convert frames to gray scale
        if strcmp(get(VideoObject,'videoFormat'),'RGB24')
            GrayImage = IM(:,:,1,:)*0.2989+IM(:,:,2,:)*0.5870+IM(:,:,3,:)*0.1140;
            GrayImage = squeeze(GrayImage);
        else
            GrayImage = squeeze(IM);
        end
    
    % Frames is a vector with the list of frames to be used for background
    Frames = StartFrame:FrameSkip:NumFrames;
    VidFrames = GrayImage(:,:,Frames);
    
    % Extract Background
    Background = zeros(VidHeight, VidWidth); % Allocate memory
    parfor ii = 1:size(VidFrames,1)
        Background(ii,:) = mode(VidFrames(ii,:,:),3);
    end
    
%% mean method
elseif strcmp(Method,'mean')
    disp('Extracting Background by MEAN approach ...')
    
    % Allocate memories
    Background = zeros(VidHeight,VidWidth);
    
    % Frames is a vector with the list of frames to be used for background
    Frames = StartFrame:FrameSkip:NumFrames;
    
        for jj = Frames
            
            % Read ff frame
            IM = im2double(read(VideoObject,jj));
            
            % Convert frames to gray scale
            [rows, columns, numberOfColorChannels] = size(IM);
            if numberOfColorChannels > 1
                % Convert it to gray scale 
                GrayImage = rgb2gray(IM);
            end

            % Extract Background
            Background = Background + GrayImage/length(Frames);
        end     
       
%% median method
elseif strcmp(Method,'median')
    disp('Extracting Background by MEDIAN approach ...')
    
    % Read Video
    IM = im2double(read(VideoObject));
    
    % Convert frames to gray scale
    if strcmp(get(VideoObject,'videoFormat'),'RGB24')
        GrayImage = IM(:,:,1,:)*0.2989+IM(:,:,2,:)*0.5870+IM(:,:,3,:)*0.1140;            
        GrayImage = squeeze(GrayImage);
    else
        GrayImage = squeeze(IM);
    end
        
    % Frames is a vector with the list of frames to be used for background
    Frames = StartFrame:FrameSkip:NumFrames;
    VidFrames = GrayImage(:,:,Frames);
    
    % Extract Background
    Background = zeros(VidHeight,VidWidth); % Allocate memory
    parfor kk = 1:size(VidFrames,1)
       Background(kk,:) = median(IM(kk,:,:),3);
    end

end % END IF

end % END FUNCTION
