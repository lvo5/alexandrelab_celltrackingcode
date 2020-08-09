function [INDmax, Maxima, INDmin, Minima] = LocMinMax(dataVEL)


% % Find maxima
% [pks, locs] = findpeaks(data);
% findpeaks(data)
% text(locs+.02,pks+0.5,num2str((1:numel(pks))'))


% Find Max values and locations
% figure;
[Maxima, INDmax] = findpeaks(dataVEL);
% findpeaks(dataVEL);

% Find Max values and locations
InvertDataVEL = max(dataVEL) - dataVEL;
[Minima, INDmin] = findpeaks(InvertDataVEL);

% True minima
Minima = dataVEL(INDmin);


end

