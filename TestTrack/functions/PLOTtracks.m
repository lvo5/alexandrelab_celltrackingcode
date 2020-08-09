function [ ] = PLOTtracks( Deletion, VideoName, dataCLEAN )

% remove the folder if it doesn't exist already.
folderName = strcat('Tracks', Deletion, VideoName);
if exist(folderName, 'dir')
    rmdir(folderName, 's') 
end

% Create the folder
mkdir(folderName);

%% Plot all tracks of cells
Ncol = size(dataCLEAN,2);     % ID column
NtrackedCell = max(dataCLEAN(:,Ncol));
TrackStack = 100; % Number of tracks on each plot
Nplots = ceil(NtrackedCell/TrackStack);
index = zeros(Nplots,1);

% Plots
for p = 1:Nplots
    
    if p < Nplots
        index(p) = p*TrackStack;
    else
        index(p) = NtrackedCell;
    end
    
    figure(p); 
    set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
    for n=(p-1)*TrackStack+1:index(p)
        lbl = int2str(n);
        indx = find(dataCLEAN(:,Ncol) == n);
        x = dataCLEAN(indx,1);
        y = dataCLEAN(indx,2);
        mx = mean(x);
        my = mean(-y);
        plot(x, -y)
        text(mx,my,lbl)
        hold on
    end
        hold off
    
    PlotName = strcat('/TracksSP7-',int2str((p-1)*TrackStack+1),...
        '-',int2str(index(p)),'.jpg');
    %% Save Plots
    saveas(figure(p),[folderName PlotName])

    % close all frames
    %close all
end % END FOR p

end

