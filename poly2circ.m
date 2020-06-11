function circfascicles = poly2circ(fascicles, eta, delta)
% POLY2CIRC  Approximate polyshape fascicles with circular fascicles
%
% INPUTS
%   * fascicles: N-cell array of Knx2 arrays of polyshape vertex
%   coordinates;
%   * eta: shrinking factor for intersecting fascicles;
%   * delta: minimum distance between fascicles.
%
% OUTPUTS
%   * circfascicles: Nx3 array of circular fascicle parameters.
%       . columns 1:2 contain the center coordinates,
%       . column 3 contains the diameters.
%
% See also POLY2ELL
%
% Author SIMONE ROMENI @TNE, EPFL

% Initialization
fascnum = size(fascicles,2);
radii = zeros(fascnum,1);
centers = zeros(fascnum,2);

%% Polyshape to equivalent circles
for i = 1:fascnum
    p = polyshape(fascicles{1,i}(:,1), fascicles{1,i}(:,2));
    A = polyarea(fascicles{1,i}(:,1), fascicles{1,i}(:,2));
    radii(i) = 2*sqrt(A/pi);
    [centers(i,1), centers(i,2)] = centroid(p);
end

%% Check for intersections
intersect = zeros(fascnum, fascnum);
for i = 1:fascnum
    for j = (i+1):fascnum
        d = sqrt(sum((centers(i,:)-centers(j,:)).^2));
        intersect(i,j) = (radii(i) + radii(j)) > 2*d;
    end
end
count = 0;

while sum(sum(intersect))
    %% Shrink a random intersecting fascicle
    count = count + 1;
    [row, col] = find(intersect);
    ind = randi(length(row));
    i_sel = row(ind);
    j_sel = col(ind);
    radii(i_sel) = (1-eta)*radii(i_sel);
    radii(j_sel) = (1-eta)*radii(j_sel);

    %% Check for intersections
    intersect = zeros(fascnum, fascnum);
    for i = 1:fascnum
        for j = (i+1):fascnum
            d = sqrt(sum((centers(i,:)-centers(j,:)).^2));
            intersect(i,j) = radii(i) + radii(j) + delta > d;
        end
    end
end
circfascicles = [centers, radii];
