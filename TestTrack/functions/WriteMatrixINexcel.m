function [] = WriteMatrixINexcel( filename,dt )

% headers = {'X', 'Y','OFN', 'FN','Time','ID'};
headers = {'X', 'Y','FN','Time','ID'};
data = load(strcat(filename,'.mat'));

XYdata = data.dataCLEAN;
XYdata(:,3) = (XYdata(:,4)/dt + 1); % Frame Number

% % Start frame number from one
% NtrackedCell = max(XYdata(:,5));
% for ii = 1:NtrackedCell
%     ind = find(XYdata(:,5) == ii);
%     XYdata(ind,4) = XYdata(ind,3) - min(XYdata(ind,3)) + 1;
% end
% 
% XYdata(:,5) = [];

% Write Headers and data 
data = [headers; num2cell(XYdata)];
xlswrite(strcat(filename,'.xlsx'), data);

end

