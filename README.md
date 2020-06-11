# README
## Info
Repository for the article:

S. Romeni, G. Valle, A. Mazzoni, and S. Micera. **Tutorial: A computational framework for the design and optimization of peripheral neural interfaces**. *Nature Protocols*, 2020

Code by Simone Romeni, Ph.D. Assistant at *Bertarelli Foundation Chair in Translational NeuroEngineering, Center for Neuroprosthetics and Institute of Bioengineering, École Polytechnique Fédérale de Lausanne (EPFL), Lausanne, Switzerland*

## Contents
**Function classification**
* Fascicle shape simplification:
  * main functions: `poly2ell.m`, `poly2circ.m`;
  * auxiliary functions: `equivellipses.m`;
  * external functions: `minboundrect.m`.
* Fibre and fascicle packing:
  * main functions: `msg_packing.m`, `aci_packing.m`;
  * auxiliary functions: `activate_centers.m`, `assign_diameters.m`
* FEM modelling:
  * main function: `fem_gui.m`;
  * auxiliary functions: `assign_materials.m`, `generate_circfasc.m`, `generate_ec.m`, `generate_electrode.m`, `generate_ellfasc.m`, `generate_materials.m`, `generate_outernerve.m`, `interface_nervelec.m`.

**Main function docstrings**
* Fascicle shape simplification:
  * `poly2ell.m` Approximate polyshape fascicles with elliptical fascicles;
  * `poly2circ.m` Approximate polyshape fascicles with circular fascicles.
* Fibre and fascicle packing:
  * `msg_packing.m` Multi-scale Square Grid packing of circular objects in a multiregion;
  * `aci_packing.m` A-priori Check for Intersections packing of circular objects in a circular region.

**Fascicle representation conventions**
* **Polylinear fascicles** are represented by an N-cell array, where N is the number of fascicles, whose elements are Knx2 arrays, where Kn is the number of points defining fascicle n and the columns represent x and y coordinates of the points, respectively.
* **Elliptical fascicles** are represented by an array with shape Nx5, where N is the number of fascicles and the columns represent: x and y coordinates of the center, x and y half-axis lengths, orientation of the x axis.
* **Circular fascicles** are represented by an array with shape Nx3, where N is the number of fascicles and the columns represent: x and y coordinates of the center, radius of the fascicle.

## Code from other locations
* [PyPNS repository](https://github.com/chlubba/PyPNS);
* [MRG02 myelinated fibre model](https://senselab.med.yale.edu/modeldb/showModel.cshtml?model=3810&file=/MRGaxon/#tabs-2);
* [Gaines myelinated fibre models](https://senselab.med.yale.edu/ModelDB/showmodel.cshtml?model=243841#tabs-2);
* [Sundt unmyelinated fibre model](https://senselab.med.yale.edu/ModelDB/showmodel.cshtml?model=187473#tabs-2).
* [Code from Gaillet's Hybrid Modelling](https://github.com/lne-lab/nBME2019)
