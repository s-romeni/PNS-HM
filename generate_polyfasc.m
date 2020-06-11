function model = generate_polyfasc(model, polylinear_fascicles, ell)
% GENERATE_POLYFASC  Generate polylinear fascicles geometry
%
% INPUTS
%   * model: COMSOL model;
%   * polylinear_fascicles: polylinear fascicles;
%   * ell: nerve extrusion length.
%
% OUTPUT
%   * model: COMSOL model.
%
% See also FEM_GUI
%
% Author SIMONE ROMENI @TNE, EPFL

geom1 = model.geom('geom1');
fasc_number = size(polylinear_fascicles, 1);
perifasc = polylinear_fascicles.perifasc;
endofasc = polylinear_fascicles.endofasc;

wp3n = geom1.feature.create('wp3n', 'WorkPlane');
wp3n.set('planetype', 'quick');
wp3n.set('quickplane', 'xy');

for i = 1:fasc_number
    % Create a fascicular compartment
    fascaux(i) = wp3n.geom.feature.create(strcat('fascaux', int2str(i)), 'Polygon');
    fascaux(i).set('type', 'solid');
    fascaux(i).set('x', perifasc{i}(:,1));
    fascaux(i).set('y', perifasc{i}(:,2));
end
geom1.run('wp3n');

fascfull = geom1.feature.create('fascfull', 'Extrude');
fascfull.set('distance',ell);

fasccopy = geom1.feature.create('fasccopy', 'Copy');
fasccopy.selection('input').set('fascfull');

wp4n = geom1.feature.create('wp4n', 'WorkPlane');
wp4n.set('planetype', 'quick');
wp4n.set('quickplane', 'xy');
for i = 1:fasc_number
    % Create an endoneurial compartment
    endoaux(i) = wp4n.geom.feature.create(strcat('endoaux', int2str(i)),'Polygon');
    endoaux(i).set('type', 'solid');
    endoaux(i).set('x', endofasc{i}(:,1));
    endoaux(i).set('y', endofasc{i}(:,2));
end
geom1.run('wp4n');

endogeom = geom1.feature.create('endogeom', 'Extrude');
endogeom.set('distance',ell);
endogeom.set('createselection','on');

endocopy = geom1.feature.create('endocopy', 'Copy');
endocopy.selection('input').set('endogeom');

geom1.run;

epigeom = geom1.feature.create('epigeom','Difference');
epigeom.selection('input').set('epifull');
epigeom.selection('input2').set('fasccopy');
epigeom.set('createselection','on');

geom1.run;

perigeom = geom1.feature.create('perigeom','Difference');
perigeom.selection('input').set('fascfull');
perigeom.selection('input2').set('endocopy');
perigeom.set('createselection','on');

geom1.run;
