function centers = aci_packing(R, r, delta, epsilon)
% ACI_PACKING  A-priori Check for Intersections packing of circular objects
% in a circular region.
%
% INPUTS
%   * R: radius of the region to be packed;
%   * r: array of radii of objects to be packed;
%   * delta: minimum spacing between packed objects;
%   * epsilon: number of grid refinements.
%
% OUTPUT
%   * centers: Nx2 array with object center positions.
%
% Author SIMONE ROMENI @TNE, EPFL

n = length(r);
xmin = -R; xmax = R; ymin = -R; ymax = R;
x = xmin:epsilon:xmax;
y = ymin:epsilon:ymax;
[x,y] = meshgrid(x,y);
% count = 0;
% maxcount = 10;
centers = zeros(n,2);
for i = 1:n
    sel = x.^2 + y.^2 < (R-r(i)-delta)^2;
    for j = 1:i-1
        sel = sel & ((x-centers(j,1)).^2 + (y-centers(j,2)).^2 > (r(j)+r(i)+delta)^2);
    end

% Try packing maxcount times
%     if ~sum(sum(selaux))
%         warning('Packing interrupted!')
%         count = count + 1;
%         if count >= maxcount
%             error('No try went well...')
%         end
%     end

[row,col] = find(sel);
nrand = randi(length(row));
centers(i,:) = [x(row(nrand),col(nrand)),y(row(nrand),col(nrand))];
end
end
