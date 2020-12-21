% Main script for Hybrid Modelling
% Author SIMONE ROMENI @TNE, EPFL

import com.comsol.model.*
import com.comsol.model.util.*

list_elec = {'TIME', 'FINE'};
[indx, tf] = listdlg('PromptString', 'Select an electrode:', ...
                    'SelectionMode', 'single',              ...
                    'ListString', list_elec);
if ~tf
    error('No electrode selected')
end
elec_type = list_elec{indx};

switch elec_type
    case 'TIME'
        dlgtitle = 'Select TIME electrode parameters';
        dims = [ones(8,1), ones(8,1)*50];
        prompt = {'Shaft length [mm]',          ...
                  'Shaft width [mm]',           ...
                  'Shaft height [mm]',          ...
                  'Tip length [mm]',            ...
                  'Tip width [mm]',             ...
                  'Number of active sites [1]', ...
                  'Active site diameter [mm]',  ...
                  'Active site depth [mm]'};
        definput = {'4', '1', '0.3', '1', '0.5', '7', '0.15', '0.1'};

        elec_params = str2double(inputdlg(prompt, dlgtitle, dims, definput));
        elec_params = elec_params.*[1e-3; 1e-3; 1e-3; 1e-3; 1e-3; 1; 1e-3; 1e-3];

        l_shaft = elec_params(1);
        w_shaft = elec_params(2);
        h_shaft = elec_params(3);
        l_tip   = elec_params(4);
        w_tip   = elec_params(5);
        n       = elec_params(6);
        d_as    = elec_params(7);
        h_as    = elec_params(8);
        l_cc    = l_shaft/n;

    case 'FINE'
        dlgtitle = 'Select FINE electrode parameters';
        dims = [ones(7,1), ones(7,1)*50];
        prompt = {'Internal x-length [mm]',     ...
                  'Internal y-length [mm]',     ...
                  'Thickness [mm]',             ...
                  'Extrusion length [mm]',      ...
                  'Number of active sites [1]', ...
                  'Active site diameter [mm]',  ...
                  'Active site depth [mm]'};
        definput = {'6', '6', '1', '2', '7', '0.1', '0.05'};

        elec_params = str2double(inputdlg(prompt, dlgtitle, dims, definput));
        elec_params = elec_params.*[1e-3;1e-3;1e-3;1e-3;1;1e-3;1e-3];

        a    = elec_params(1);
        b    = elec_params(2);
        t    = elec_params(3);
        ell  = elec_params(4);
        n    = elec_params(5);
        d_as = elec_params(6);
        h_as = elec_params(7);
        l_cc = a/(n+1);
end

if strcmp(elec_type, 'FINE')
    ps = questdlg('Paraneurium/saline?', ...
	'Paraneurium', ...
	'Paraneurium','Saline','Saline');
    if strcmp(ps, 'Paraneurium')
        opt = [1, elec_params(1), elec_params(2)];
    else
        opt = [0, elec_params(1), elec_params(2)];
    end
else
    opt = [0, 0, 0];
end

list_modes = {'auto', 'custom circular', 'custom elliptical', 'custom polylinear'};
msg = 'Select a nerve generation mode:';
[indx, tf] = listdlg('PromptString', msg,       ...
                     'SelectionMode', 'single', ...
                     'ListString', list_modes);

if ~tf
    error('No nerve generation mode selected')
end
nerve_genmode = list_modes{indx};

switch nerve_genmode
    case 'auto'
        dlgtitle = 'Select nerve generation parameters';
        dims = [ones(7,1), ones(7,1)*50];
        prompt = {'Number of fascicles [1]',      ...
                  'Fascicle minimum radius [mm]', ...
                  'Fascicle maximum radius [mm]', ...
                  'Nerve external radius [mm]',   ...
                  'delta [mm]',                   ...
                  'epsilon [mm]',                 ...
                  'Nerve extrusion length [mm]'};
        definput = {'10', '0.3', '0.5', '3', '0.05', '0.01', '2'};

        nerve_pars = str2double(inputdlg(prompt, dlgtitle, dims, definput));
        ell = nerve_pars(7)*1e-3;

    case {'custom circular', 'custom elliptical', 'custom polylinear'}
        file_name = uigetfile('*.mat', 'Select a nerve parameter file');
        load(file_name);
end

tic
model = ModelUtil.create('Model');
ModelUtil.showProgress(true);
geom1 = model.geom.create('geom1', 3);
model = generate_ec(model);

% Nerve:
%   * 'auto', 'custom'
%   * if 'auto' only 'circular';
%   * you must choose
%   * if 'custom' choose among 'elliptical' or 'circular'.
% If 'custom circular' the file must contain centers and radii (Nx3)
% If 'custom elliptical' (Nx5)
% If 'auto' [n, rmin, rmax, R, delta, epsilon] (1x6)
% generate_outernerve() generates saline and epineurium
sal_pars = [6*1e-3, 2*1e-3];    % ok for any human nerve
switch nerve_genmode
    case 'auto'
        n_fasc  = nerve_pars(1);
        rmin    = nerve_pars(2)*1e-3;
        rmax    = nerve_pars(3)*1e-3;
        R       = nerve_pars(4)*1e-3;
        delta   = nerve_pars(5)*1e-3;
        epsilon = nerve_pars(6)*1e-3;

        radii = (rmax-rmin)*rand(n_fasc,1) + rmin;
        centers = aci_packing(R, radii, delta, epsilon);
        circular_fascicles = [centers, radii];
        save('nerve_mod.mat', 'R', 'ell', 'circular_fascicles');
        custom = 0;
        model = generate_outernerve(model, elec_type, opt, ell, R, sal_pars, custom);
        model = generate_circfasc(model, [centers, radii], ell);

    case 'custom circular'
        custom = 1;
        model = generate_outernerve(model, elec_type, opt, ell, epineurium, sal_pars, custom);
        model = generate_circfasc(model, circular_fascicles, ell);

    case 'custom elliptical'
        custom = 1;
        model = generate_outernerve(model, elec_type, opt, ell, epineurium, sal_pars, custom);
        model = generate_ellfasc(model, elliptical_fascicles, ell);

    case 'custom polylinear'
        custom = 1;
        model = generate_outernerve(model, elec_type, opt, ell, epineurium, sal_pars, custom);
        model = generate_polyfasc(model, polylinear_fascicles, ell);
end

model = generate_electrode(model, elec_type, elec_params);
mphgeom(model)

% Select boundaries of active site
list_as = {};
definput = {};
for i = 1:2*n
    list_as{end+1} = num2str(i);
    definput{end+1} = '1';
end
[which_as,tf] = listdlg('PromptString', 'Select active sites:',...
                        'ListString', list_as);

dlgtitle = 'Select current for each active site';
dims = [ones(length(which_as),1), ones(length(which_as),1)*50];
prompt = {};

for i = 1:length(which_as)
    prompt{end+1} = strcat('Active site ', num2str(which_as(i)));
end

curr = str2double(inputdlg(prompt, dlgtitle, dims, definput));

for i = 1:length(which_as)
    asnum = which_as(i);
    delta = 0.001*1e-3;
    switch elec_type
        case 'TIME'
            if asnum <= n
                p0 = [-l_cc*(asnum-1) + d_as/2 + delta, ...
                      h_shaft/2 - h_as - delta,         ...
                      -d_as/2 - delta];
                p1 = [-l_cc*(asnum-1) - d_as/2 - delta, ...
                      h_shaft/2 + delta,                ...
                    d_as/2 + delta];
            else
                p0 = [-l_cc*(asnum - n - 1) + d_as/2 + delta,   ...
                      -h_shaft/2 + h_as + delta,                ...
                      -d_as/2 - delta];
                p1 = [-l_cc*(asnum - n - 1) - d_as/2 - delta,   ...
                      -h_shaft/2 - delta,                       ...
                      d_as/2 + delta];
            end
        case 'FINE'
            if asnum <= n
                %p0 = [-a/2 + l_cc*(asnum + 0.5) - d_as/2 - delta,   ...
                p0 = [-a/2 + l_cc*(asnum) - d_as/2 - delta,   ...
                      -b/2 - h_as - delta,                          ...
                      - d_as/2 - delta];
                %p1 = [-a/2 + l_cc*(asnum + 0.5) + d_as/2 + delta,   ...
                p1 = [-a/2 + l_cc*(asnum) + d_as/2 + delta,   ...
                      -b/2 + delta,                                 ...
                      d_as/2 + delta];
            else
                %p0 = [-a/2 + l_cc*(asnum - n + 0.5) - d_as/2 - delta,   ...
                p0 = [-a/2 + l_cc*(asnum - n) - d_as/2 - delta,   ...
                      b/2 + h_as + delta,                               ...
                      -d_as/2 - delta];
                %p1 = [-a/2 + l_cc*(asnum - n + 0.5) + d_as/2 + delta,   ...
                p1 = [-a/2 + l_cc*(asnum - n) + d_as/2 + delta,   ...
                      b/2 - delta,                                      ...
                      d_as/2 + delta];
            end
    end

    %     Decomment if you want a boundary current source %%%%%%%%%%%%%%%%%%%%%%
    %     idx = mphselectbox(model,'geom1',[p0',p1'],'boundary');
    %     model.physics('ec').feature.create(strcat('ncd1',num2str(i)), 'BoundaryCurrentSource', 2);
    %     model.physics('ec').feature(strcat('ncd1',num2str(i))).selection.set(idx);
    %     model.physics('ec').feature(strcat('ncd1',num2str(i))).set('Qjs', curr(i), '1');

    idx = mphselectbox(model,'geom1',[p0',p1'],'domain');
    model.physics('ec').feature.create(strcat('cs1', num2str(i)), 'CurrentSource', 3);
    model.physics('ec').feature(strcat('cs1', num2str(i))).selection.set(idx);
    model.physics('ec').feature(strcat('cs1', num2str(i))).set('Qj', curr(i), '1');
end

%% 8. Add and assign materials
model = generate_materials(model);
model = assign_materials(model);

% Interface nerve and electrode models
if strcmp(elec_type, 'TIME')
    dlgtitle = 'Select insertion parameters';
        dims = [ones(4,1), ones(4,1)*50];
        prompt = {'Leading active site [1]',                ...
                  'Desired x-position of active site [mm]', ...
                  'Desired y-position of active site [mm]', ...
                  'Desired angle of insertion [deg]'};
        definput = {'1', '0', '0', '0'};

        insertion_params = str2double(inputdlg(prompt, dlgtitle, dims, definput));

        asnum = insertion_params(1);
        P(1)  = insertion_params(2)*1e-3;
        P(2)  = insertion_params(3)*1e-3;
        P(3)  = 0;
        theta = insertion_params(4);

        model = interface_nervelec(model, theta, asnum, P, elec_params);
    model.geom('geom1').run;
    mphgeom(model)
end

if strcmp(elec_type, 'FINE')
    eleccopy = geom1.feature.create('eleccopy', 'Copy');
    eleccopy.selection('input').set('elec');

    ascopy = geom1.feature.create('ascopy', 'Copy');
    ascopy.selection('input').set('as');

    nerve = geom1.feature.create('nerve','Difference');
    nerve.selection('input').set({'salgeom','epigeom','perigeom','endogeom'});
    nerve.selection('input2').set({'eleccopy','ascopy'});
end

time_for_settings = toc;

% Mesh
tic
model.mesh.create('mesh1', 'geom1');
model.mesh('mesh1').autoMeshSize(3);
model.mesh('mesh1').run;

% After meshing
stats = mphmeshstats(model);
%if stats.hasproblems
%    error('The meshing operation has problems!')
%end
time_for_meshing = toc;

mphmesh(model)

% Solve
ModelUtil.showProgress(true)

tic
model.study('std1').run;
time_for_solving = toc;
dataref = mpheval(model,{'V'});
