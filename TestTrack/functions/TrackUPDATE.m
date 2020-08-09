function [ dataUPDATED ] = TrackUPDATE( TrackData )
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function removed the track you indicate
%
% INPUTS:
%       
%       DelTrackID is the ID of the track to be deleted
%
%       dataCLEAN is the data with all track
%
% OUTPUTS:
%
%       TrackData is the data with removed DelTrackID track
%
% USE: 
%       
%       [ TrackData ] = TrackUPDATE( dataCLEAN );
% 
% Mustafa Elmas
% University of Tennessee - Knoxville
% melmas at utk dot edu
% September 15 2017 
% Written and tested in Matlab R2017a
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Delete the DelTrackID track
Ncol = size(TrackData,2); % ID column
cntrl = 1;
LengthDEL = 0;
while(cntrl==1)
    
% Ask a user whether any track to be deleted or not
ck=input('Do you want to delete any track?, Y/N [Y]:','s');

    if ck=='Y'
        
        % Ask a user if any track needs to be deleted
        DelTrackID = input('Enter Track Numbers in [1,2,3] that you want to delete = ')

        % Number of tracks to be deleted
        LengthDEL = length(DelTrackID);
        
        % Sort number of tracks, descending order
        TrackID = sort(DelTrackID,'descend');
        
        for DelID = TrackID
            
            % Delete DelTrackID track
            delID = find(TrackData(:,Ncol) == DelID);
            TrackData(delID,:) = [];

            % Sort IDs
            [out4,idx4] = sort( unique(TrackData(:,Ncol)));

            % Update the data file
            TrackData(:,Ncol) = changem(TrackData(:,Ncol),idx4,out4);
        end

    elseif ck=='N'
        disp(strcat(num2str(LengthDEL), ' tracks were deleted!!'));
        dataUPDATED = TrackData;
        cntrl = cntrl +1;
    end  % END IF 
    
end  % END WHILE

end

