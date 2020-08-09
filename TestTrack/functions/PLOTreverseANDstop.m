function [ ] = PLOTreverseANDstop(VideoName, AngVdata, VelData, factorP2M,...
    dataCLEAN, TumbleSpeed, TumbleAngle )
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This Function produces plots of reverses and stops
%
% INPUTS:
%
%       dataCLEAN is the clean data
%
%       TumbleSpeed is information about stops
%
%       TumbleAngle is information about reverses 
%
% OUTPUTS:
%
% USE: 
%       
%       PLOTreverseANDstop(AngVdata, VelData, factorP2M, dataCLEAN, ...
%       TumbleSpeed, TumbleAngle );
% 
% Mustafa Elmas
% University of Tennessee - Knoxville
% melmas at utk dot edu
% September 15 2017 
% Written and tested in Matlab R2017a
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ID column
Ncol = size(dataCLEAN,2);    

% Angle Column
AngleCol = Ncol-2;

% Number of cells
NtrackedCell = max(dataCLEAN(:,Ncol));

% remove the folder if it doesn't exist already.
folderName = strcat('TrackReverseStop', VideoName);
if exist(folderName, 'dir')
    rmdir(folderName, 's') 
end

% Create the folder
mkdir(folderName);

%% Plots of reverses and stops for each track
% for s=1:NtrackedCell
for s=3:3    
    % close al figures
    close all
    
    % Speed
    ind = find(VelData(:,2) == s);          % Local indices
    LocalVEL = VelData(ind(2:end),1);       % Local Velocities
    Time = VelData(ind(2:end),3);           % Local Time
    
    % Angular velocity
    indAng = find(AngVdata(:,2) == s);              % Local indices
          LocAngle = dataCLEAN(indAng(1:end),AngleCol);     % Local Angles
       LocalAngVEL = AngVdata(indAng(1:end),1);             % Local Ang. Vel.
    AbsLocalAngVEL = abs(LocalAngVEL);                      % Abs value of Ang. Vel.
           TimeAng = AngVdata(indAng(1:end),3);             % Local Time
           
    % Number of Reverses
    StructINDang = length(TumbleAngle(s).LocalTumble);
    
    % Number of stops
    StructINDvel = length(TumbleSpeed(s).LocalTumble);
    
%     % Figure sth
%     figure(NtrackedCell+s);
%     
%     % Plot sth track
%     indx = find(dataCLEAN(:,Ncol) == s);
%     x = dataCLEAN(indx,1);
%     y = dataCLEAN(indx,2);
%     plot(x, y)
%     hold on
%     
%     indTA = indx(IDmaxAngVEL);
%     plot(dataCLEAN(indTA,1), dataCLEAN(indTA,2),'*r')
%     hold off
%     title('TrackReverse')
%     xlabel('x')
%     ylabel('y')
    
    % Figure sth
    figure(s);
    
    % Plot sth track
    subplot(1,4,1)
    indx = find(dataCLEAN(:,Ncol) == s);
    x = dataCLEAN(indx,1);
    y = dataCLEAN(indx,2);
    plot(x, y)
    hold on
    
    % Angular velocity
    if (StructINDang > 0)
        indTumI = [TumbleAngle(s).LocalTumble.index];
        indT = indx(indTumI);
        plot(dataCLEAN(indT,1), dataCLEAN(indT,2),'*r')
    end 
    
    % Speed
    if (StructINDvel > 0)
        indStopI = [TumbleSpeed(s).LocalTumble.index];
        indS = indx(indStopI);
        plot(dataCLEAN(indS,1), dataCLEAN(indS,2),'*g')
    end 
    
    if (StructINDang > 0)
        for st = 1:StructINDang
            hold on
            indSE = indx([TumbleAngle(s).LocalTumble(st).location]);
            plot(dataCLEAN(indSE(1),1), dataCLEAN(indSE(1),2),'*k')
            hold on
            plot(dataCLEAN(indSE(end),1), dataCLEAN(indSE(end),2),'*k')
        end
    end
    
    hold off
    title('Track')
    xlabel('x')
    ylabel('y')
        
    % Plot Stops
    if (StructINDvel > 0)
        subplot(1,4,2)
        plot(Time, LocalVEL*factorP2M, 'b')
        hold on
        
        % Where it slows down
        for st = 1:StructINDvel
            indSL = [TumbleSpeed(s).LocalTumble(st).location];
            plot(Time(indSL), LocalVEL(indSL)*factorP2M, 'g')
            hold on
        end
        
        % Where it stops
        indSI = [TumbleSpeed(s).LocalTumble.index];
        plot(Time(indSI), LocalVEL(indSI)*factorP2M, 'g*')   
        hold off
        title('Reversal Event via Speed Criterion')
        xlabel('time (s)')
        ylabel('Speed')
    end
    
    % Plot Reversals
    if (StructINDang > 0)
        subplot(1,4,3)
        plot(TimeAng, AbsLocalAngVEL, 'b')
        hold on
        
        % Where it reverses
        for st = 1:StructINDang
            indTL = [TumbleAngle(s).LocalTumble(st).location];
            plot(TimeAng(indTL), AbsLocalAngVEL(indTL), 'r')
            hold on
        end
        
        % Where it reverses
        indTI = [TumbleAngle(s).LocalTumble.index];
        plot(TimeAng(indTI), AbsLocalAngVEL(indTI), 'r*')    
        hold off
        title('Reversal Event via Angle Criterion')
        xlabel('time (s)')
        ylabel('Angular Velocity')
    end 
    
    % Plot Reversals and Speed together
    if (StructINDang > 0 && StructINDvel >0 )
        subplot(1,4,4)
        plot(TimeAng, AbsLocalAngVEL, 'b')
        hold on 
        plot(Time, LocalVEL*factorP2M, 'k')
        hold on
        
        % Where it slows down
        indSI = [TumbleSpeed(s).LocalTumble.index];
        plot(Time(indSI), LocalVEL(indSI)*factorP2M, 'g*')
        hold on
        
        % Whre it reverses
        indTI = [TumbleAngle(s).LocalTumble.index];
        plot(TimeAng(indTI), AbsLocalAngVEL(indTI), 'r*') 
        hold off
        title('Reversal & Pause Event')
        xlabel('time (s)')
        ylabel('Angular Velocity & Speed')
    end
    
    % Save Plot
    set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
%     saveas(gcf,strcat('Track',int2str(s),'.jpg'))
    saveas(figure(s),[folderName strcat('/Track',int2str(s),'.jpg')]);
    
end % END FOR

end

