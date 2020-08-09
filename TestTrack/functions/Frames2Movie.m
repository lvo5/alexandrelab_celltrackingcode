function [  ] = Frames2Movie( dt, dataCLEAN, TrackNum, FrameTestPath, ...
    TvideosPath, Ftype )
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Create a new movie by recalling the saved images of certain tracks on.
%
% OUTPUTS:
%
%       TestTrackFrames is the subfolder where frames are located 
%
%       Ftype is the type of frames.
%
%       TrackNum is the number of track
%
% USE: 
%      [ ] = Frames2Movie( Subfolder, Ftype ) 
%      
% Mustafa Elmas
% University of Tennessee - Knoxville
% melmas at utk dot edu
% September 15 2017 
% Written and tested in Matlab R2017a
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% Change the current folder to the folder of this m-file.
% (The line of code below is from Brett Shoelson of The Mathworks.)
% if(~isdeployed)
% 	cd(fileparts(which(mfilename)));
% end

%% Load frames
% Folder where Original frames are in
ImgPath = strcat(FrameTestPath, '/');
FrameType = strcat('*.', Ftype);
FramesDir  = dir([ImgPath FrameType]);
numberOfFrames = length(FramesDir);

% Check images
if( ~exist(ImgPath, 'dir') || numberOfFrames<1 )
        disp('Directory not found or no matching images found.');
end

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

% Create a VideoWriter object to write the video out to a new, different file.
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
    thisFrame = imcrop(thisFrame,[Xmin Ymin Iwidth Iheight]);
    
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

% Create a movie
movefile(NewVideo,TvideosPath);

end % END FUNCTION

