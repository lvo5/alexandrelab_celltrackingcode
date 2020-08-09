function [position] = ObjectDetection(PixTresh, frame,image,feature,...
                        Inoise,maskradius)
%%
%   Call the bpass, pkfnd and cntrd functions and generate
%   the (unsorted) position list of particles in each frame. The
%   position list will be used by track to create particle trajectories.
%
% INPUTS:
%
%       PixTresh is a pixel threshold
%
%       frame is the frame number
%
%       image is the foreground image. 
%
%       feature is expected size of the particle (diameter)
%
%       masradius % maskradius: If an image is vignetted, this is the radius
%       of the image to use in calculations. Otherwise, this defaults to a value
%       1200. A maskradius equal to -1 will ignore the vignette.
%
% OUTPUTS:
%
%       postion is the positions of the objects in the image
%
% USE: 
%       [position] = ObjectDetection(PixTresh,frame,image,feature,...
%                        maskradius);
% 
%
% Mustafa Elmas
% University of Tennessee - Knoxville
% melmas at utk dot edu
% September 15 2017 
% Written and tested in Matlab R2017a
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% Check the feature 
if mod(feature,2) == 0 || feature < 3
    warning('Feature size must be an odd value >= 3.');
    signal=[];
    noise=[];
    return;
end    

% Set the maskradius to a default value
if nargin==2
%    maskradius=1200; 
    maskradius=-1; 
end

% Bandpass filter
imagebp = bpass(image,Inoise,feature);
    
% Find locations of the brightest pixels Need to change the 'th'
% (threshold) argument to something that is specified or determined.
% A rough guide is to accept 60-70% of the brightest pixels 
th = PixTresh*max(imagebp(:));
pk = pkfnd(imagebp, th, feature);
% disp(['Maximum imagebp value is ', num2str(max(imagebp(:)))]);
% disp(['Using values > ', num2str(th)]);
% disp(['located ' num2str(size(pk,1)) ' particles.']);

% Refine location estimates using centroid
sz = 2*feature+1;
cnt = cntrd(imagebp, pk, sz);
    
% Add frame number to tracking data
cnt(:,5) = 0;       % Angle
cnt(:,6) = frame;   % Frame number

r = (sz-1)/2;
[x, y]=meshgrid(-(r):(sz-r-1),-(r):(sz-r-1));
particlemask=((x.^2+y.^2)<=r^2);
particlemask=((x.^2+y.^2)>r^2)-particlemask;

% go through list of particle locations
% make a circle of radius feature at each location with value -1
imagenoise = image;
for i=1:size(pk,1)
    x = pk(i,1);
    y = pk(i,2);
    imagenoise((y-r):(y+r),(x-r):(x+r))=...
        image((y-r):(y+r),(x-r):(x+r)).*particlemask;
end 

% Make the mask for the signal
sz = feature-2;
r = (sz-1)/2;
[x, y]=meshgrid(-(r):(sz-r-1),-(r):(sz-r-1));
particlemask=((x.^2+y.^2)<=r^2);
particlemask=((x.^2+y.^2)>r^2)-particlemask;

% go through list of particle locations
% make a circle of radius feature at each location with value -1
imagesignal = image;
for i=1:size(pk,1)
    x = pk(i,1);
    y = pk(i,2);
    imagesignal((y-r):(y+r),(x-r):(x+r))=...
        image((y-r):(y+r),(x-r):(x+r)).*particlemask;
end 

imagesignal = -imagesignal;
% disp('flag');

% Finally, mask the image to exclude vignette regions
imagenoise = vignette(imagenoise,maskradius,-1);
imagesignal = vignette(imagesignal,maskradius,-1);

% Now that we have maskimage, let's calculate the noise
% Statistics of all regions with positive values > 0
index = find(imagenoise>0);
noise = image(index);
index = find(imagesignal>0);
signal = image(index);

% imagesc(imagenoise./max(imagenoise(:)));
% disp(['Mean signal: ', num2str(mean(signal))]);
% disp(['Mean noise: ', num2str(mean(noise))]);
% disp(['Standard deviation noise: ', num2str(std(noise))]);
% disp(['Signal-to-noise: ', num2str((mean(signal)-mean(noise))/std(noise)),...
%     '(',num2str(10*log10((mean(signal)-mean(noise))/std(noise))),' dB)' ]);

position = cnt;
end

