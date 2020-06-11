function centers = activate_centers(grid_step, multiregion)
% ACTIVATE_CENTERS  Find grid centers inside the polygonal multiregion under analysis.
%
% INPUTS
%   * grid_step: grid step;
%   * multiregion: R-cell array of Nx2 arrays with the vertices of the R polygons.
%
% OUTPUT
%   * centers: Kx2 active center coordinates (K initially unknown).
%
% Author SIMONE ROMENI @TNE, EPFL

%% STEP 1
% Obtain a grid with step grid_step containing all polygons in multiregion
xc = [];
yc = [];

x_max = -Inf;
y_max = -Inf;
x_min = Inf;
y_min = Inf;

for i = 1:length(multiregion)
    temp_xmax = max(multiregion{i}(:,1));
    temp_xmin = min(multiregion{i}(:,1));
    temp_ymax = max(multiregion{i}(:,2));
    temp_ymin = min(multiregion{i}(:,2));

    if temp_xmax > x_max
        x_max = temp_xmax;
    end
    if temp_ymax > y_max
        y_max = temp_ymax;
    end
    if temp_xmin < x_min
        x_min = temp_xmin;
    end
    if temp_ymin < y_min
        y_min = temp_ymin;
    end
end

x = x_min:grid_step:(x_max+grid_step);
y = y_min:grid_step:(y_max+grid_step);
[X,Y] = meshgrid(x,y);

%% STEP 2
% Return only grid centers whose cell is completely inside a polygon
npol = length(multiregion);
for k = 1:npol
    state{k} = inpolygon(X,Y,multiregion{k}(:,1),multiregion{k}(:,2));
end

for k = 1:npol
    for i = 1:length(y)-1
        for j = 1:length(x)-1
            % If all the vertices a square is inside one polygon,
            % then its center is an admissible center
            if (state{k}(i,j) && state{k}(i,j+1) && state{k}(i+1,j) && state{k}(i+1,j+1))
                xc = [xc,(X(i,j)+X(i,j+1))/2];
                yc = [yc,(Y(i,j)+Y(i+1,j))/2];
            end
        end
    end
end

centers = [xc', yc'];
