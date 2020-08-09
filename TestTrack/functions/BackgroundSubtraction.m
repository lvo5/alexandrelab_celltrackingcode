function [ Fground ] = BackgroundSubtraction( AdpFiltLength, ...
         Background, Image )
%%
% Subtrct Background from each Frames and 
% returns foreground of each frame
%
% INPUTS:
%
%       Background is the background of each image
%
%       Image is the original frame
%
%       AdpFiltLength is the adaptive filter size
%
% OUTPUTS:
%
%       Fground is foreground of each frame
%
% USE: 
%       
%       [ Fground ] = BackgroundSubtraction( Background, Image );
% 
%
% Mustafa Elmas
% University of Tennessee - Knoxville
% melmas at utk dot edu
% September 15 2017 
% Written and tested in Matlab R2017a
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Convert Image to Gray Scale
% Convert frames to gray scale
[rows, columns, numberOfColorChannels] = size(Image);
if numberOfColorChannels > 1
    curIm = rgb2gray(Image);
end

%Background subtraction
Fground = imcomplement(curIm) - imcomplement(Background);
% Fground = Fground - min(Fground(:));
% Fground(Fground(:) > 0.55*max(Fground(:))) = 1;
%         Fground(Fground(:) < 0) = 0;

% Contrasted foreground
Fmax = max(Fground(:));
Fmin = min(Fground(:));
Ffactor = Fmax - Fmin;
ContFIM = (Fground-Fmin)/Ffactor;

% Filter the frame
Filter_sig = 1.0;
FilterIM = fspecial('gaussian', ceil(Filter_sig*7), Filter_sig);
FilterIM = FilterIM./sum(FilterIM(:));
IMfiltered = imfilter(ContFIM, FilterIM, 'same', 'replicate');

% Image contrast
Rmin = min(IMfiltered(:));
Rmax = max(IMfiltered(:));
Rfactor = Rmax - Rmin;
Cfactor = 1/Rfactor;
Fground = (IMfiltered - Rmin)*Cfactor;

% Smooth the image
Fground = adpmedian(Fground, AdpFiltLength);

% % Detect objects
% Fground = rdivide(Fground, Background);
end

