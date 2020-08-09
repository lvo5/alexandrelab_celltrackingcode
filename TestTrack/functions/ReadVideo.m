function [VideoObject] = ReadVideo(VideoName, Vtype )
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% The purpose of this script is to get information of a video
%
% INPUTS:
%
%       VideoName is the videoreader. 
%
%       Vtype is the type of video.
%
% OUTPUTS:
%
%       Vname is the name of video
%
%       VideoObject is the information about the video
%
%       VidHeight & VidWidth are the height and weight of each frames,resp.
%
%       NumFrames is number of frames in the video
%
% USE: 
%       
%       [VideoObject] = ReadVideo(VideoName, Vtype );
% 
% Mustafa Elmas
% University of Tennessee - Knoxville
% melmas at utk dot edu
% September 15 2017 
% Written and tested in Matlab R2017a
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Make sure the workspace panel is showing.
workspace;

% Concatenate video name and video type
Vname = strcat(VideoName, '.', Vtype);
Vtype = strcat('.', Vtype);

% Open the Sp7Pre.avi movie, first get the folder that it lives in.
folder = fileparts(which(Vname)); 
movieFullFileName = fullfile(folder, Vname);

% Check to see that it exists.
if ~exist(movieFullFileName, 'file')
	strErrorMessage = sprintf('File not found:\n%s\nYou can choose a new one, or cancel', movieFullFileName);
	response = questdlg(strErrorMessage, 'File not found', 'OK - choose a new movie.', 'Cancel', 'OK - choose a new movie.');
	if strcmpi(response, 'OK - choose a new movie.')
		[baseFileName, folderName, FilterIndex] = uigetfile(strcat('*',Vtype));
		if ~isequal(baseFileName, 0)
			movieFullFileName = fullfile(folderName, baseFileName);
		else
			return;
		end
	else
		return;
	end
end

disp('Opening video...')

%% Read a video
VideoObject = VideoReader(movieFullFileName);

end % END FUNCTION
