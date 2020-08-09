function [ ] = PlotStatsParam( VideoName,dt,AngleType,RunTimeBR,...
    AvgVelWR,ReverseAngle,RatioSpeedReverse )



% remove the folder if it doesn't exist already.
folderName = strcat('PlotStats', VideoName);
if exist(folderName, 'dir')
    rmdir(folderName, 's') 
end

% Create the folder
mkdir(folderName);

% Number of bins
nbinsRA = 12;   % Reverse Angle
nbinsRV = 10;   % Ratio Velocity 
nbinsAV = 10;   % Average Velocity 
nbinsRT = 7;    % Run Time

%% Plot of Reverse Angle
% Histogram Plot of Reversing Angle with probability
if(strcmp(AngleType,'deg'))
    figure(1);histogram(ReverseAngle.*180/pi,nbinsRA,'Normalization','probability')
else
    figure(1);histogram(ReverseAngle,nbinsRA,'Normalization','probability')
end
title('Reversing Angle')
ylabel('Probability')
xlabel(AngleType)
% Save histogram
saveas(figure(1),[folderName strcat('/histRevAngleProb','.jpg')]);

% Histogram Plot of Reversing Angle with frequency
if(strcmp(AngleType,'deg'))
    figure(2);histogram(ReverseAngle.*180/pi,nbinsRA)
else
    figure(2);histogram(ReverseAngle,nbinsRA)
end
title('Reversing Angle')
ylabel('Frequency')
xlabel(AngleType)
% Save histogram
saveas(figure(2),[folderName strcat('/histRevAngleFreq','.jpg')]);

%% Plots of Speed before and after reversal event 
% Histogram of Speed before and after reversal event with probability
figure(3);histogram(RatioSpeedReverse,nbinsRV,'Normalization','probability')
title('Speed Ratio Before and After Reversal event')
ylabel('Probability')
xlabel('Speed Ratio')
% Save histogram
saveas(figure(3),[folderName strcat('/histRatioSPeedBAProb','.jpg')]);

% Histogram of Speed before and after reversal event with frequency
figure(4);histogram(RatioSpeedReverse,nbinsRV)
title('Speed Ratio Before and After Reversal event')
ylabel('Frequency')
xlabel('Speed Ratio')
% Save histogram
saveas(figure(4),[folderName strcat('/histRatioSPeedBAFreq','.jpg')]);

%% Plots of Average Speed with reversal event
% Histogram of Average Speed with reversal event with probability
figure(5);histogram(AvgVelWR,nbinsAV,'Normalization','probability')
title('Average Speed with Reversal event')
ylabel('Probability')
xlabel('Run Time (micron/sec)')
% Save histogram
saveas(figure(5),[folderName strcat('/histAvgSpeedWRProb','.jpg')]);

% Histogram of Average Speed with reversal event with probability
figure(6);histogram(AvgVelWR,nbinsAV)
title('Average Speed with Reversal event')
ylabel('Frequency')
xlabel('Run Time (micron/sec)')
% Save histogram
saveas(figure(6),[folderName strcat('/histAvgSpeedWRFreq','.jpg')]);

%% Plots of Run Time between two reversal events
% Histogram of Average Speed with reversal event with probability
figure(7);histogram(RunTimeBR,nbinsRT,'Normalization','probability')
title('Run Time Between Two Reversal event')
ylabel('Probability')
xlabel('Run Time (sec)')
% Save histogram
saveas(figure(7),[folderName strcat('/histRunTimeBRProb','.jpg')]);

% Histogram of Average Speed with reversal event with frequency
figure(8);histogram(RunTimeBR*dt,nbinsRT)
title('Run Time Between Two Reversal event')
ylabel('Frequency')
xlabel('Run Time (sec)')
% Save histogram
saveas(figure(8),[folderName strcat('/histRunTimeBRFreq','.jpg')]);

end % END FUNTION

