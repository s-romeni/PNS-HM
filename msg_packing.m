function object_xy = msg_packing(diam, multiregion, n_steps)
% MSG_PACKING  Multi-scale Square Grid packing of circular objects in a multiregion.
%
% INPUTS
%   * diam: array of object diameters;
%   * multiregion: R-cell array of Nx2 arrays with the vertices of the R polygons;
%   * n_steps: number of grid refinements.
%
% OUTPUT
%   * object_xy: Nx4 array with object center positions, diameters, object IDs.
%
% See also ACTIVATE_CENTERS, ASSIGN_DIAMETERS
%
% Author SIMONE ROMENI @TNE, EPFL

grid_step = max(diam);
centers = activate_centers(grid_step, multiregion);
object_xy = assign_diameters(centers, diam, n_steps);
