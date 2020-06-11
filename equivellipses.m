function ellipses = equivellipses(fascicles)
% EQUIVELLIPSES  Generate ellipses equivalent to given polyshapes
%
% INPUT
%   * fasicles: N-cell array of Knx2 arrays of polyshape vertex
%   coordinates;
%
% OUTPUT
%   * ellipses: Nx5 array of elliptical parameters for the ellipses
%     equivalent to the original fascicles (same area).
%
% See also MINBOUNDRECT, POLY2ELL
%
% Author SIMONE ROMENI @TNE, EPFL

fascnum = length(fascicles);
ellipses = zeros(fascnum,5);
for i = 1:fascnum
    [rectx, recty] = minboundrect(fascicles{i}(:,1), fascicles{i}(:,2),'a');
    rect = [rectx(1:4), recty(1:4)];

    O = [sum(rect(:,1))/4, (sum(rect(:,2))/4)];
    a = sqrt(sum((rect(1,:)-rect(2,:)).^2))/2;
    b = sqrt(sum((rect(2,:)-rect(3,:)).^2))/2;
    alpha = atan2((rect(2,2)-rect(1,2)),(rect(2,1)-rect(1,1)));
    A = polyarea(fascicles{i}(:,1), fascicles{i}(:,2));

    ellipses(i,1:2) = O;
    ellipses(i,3) = sqrt((a*A)/(b*pi));
    ellipses(i,4) = sqrt((b*A)/(a*pi));
    ellipses(i,5) = alpha;
end
