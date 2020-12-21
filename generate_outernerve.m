function model = generate_outernerve(model, type, opt, ell, epineurium, sal_pars, custom)
% GENERATE_OUTERNERVE  Generate saline bath and epineurium
%
% INPUTS
%   * model: COMSOL model;
%   * type: electrode type;
%   * opt: (only for type == 'FINE') parameters of interface with FINE
%   * ell: nerve extrusion length;
%   * epineurium: Kx2 epineurium polyshape if custom, radius of epineurium if not custom;
%   * sal_pars: geometry of saline bath;
%   * custom: 1 if the geometry is custom, 0 otherwise
%
% OUTPUT
%   * model: COMSOL model.
%
% See also FEM_GUI
%
% Author SIMONE ROMENI @TNE, EPFL

geom1 = model.geom('geom1');
Rs = sal_pars(1);
topbot = 2*sal_pars(2);

salfull = geom1.feature.create('salfull','Cylinder');
salfull.set('h', ell+topbot);
salfull.set('r', Rs);
salfull.set('pos', [0,0,-(ell+topbot)/2]);

% Ground saline bath external boundaries
delta = 0.001*1e-3;
p0 = [Rs, Rs, (ell+topbot)/2] + delta;
p1 = [-delta, -delta, -(ell+topbot)/2-delta];
idx = mphselectbox(model,'geom1',[p0',p1'],'boundary');
model.physics('ec').feature.create('gnd11', 'Ground', 2);
model.physics('ec').feature('gnd11').selection.set(idx);

p0 = [-Rs-delta, Rs+delta, (ell+topbot)/2+delta];
p1 = [+delta, -delta, -(ell+topbot)/2-delta];
idx = mphselectbox(model,'geom1',[p0',p1'],'boundary');
model.physics('ec').feature.create('gnd01', 'Ground', 2);
model.physics('ec').feature('gnd01').selection.set(idx);

p0 = [Rs+delta, -Rs-delta, (ell+topbot)/2+delta];
p1 = [-delta, +delta, -(ell+topbot)/2-delta];
idx = mphselectbox(model,'geom1',[p0',p1'],'boundary');
model.physics('ec').feature.create('gnd10', 'Ground', 2);
model.physics('ec').feature('gnd10').selection.set(idx);

p0 = [-Rs-delta, -Rs-delta, (ell+topbot)/2+delta];
p1 = [delta, delta, -(ell+topbot)/2-delta];
idx = mphselectbox(model,'geom1',[p0',p1'],'boundary');
model.physics('ec').feature.create('gnd00', 'Ground', 2);
model.physics('ec').feature('gnd00').selection.set(idx);

% Generate epineurium
switch type
    case 'TIME'
        % Generate epineurium
        if custom
            wpepi = geom1.feature.create('wpepi', 'WorkPlane');
            wpepi.set('planetype', 'quick');
            wpepi.set('quickplane', 'xy');
            wpepi.set('quickz', -ell/2)

            epiaux = wpepi.geom.feature.create('epiaux', 'Polygon');
            epiaux.set('type', 'solid');
            epiaux.set('x', epineurium(:,1));
            epiaux.set('y', epineurium(:,2));

            geom1.run('wpepi');

            epifull = geom1.feature.create('epifull', 'Extrude');
            epifull.set('distance', ell);
        else
            epifull = geom1.feature.create('epifull','Cylinder');
            epifull.set('h',ell);
            epifull.set('r', epineurium);
            epifull.set('pos', [0,0,-ell/2])
        end

    case 'FINE'
        has_para = opt(1);
        a = opt(2);
        b = opt(3);


        switch has_para
            case 1
                wp1n = geom1.feature.create('wp1n', 'WorkPlane');
                wp1n.set('planetype', 'quick');
                wp1n.set('quickplane', 'xy');
                wp1n.set('quickz', -ell/2)

                epirect = wp1n.geom.feature.create('epirect','Rectangle');
                epirect.set('base','center');
                epirect.set('lx',a);
                epirect.set('ly',b);

                geom1.run('wp1n');

                epifull = geom1.feature.create('epifull','Extrude');
                epifull.set('distance',ell);

                geom1.run;

            case 0
                if custom
                    wpepi = geom1.feature.create('wpepi', 'WorkPlane');
                    wpepi.set('planetype', 'quick');
                    wpepi.set('quickplane', 'xy');
                    wpepi.set('quickz', -ell/2)

                    epiaux = wpepi.geom.feature.create('epiaux', 'Polygon');
                    epiaux.set('type', 'solid');
                    epiaux.set('x', epineurium(:,1));
                    epiaux.set('y', epineurium(:,2));

                    geom1.run('wpepi');

                    epifull = geom1.feature.create('epifull', 'Extrude');
                    epifull.set('distance', ell);
                else
                    epifull = geom1.feature.create('epifull', 'Cylinder');
                    epifull.set('h', ell);
                    epifull.set('r', epineurium);
                    epifull.set('pos', [0,0,-ell/2]);
                end

        end
end
epifullcopy = geom1.feature.create('epifullcopy','Copy');
epifullcopy.selection('input').set('epifull');

geom1.run;

salgeom = geom1.feature.create('salgeom','Difference');
salgeom.selection('input').set('salfull');
salgeom.selection('input2').set('epifullcopy');
salgeom.set('createselection','on');
