function model = generate_materials(model)
% GENERATE_MATERIALS  Generate materials
%
% See also FEM_GUI
%
% Author SIMONE ROMENI @TNE, EPFL

endo = model.material.create('endo');
endo.name('Endoneurium');
endo.propertyGroup('def').set('relpermittivity', 80); % water
endo.propertyGroup('def').set('electricconductivity',{'0.083', '0', '0', '0', '0.083', '0', '0', '0', '0.571'});

peri = model.material.create('peri');
peri.name('Perineurium');
peri.propertyGroup('def').set('relpermittivity', 80);
peri.propertyGroup('def').set('electricconductivity',0.0009);

epi = model.material.create('epi');
epi.name('Epineurium');
epi.propertyGroup('def').set('relpermittivity', 80);
epi.propertyGroup('def').set('electricconductivity',0.083);

sal = model.material.create('sal');
sal.name('Saline');
sal.propertyGroup('def').set('relpermittivity', 80);
sal.propertyGroup('def').set('electricconductivity',2);

plat = model.material.create('as');
plat.name('Sites');
plat.propertyGroup('def').set('relpermittivity', 1);
plat.propertyGroup('def').set('electricconductivity', 1e6);

poly = model.material.create('elec');
poly.name('Elecshaft');
poly.propertyGroup('def').set('relpermittivity', 1);
poly.propertyGroup('def').set('electricconductivity',1e-6);
