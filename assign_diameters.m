function object_xy = assign_diameters(centers, diam, n_steps)
% ASSIGN_DIAMETERS  Locate objects in a refining square grid.
%
% INPUTS
%   * centers: initially available center positions;
%   * diam: array of object diameters;
%   * n_steps: number of grid refinements.
%
% OUTPUT
%   * object_xy: Nx4 array with object center positions, diameters, object IDs.
%
% Author SIMONE ROMENI @TNE, EPFL

%% Initialization
n_centers = size(centers, 1);
L = max(diam);    % grid step
object_xy = [];

% Add fiber IDs to maintained labelled line through the process
diam_id = (1:length(diam))';
diam = [diam, diam_id];

%% Iteration
for iter = 1:n_steps
    L = L/2;
    % Select diameters
    idx_diamsel = diam(:, 1) >= L;
    diam_sel = diam(idx_diamsel, :);
    n_selfibers = size(diam_sel, 1);

    % Defines an array of zeros with a row for each available center, then
    % assigns the selected diameters to random centers
    assigned_diams = zeros(n_centers, 2);
    assigned_diams(randperm(n_centers, n_selfibers), :) = diam_sel;

    % The rows with non-zero first-column elements denote occupied centers
    idx_centersel = assigned_diams(:, 1) ~= 0;

    new_xy = [centers(idx_centersel, :), assigned_diams(idx_centersel, :)];
    object_xy = [object_xy; new_xy];

    % Remove assigned center locations and diameters
    diam(idx_diamsel, :) = [];
    centers(idx_centersel, :) = [];
    n_centers = size(centers, 1);

    % Generate next-step grid
    centerdisplace = [L/2 L/2; L/2 -L/2; -L/2 L/2; -L/2 -L/2];
    for i = 1:n_centers
        centers_aux((4*i-3):(4*i), :) = repmat(centers(i, :), 4, 1) + centerdisplace;
    end
    centers = centers_aux;
    n_centers = size(centers, 1);
end

%% All fibers not yet considered
assigned_diams = zeros(n_centers, 2);
assigned_diams(randperm(n_centers, size(diam, 1)), :) = diam;

idx_centersel = assigned_diams(:, 1) ~= 0;

new_xy = [centers(idx_centersel, :), assigned_diams(idx_centersel, :)];
object_xy = [object_xy; new_xy];
