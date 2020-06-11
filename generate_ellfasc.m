function model = generate_ellfasc(model, elliptical_fascicles, ell)
% GENERATE_ELLFASC  Generate elliptical fascicles geometry
%
% INPUTS
%   * model: COMSOL model;
%   * elliptical_fascicles: elliptical fascicle parameters;
%   * ell: nerve extrusion length.
%
% OUTPUT
%   * model: COMSOL model.
%
% See also FEM_GUI
%
% Author SIMONE ROMENI @TNE, EPFL

geom1 = model.geom('geom1');
fasc_number = size(elliptical_fascicles, 1);
eta = 0.03;
wp3n = geom1.feature.create('wp3n', 'WorkPlane');
wp3n.set('planetype', 'quick');
wp3n.set('quickplane', 'xy');

for i = 1:fasc_number
    % Create a fascicular compartment
    fascaux(i) = wp3n.geom.feature.create(strcat('fascaux', int2str(i)), 'Ellipse');
    fascaux(i).set('x',   elliptical_fascicles(i, 1));
    fascaux(i).set('y',   elliptical_fascicles(i, 2));
    fascaux(i).set('a',   elliptical_fascicles(i, 3));
    fascaux(i).set('b',   elliptical_fascicles(i, 4));
    fascaux(i).set('rot', elliptical_fascicles(i, 5));
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
    a = elliptical_fascicles(i, 3);
    b = elliptical_fascicles(i, 4);
    thick = eta*2*sqrt(a*b);
    % Create an endoneurial compartment
    endoaux(i) = wp4n.geom.feature.create(strcat('endoaux', int2str(i)),'Ellipse');
    endoaux(i).set('x',   elliptical_fascicles(i, 1));
    endoaux(i).set('y',   elliptical_fascicles(i, 2));
    endoaux(i).set('a',   a - thick);
    endoaux(i).set('b',   b - thick);
    endoaux(i).set('rot', elliptical_fascicles(i, 5));
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
