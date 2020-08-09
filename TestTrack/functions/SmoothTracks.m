function [ outDATA ] = SmoothTracks(INPUTdata, AvgPoints, SmoothMETHOD)
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This Function Smooth the data: (x,y) positions of bacteria
%
% INPUTS:
%       
%       AvgPoints: the window length (in frames) of the smoothing algorithm
%       
%       INPUTdata: the data with noise
%
%       SmoothMETHOD:  the method used for the smoothing algorithm. 
%       It can be mean, median, max and Sgolay. Default is mean.
%
% OUTPUTS:
%
%       smoothDATA is the smooth data
%
% USE: 
%       
%       [ smoothDATA ] = SmoothData( OUTdata, AvgPoints, SmoothMETHOD );
% 
% Mustafa Elmas
% University of Tennessee - Knoxville
% melmas at utk dot edu
% September 15 2017 
% Written and tested in Matlab R2017a
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% The default method
if isempty(SmoothMETHOD)
    SmoothMETHOD = 'MovAvg';
end

% ID column number
Ncol = size(INPUTdata,2);

% DataXY = INPUTdata(:,1:2);
smoothrow = length(INPUTdata);
smoothDATA = zeros(smoothrow, 2);
NtrackedCell = max(INPUTdata(:,Ncol));

% OUTPUT data
outDATA = INPUTdata;

% Smoothing by Moving Average
if strcmp(SmoothMETHOD, 'MovAverage')
    for n=1:NtrackedCell
    
    % indeces of the nth track
    indx = find(INPUTdata(:,Ncol) == n);
    
    % x and y positions
    DataXY = INPUTdata(indx,1:2);
    
    % Smooth the data 
    smoothDATA(indx,1:2) = movmean(DataXY, AvgPoints);
    end

% Smoothing by Moving Median
elseif strcmp(SmoothMETHOD, 'MovMedian')
    for n=1:NtrackedCell
    
    % indeces of the nth track
    indx = find(INPUTdata(:,Ncol) == n);
    
    % x and y positions
    DataXY = INPUTdata(indx,1:2);
    
    % Smooth the data 
    smoothDATA(indx,1:2) = movmedian(DataXY, AvgPoints);
    end
    
% Smoothing by Savitzy-Golay polynomial  
elseif strcmp(SmoothMETHOD, 'Sgolay')
    windowWidth = 7;
    polynomialOrder = 3;
    for n=1:NtrackedCell
    
    % indeces of the nth track
    indx = find(INPUTdata(:,Ncol) == n);
    
    % x and y positions
    DataXY = INPUTdata(indx,1:2);
    
    % Smooth the data 
    smoothDATA(indx,1:2) = sgolayfilt(DataXY, polynomialOrder, windowWidth);
    end

% Local regression using weighted linear least squares and a 2nd degree 
% polynomial model. using a span of 15% of the total number of data points    
elseif strcmp(SmoothMETHOD, 'loess')    
    for n=1:NtrackedCell
    
        % indeces of the nth track
        indx = find(INPUTdata(:,Ncol) == n);

        % x and y positions
        DataXY = INPUTdata(indx,1:2);
        
        % Smooth data
        smoothDATA(indx,1) = smooth(DataXY(:,1),0.15,'loess');
        smoothDATA(indx,2) = smooth(DataXY(:,2),0.15,'loess');
    end
    
% A robust version of 'loess' that assigns lower weight to outliers in the 
% regression. Assigns 0 weight to data outside 6 mean absolute deviations.
% using a span of 15% of the total number of data points 
elseif strcmp(SmoothMETHOD, 'rloess')    
    for n=1:NtrackedCell
    
        % indeces of the nth track
        indx = find(INPUTdata(:,Ncol) == n);

        % x and y positions
        DataXY = INPUTdata(indx,1:2);
        
        % Smooth data
        smoothDATA(indx,1) = smooth(DataXY(:,1),0.13,'rloess');
        smoothDATA(indx,2) = smooth(DataXY(:,2),0.13,'rloess');   
    end

end

% Smooth data
outDATA(:,1:2) = smoothDATA(:,1:2);

end

