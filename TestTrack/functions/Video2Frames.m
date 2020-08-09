function [ ] = Video2Frames( VideoName, Vtype, Ftype, StartFrame, ...
                FrameSubfolder)
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Extract frames and get frame means from a movie and save individual 
% frames to separate image files.
%
% INPUTS:
%
%       VideoName is the name of video. 
%
%       Vtype is the type of video.
%
%       Ftype is the type of frames.
%   
%       StartFrame is the index of frame where to start analyzing the video
%
%       subfolder is the name of folder where frames are saved.
%
% OUTPUTS:
%
%       Frames in the video will be saved in subfolder. 
%
% USE: 
%       
%       [FSubFolder, GSubFolder ] = Video2Frames( VideoName, Vtype, ...
%       Ftype, startF, FrameSubfolder,GrayFrameSubfolder)
%
% Mustafa Elmas
% University of Tennessee - Knoxville
% melmas at utk dot edu
% September 15 2017 
% Written and tested in Matlab R2017a
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Call ReadVideo function to produce information about the video
[VideoObject] = ReadVideo(VideoName, Vtype );

% Frames' Height
Vidname = VideoObject.Name;

% Find the folder that the  video lives in.
folder = fileparts(which(Vidname)); 
movieFullFileName = fullfile(folder, Vidname);

% Concatenate Frame name
Fname = strcat('Frame%4.4d', '.', Ftype);

% Concatenate subfolder name for Original
FSubFolder = strcat('%s/', FrameSubfolder,'%s');

% The number of frames
NumFrames = VideoObject.NumberOfFrames;

% Number of frames is saved
numberOfFramesWritten = 0;

%% Ask user if they want to write the individual original frames out to disk.
	promptMessage = sprintf('Do you want to save the individual frames out to individual disk files?');
	button = questdlg(promptMessage, 'Save individual frames?', 'Yes', 'No', 'Yes');
	if strcmp(button, 'Yes')
		writeToDisk = true;
		% Extract out the various parts of the filename.
		[folder, baseFileName, extentions] = fileparts(movieFullFileName);
        % Make up a special new output subfolder for all the separate
		% movie frames that we're going to extract and save to disk.
		folder = pwd;   
        % Make it a subfolder of the folder where this m-file lives.
		outputFolder = sprintf(FSubFolder, folder, baseFileName);
        % Create the folder if it doesn't exist already.
		if ~exist(outputFolder, 'dir')
			mkdir(outputFolder);
		end
	else
		writeToDisk = false;
    end
    
    %% start saving frames in the video
    disp('Writing frames...')
    for ii = StartFrame : NumFrames
        
        % Extract the frame from the movie structure.
		thisFrame = im2double(read(VideoObject, ii));
  
        % Write the Original image array to the output file, if requested.
		if writeToDisk
			% Construct an output image file name.
			outputBaseFileName = sprintf(Fname, ii-StartFrame+1);
			outputFullFileName = fullfile(outputFolder, outputBaseFileName);
			
			% Save thisFrame image
			imwrite(thisFrame, outputFullFileName, Ftype);
        end
        
        % Update user with the progress.  Display in the command window.
		if writeToDisk
			progressIndication = sprintf('Wrote frame %4d of %d.', ii, NumFrames);
		else
			progressIndication = sprintf('Processed frame %4d of %d.', ii, NumFrames);
		end
		disp(progressIndication);
        
        % Increment frame count 
		numberOfFramesWritten = numberOfFramesWritten + 1;
        
    end  % END FOR LOOP 
    
    % Alert user that we're done.
	if writeToDisk
		finishedMessage = sprintf('Done!  It wrote %d frames to folder\n"%s"', numberOfFramesWritten, outputFolder);
	else
		finishedMessage = sprintf('Done!  It processed %d frames of\n"%s"', numberOfFramesWritten, movieFullFileName);
    end
    
	disp(finishedMessage); % Write to command window.
    
end % END FUNCTION

