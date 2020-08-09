function [ dataUPDATED ] = MergeTrack( dataCLEAN, dt )
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function removed the track you indicate
%
% INPUTS:
%       
%       MerTrackID is the ID of the track to be Merged
%
%       dataCLEAN is the data with all track
%
%       dt is frame per second (1/30)
%
% OUTPUTS:
%
%       TrackData is the data with merged MerTrackID tracks
%
% USE: 
%       
%       [ TrackData ] = MergeTrack( dataCLEAN );
% 
% Mustafa Elmas
% University of Tennessee - Knoxville
% melmas at utk dot edu
% September 15 2017 
% Written and tested in Matlab R2017a
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[nrow, ncol] = size(dataCLEAN);
Tcol = ncol-1; % Time col
TrackData = dataCLEAN; % Data for merging 
DelTrackData = dataCLEAN; % Data for deletion
%% Merge the MergeTrackID track
cntrl = 1;
while(cntrl==1)
    
% Ask a user whether any track to be deleted or not
ck=input('Do you want to merge any tracks?, Y/N [Y]:','s');

    if ck=='Y'
        MerTrackID = input('Enter Track Numbers that you want to merge as a row vector = ')
        
        %MergedTracks = [];
        
        % Merge MerTrackID track
        sizeMerID = length(MerTrackID);
        
        % HEAD of the track to be merged
        HeadID = find(TrackData(:,ncol) == MerTrackID(1));
        HeadTracks = TrackData(HeadID,:);
        MergedTracks = HeadTracks';
        
        for ii = 2:sizeMerID
        
            HeadLength = length(HeadTracks);
            HeadX = HeadTracks(HeadLength,1);
            HeadY = HeadTracks(HeadLength,2);
            HeadT = HeadTracks(HeadLength,Tcol);
            
            % Local ID
            TrackID = MerTrackID(ii);
            
            % Track to be merged
            TailID = find(TrackData(:,ncol) == TrackID);
            TailTracks = TrackData(TailID,:);
    
            TailLength = length(TailTracks);
            TailX = TailTracks(1,1);
            TailY = TailTracks(1,2);
            TailT = TailTracks(1,Tcol);
            
            % Fill Gap
            FrameGap = abs(ceil((HeadT - TailT)/dt))-1; 
            Xgap = HeadX + ((TailX - HeadX )/FrameGap)*(1:FrameGap); % linspace(HeadX,TailX,FrameGap);
            Ygap = HeadY + ((TailY - HeadY )/FrameGap)*(1:FrameGap); %linspace(HeadY,TailY,FrameGap);
            Tgap = HeadT + dt*(1:FrameGap); %linspace(HeadT,TailT,FrameGap);
            Gapdata = zeros(FrameGap,ncol);
            Gapdata(:,1) = Xgap;
            Gapdata(:,2) = Ygap;
            Gapdata(:,Tcol) = Tgap;
            Gapdata(:,ncol) = 7;
            
            % Merge Tracks
            MergedTracks = [MergedTracks, Gapdata', TailTracks'];
            
            % Update Head Tracks
            HeadTracks = TailTracks;
            
            % >>>>>>>>> Delete DelTrackID track <<<<<<<<<<
            DelTrackData(TailID,:) = [];

            % Sort IDs
            [out4,idx4] = sort( unique(DelTrackData(:,ncol)));

            % Update the data file
            DelTrackData(:,ncol) = changem(DelTrackData(:,ncol),idx4,out4); 
    
        end % END ii
        MergedTracks = MergedTracks';
        
        % Number of tracked cell after deletion
        Ndel = max(DelTrackData(:,ncol));
        
        % ID of merged tracked
        NtrackedCell = Ndel+1; 
        MergedTracks(:,ncol) = NtrackedCell;
        
        % UPDATE DATA
        TrackData = [DelTrackData', MergedTracks']';

            % Plot all tracks of cells
            figure; 
            set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
            for n=1:NtrackedCell
                lbl = int2str(n);
                indx = find(TrackData(:,ncol) == n);
                x = TrackData(indx,1);
                y = TrackData(indx,2);
                mx = mean(x);
                my = mean(-y);
                plot(x, -y)
                text(mx,my,lbl)
                hold on
            end
            Tracks = strcat('TracksUpdated', '.jpg');
            % Save Plots
            saveas(gcf,Tracks)
             
            % UPDATE data
            DelTrackData = TrackData;
            
    elseif ck=='N'
        disp('Lucky you!!');
        dataUPDATED = TrackData;
        cntrl = cntrl +1;
    end  % END IF 
    
end  % END WHILE

end

