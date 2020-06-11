function model = generate_circfasc(model, circular_fascicles, ell)
% GENERATE_ELLFASC  Generate elliptical fascicles geometry
%
% INPUTS
%   * model: COMSOL model;
%   * circular_fascicles: circular fascicle parameters;
%   * ell: nerve extrusion length.
%
% OUTPUT
%   * model: COMSOL model.
%
% See also FEM_GUI
%
% Author SIMONE ROMENI @TNE, EPFL

geom1 = model.geom('geom1');
fasc_number = size(circular_fascicles, 1);
fascnames = {};
endonames = {};
for i =1:fasc_number
    % Create a fascicular compartment
    fascaux(i) = geom1.feature.create(strcat('fascaux', int2str(i)), 'Cylinder');
    fascaux(i).set('h', ell);
    fascaux(i).set('x', circular_fascicles(i, 1));
    fascaux(i).set('y', circular_fascicles(i, 2));
    fascaux(i).set('r', circular_fascicles(i, 3));
    fascaux(i).set('z', -ell/2);
    fascnames{end+1} = strcat('fascaux', int2str(i));

    % Create an endoneurial compartment
    endoaux(i) = geom1.feature.create(strcat('endoaux', int2str(i)),'Cylinder');
    endoaux(i).set('h', ell);
    endoaux(i).set('x', circular_fascicles(i, 1));
    endoaux(i).set('y', circular_fascicles(i, 2));
    endoaux(i).set('r', 0.97*circular_fascicles(i, 3));
    endoaux(i).set('z', -ell/2);
    endonames{end+1} = strcat('endoaux',int2str(i));
end

geom1.run;

endogeom = geom1.feature.create('endogeom', 'Union');
endogeom.selection('input').set(endonames);
endogeom.set('createselection','on');

endocopy = geom1.feature.create('endocopy', 'Copy');
endocopy.selection('input').set('endogeom');

fascfull = geom1.feature.create('fascfull', 'Union');
fascfull.selection('input').set(fascnames);

fasccopy = geom1.feature.create('fasccopy', 'Copy');
fasccopy.selection('input').set('fascfull');

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

%figure;
%mphgeom(model)
