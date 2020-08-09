function [ dataCurveture ] = TrackCurveture( INPUTdata )


NtrackedCell = max(INPUTdata(:,7));
dataCurveture = zeros(NtrackedCell, 2);

for n=1:NtrackedCell    
    % indeces of the nth track
    indx = find(INPUTdata(:,7) == n);
    
    % x and y positions
    DataXY = INPUTdata(indx,1:2);
    x = DataXY(:,1);
    y = DataXY(:,2);
   
    
    % Calculate curveture 
    dx  = gradient(x);
    ddx = gradient(dx);
    dy  = gradient(y);
    ddy = gradient(dy);
    num   = dx .* ddy - ddx .* dy;
    denom = dx .* dx + dy .* dy;
    denom = sqrt(denom);
    denom3 = denom .* denom .* denom;
    curvature = num ./ denom3;
    curvature(denom3 < 0) = NaN;

    dataCurveture(n,1) = sum(abs(curvature))/length(indx);
    dataCurveture(n,2) = n;
end

end

