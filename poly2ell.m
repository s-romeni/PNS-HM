function ellfascicles = poly2ell(fascicles, eta, delta)
% POLY2ELL  Approximate polyshape fascicles with elliptical fascicles
%
% INPUTS
%   * fascicles: N-cell array of Knx2 arrays of polyshape vertex
%   coordinates;
%   * eta: shrinking factor for intersecting fascicles;
%   * delta: minimum distance between fascicles.
%
% OUTPUTS
%   * circfascicles: Nx5 array of elliptical fascicle parameters.
%       . columns 1:2 contain the center coordinates,
%       . columns 3:4 contain the major and minor axis lengths,
%       . column 5 contains the orientation of the major axis.
%
% See also EQUIVELLIPSES, ELLSHAPE, POLY2CIRC
%
% Author SIMONE ROMENI @TNE, EPFL

%% Inizialization
fascnum = length(fascicles); % Number of fascicles
ellfascicles = equivellipse(fascicles);

%% Check for intersections with tolerance delta
intersect = zeros(fascnum,fascnum);
ellfascicles_exp = ellfascicles + repmat([0, 0, delta, delta, 0]/2, fascnum, 1);
for i = 1:fascnum
    for j = i+1:fascnum
        c2c = sqrt(sum((ellfascicles(i,1:2)-ellfascicles(j,1:2)).^2));
        if c2c >= (max(ellfascicles(i,3:4)) + max(ellfascicles(j,3:4)) + delta)
            % if they are too far away, they have null interception
            intersect(i,j) = 0;
        else
            % check intersection between expanded ellipses
            intersect(i,j) = overlaps(ellshape(ellfascicles_exp(i,:)), ellshape(ellfascicles_exp(j,:)));
        end
    end
end

while sum(sum(intersect))
    %% Shrink a random intersecting fascicle
    [row, col] = find(intersect);
    ind = randi(length(row));
    i_sel = row(ind);
    j_sel = col(ind);
    ellfascicles(i_sel,3:4) = (1-eta)*ellfascicles(i_sel,3:4);
    ellfascicles(j_sel,3:4) = (1-eta)*ellfascicles(j_sel,3:4);

    %% Check for intersections
    intersect = zeros(fascnum,fascnum);
    ellfascicles_exp = ellfascicles + repmat([0, 0, delta, delta, 0]/2, fascnum, 1);
    for i = 1:fascnum
        for j = i+1:fascnum
            c2c = sqrt(sum((ellfascicles(i,1:2)-ellfascicles(j,1:2)).^2));
            if c2c >= (max(ellfascicles(i,3:4)) + max(ellfascicles(j,3:4)) + delta)
                % if they are too far away, they have null interception
                intersect(i,j) = 0;
            else
                % check intersection between expanded ellipses
                intersect(i,j) = overlaps(ellshape(ellfascicles_exp(i,:)), ellshape(ellfascicles_exp(j,:)));
            end
        end
    end
end
