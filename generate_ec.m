function model = generate_ec(model)
%This function sets up the phsical interface ec (as a Conductive Media) and
%saves within std1 the type of solver that will be used
model.physics.create('ec', 'ConductiveMedia', 'geom1');

model.study.create('std1');
model.study('std1').feature.create('stat', 'Stationary');
model.study('std1').feature('stat').set('sweeptype', 'sparse');
model.study('std1').feature('stat').set('plistarr_vector_start', {});
model.study('std1').feature('stat').set('usesol', 'off');
model.study('std1').feature('stat').set('constraintgroup', {});
model.study('std1').feature('stat').set('plot', 'off');
model.study('std1').feature('stat').set('adaption', 'off');
model.study('std1').feature('stat').set('notstudy', 'zero');
model.study('std1').feature('stat').set('plistarr', {});
model.study('std1').feature('stat').set('notsolnum', '1');
model.study('std1').feature('stat').set('plistarr_vector_numvalues', {});
model.study('std1').feature('stat').set('plist', '');
model.study('std1').feature('stat').set('nottimeinterp', 'off');
model.study('std1').feature('stat').set('useloadcase', 'off');
model.study('std1').feature('stat').set('loadgroup', {});
model.study('std1').feature('stat').set('useparam', 'off');
model.study('std1').feature('stat').set('plistarr_vector_step', {});
model.study('std1').feature('stat').set('plistarr_vector_function', {});
model.study('std1').feature('stat').set('notsolmethod', 'init');
model.study('std1').feature('stat').set('plistarr_vector_method', {});
model.study('std1').feature('stat').set('optimization', false);
model.study('std1').feature('stat').set('geometricNonlinearity', false);
model.study('std1').feature('stat').set('nott', '0');
model.study('std1').feature('stat').set('loadgroupweight', {});
model.study('std1').feature('stat').set('probesel', 'all');
model.study('std1').feature('stat').set('loadcase', {});
model.study('std1').feature('stat').set('notsolvertype', 'none');
model.study('std1').feature('stat').set('geometricNonlinearityActive', true);
model.study('std1').feature('stat').set('plistarr_vector_stop', {});
model.study('std1').feature('stat').set('pname', {});
model.study('std1').feature('stat').set('showGeometricNonlinearity', 'on');
model.study('std1').feature('stat').activate('ec', true);