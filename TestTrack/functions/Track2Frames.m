function [ ] = Track2Frames(dt,VelThresh,VelData,dataCLEAN,VideoName,...
    TestTrackFrames,FramePath,Ftype,TrackNum,TumbleSpeed,TumbleAngle )
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Create a new movie by recalling the saved images of certain tracks on.
%
% INPUTS:
%
%       VideoName is the name of video. 
%
%       TestTrackFrames is the subfolder where the frames with tracks will be saved 
%
%       OriginalSubfolder is the subfolder where frames are located
%
%       Ftype is the type of frames.
%
%       TrackNum is the number of track
%
%       VelData is the data for velocities
%
%       VelThresh is the treshold value for velocity
%
%       dt is frame per second
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

%% Load frames
% Image Path 
ImgPath = strcat(FramePath, '/');
FrameType = strcat('*.', Ftype);
FramesDir  = dir([ImgPath FrameType]);
numberOfFrames = length(FramesDir);

% Check images
if( ~exist(ImgPath, 'dir') || numberOfFrames<1 )
        disp('Directory not found or no matching images found.');
else
    disp('Frames are found!');
end

% Concatenate Frame name
Fname = strcat('Frame%4.4d', '.', Ftype);

% remove the folder if it doesn't exist already.
if exist(TestTrackFrames, 'dir')
    rmdir(TestTrackFrames, 's') 
end

% Create the folder
mkdir(TestTrackFrames);

%% Super-Imposed tracks on frames
Ncol = size(dataCLEAN,2);
Fcol = Ncol-1;
ind = find(dataCLEAN(:,Ncol)==TrackNum);
IMindx = uint32(dataCLEAN(ind,Fcol)/dt+1);

% Frame Number
FrameIND = IMindx;

% Plot parameters
Linewidth = 1;
Markersize = 1;

% Flags
FlagSTART = 0;
FlagEND = 0;

% Parameters
TrackFollow = 3;

% Frames before and after
FramesAddition = 15;

% Local parameter
IndAdjM = FramesAddition + TrackFollow; % Middle
IndAdjB = TrackFollow;  % Beginning
IndAdjE = FramesAddition + TrackFollow;  % End

% Add additional 15 frames before the track
if (min(IMindx)- FramesAddition > 1)
    FlagSTART = 1;
    ADDbind = min(IMindx)-FramesAddition:min(IMindx)-1;
    IMindx = [ADDbind'; IMindx];
end

% Add additional 15 frames after the track
if (max(IMindx)+FramesAddition < numberOfFrames)
    FlagEND = 1;
    ADDaind = max(IMindx)+1:max(IMindx)+FramesAddition;
    IMindx = [IMindx; ADDaind'];
end

% Data
X=dataCLEAN(ind,1);
Y=dataCLEAN(ind,2);

% Number of Tumbles
Ntumbles = length(TumbleAngle(TrackNum).LocalTumble);

% Angular velocity
indT = 0;
if (Ntumbles > 0)
    % Reverse Index
    indT = [TumbleAngle(TrackNum).LocalTumble(1:end).index]; 
end

% Number of Stops
Nstops = length(TumbleSpeed(TrackNum).LocalTumble);

% Stops
indS = 0;
if (Nstops > 0)
    % Stop Index
    indS = [TumbleSpeed(TrackNum).LocalTumble(1:end).index]; 
end

% Supper impose the track on frames
for frame = 1:length(IMindx)
    
    % Original frame Index
    ii = IMindx(frame);
    close all
    thisFrame = imread([ImgPath FramesDir(ii).name]);
    
    % Unvisible figure
    set(groot,'defaultFigureVisible','off')
    figure;imshow(thisFrame)
    hold on;
       
    % Plot
    % Frames in the middle
    if (FlagSTART == 1 && FlagEND == 1) 
        if ((ii >= FrameIND(1)+TrackFollow) && (ii <= FrameIND(end)+TrackFollow))                   
            plot(X(1:frame-IndAdjM),Y(1:frame-IndAdjM),'r*','LineWidth',...
                Linewidth,'MarkerSize',Markersize)
            
            % Reverses
            if (Ntumbles > 0)
                if ((frame-IndAdjM) >= indT(1))
                    hold on
                    sumR = sum(indT <= frame-IndAdjM);
                    plot(X(indT(1:sumR)),Y(indT(1:sumR)),'b*','LineWidth',...
                        Linewidth,'MarkerSize',Markersize)
                end
            end
            
            % Stops
            if (Nstops > 0)
                if ((frame-IndAdjM) >= indS(1))
                    hold on    
                    sumS = sum(indS <= frame-IndAdjM);
                    plot(X(indS(1:sumS)),Y(indS(1:sumS)),'y*','LineWidth',...
                        Linewidth,'MarkerSize',Markersize)
                end
            end         
            
        % END    
        elseif(ii > FrameIND(end)+TrackFollow)
            plot(X,Y,'r*','LineWidth',Linewidth,'MarkerSize',Markersize)
            
            % Reverses
            if (Ntumbles > 0)
                hold on
                plot(X(indT(1:end)),Y(indT(1:end)),'b*','LineWidth',...
                    Linewidth,'MarkerSize',Markersize)
            end
            
            % Stops
            if (Nstops > 0)
                hold on                
                plot(X(indS(1:end)),Y(indS(1:end)),'y*','LineWidth',...
                    Linewidth,'MarkerSize',Markersize)
            end 
        end % END middle
        
    % Frames in the end    
    elseif (FlagSTART == 1 && FlagEND == 0)
        if ((ii >= FrameIND(1)+TrackFollow) && (ii < FrameIND(end)))                   
            plot(X(1:frame-IndAdjE),Y(1:frame-IndAdjE),'r*','LineWidth',...
                Linewidth,'MarkerSize',Markersize)
            
            % Reverses
            if (Ntumbles > 0)
                if ((frame-IndAdjE) >= indT(1))
                    hold on
                    sumR = sum(indT <= frame-IndAdjE);
                    plot(X(indT(1:sumR)),Y(indT(1:sumR)),'b*','LineWidth',...
                        Linewidth,'MarkerSize',Markersize)
                end
            end
            
            % Stops
            if (Nstops > 0)
                if ((frame-IndAdjE) >= indS(1))
                    hold on    
                    sumS = sum(indS <= frame-IndAdjE);
                    plot(X(indS(1:sumS)),Y(indS(1:sumS)),'y*','LineWidth',...
                        Linewidth,'MarkerSize',Markersize)
                end
            end
            
        % END    
        elseif(ii >= FrameIND(end))
            plot(X,Y,'r*','LineWidth',Linewidth,'MarkerSize',Markersize)
            
            % Reverses
            if (Ntumbles > 0)
                hold on
                plot(X(indT(1:end)),Y(indT(1:end)),'b*','LineWidth',...
                    Linewidth,'MarkerSize',Markersize)
            end
            
            % Stops
            if (Nstops > 0)
                hold on                
                plot(X(indS(1:end)),Y(indS(1:end)),'y*','LineWidth',....
                    Linewidth,'MarkerSize',Markersize)
            end   
        end % END end
       
    % Frames in the beginning    
    elseif (FlagSTART == 0 && FlagEND == 1)
        if ((ii >= FrameIND(1)+TrackFollow) && (ii <= FrameIND(end)+TrackFollow))                   
            plot(X(1:frame-IndAdjB),Y(1:frame-IndAdjB),'r*','LineWidth',...
                Linewidth,'MarkerSize',Markersize)
            
            % Reverses
            if (Ntumbles > 0)
                if ((frame-IndAdjB) >= indT(1))
                    hold on
                    sumR = sum(indT <= frame-IndAdjB);
                    plot(X(indT(1:sumR)),Y(indT(1:sumR)),'b*','LineWidth',...
                        Linewidth,'MarkerSize',Markersize)
                end
            end
            
            % Stops
            if (Nstops > 0)
                if ((frame-IndAdjB) >= indS(1))
                    hold on    
                    sumS = sum(indS <= frame-IndAdjB);
                    plot(X(indS(1:sumS)),Y(indS(1:sumS)),'y*','LineWidth',...
                        Linewidth,'MarkerSize',Markersize)
                end
            end
        % END    
        elseif(ii > FrameIND(end)+TrackFollow)
            plot(X,Y,'r*','LineWidth',Linewidth,'MarkerSize',Markersize)
            
            % Reverses
            if (Ntumbles > 0)
                hold on
                plot(X(indT(1:end)),Y(indT(1:end)),'b*','LineWidth',...
                    Linewidth,'MarkerSize',Markersize)
            end
            
            % Stops
            if (Nstops > 0)
                hold on                
                plot(X(indS(1:end)),Y(indS(1:end)),'y*','LineWidth',...
                    Linewidth,'MarkerSize',Markersize)
            end   
        end % END beginning
    end
    hold off
        
    % Construct an output image file name.
    outputBaseFileName = sprintf(Fname, ii);
    outputFullFileName = fullfile(TestTrackFrames, outputBaseFileName);
    
    % Write the Original image array to the output file
    frameWithText = getframe(gca);

    % Save thisFrame image
    imwrite(frameWithText.cdata, outputFullFileName);
end

end % END OF FUNCTION

