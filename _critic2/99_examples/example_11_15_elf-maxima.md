---
layout: single
title: "Finding and Integrating Maxima of the ELF"
permalink: /critic2/examples/example_11_15_elf-maxima/
excerpt: "Integrating the number of electrons in the basins of the ELF and finding the ELF maxima with YT or BADER"
sidebar:
  - repo: "critic2"
    nav: "critic2_examples"
toc: true
toc_label: "ELF basins and ELF maxima"
---

In this example we will see how to use the basin integration methods
(YT and BADER) to: a) find and visualize the maxima of the electron
localization function (ELF) in solids and molecules, and b) integrate
the electron density in the basins associated to the ELF maxima.

## ELF basins in molecules

We start with a simple example of a molecular calculation. The
following Gaussian input calculates the pyridine molecule using
B3LYP/6-31+G**. We ask Gaussian to generate a wavefunction file (with
extension `.wfx`; the old extension `.wfn` is also accepted by
critic2) containing the converged Kohn-Sham orbitals:
~~~
%nprocs=4
%mem=2GB
#p b3lyp 6-31+G** output=wfx int=(grid=ultrafine)
 
title
 
0 1
N       0.000000 0.000000 1.417497
C       0.000000 0.000000 -1.382528
C       0.000000 1.139575 0.720388
C       0.000000 -1.139575 0.720388
C       0.000000 -1.195555 -0.671305
C       0.000000 1.195555 -0.671305
H       0.000000 0.000000 -2.467674
H       0.000000 2.056798 1.305138
H       0.000000 -2.056798 1.305138
H       0.000000 -2.153584 -1.179452
H       0.000000 2.153584 -1.179452

pyridine.wfx

~~~
Running this input generates a `pyridine.wfx` file that we now use to
calculate the ELF and find its maxima.

The `wfx` file contains both structural information and the exponents
and coefficients for the Kohn-Sham orbitals and the electron
density. We load this information in critic by first reading the
structure:
~~~
molecule pyridine.wfx
~~~
and then loading the same file as a scalar field:
~~~
load pyridine.wfx id wfx
~~~
Using the keyword `id`, we indicate that we are going to refer to this
field using the `wfx` label in the rest of the input.

In order to use YT to find and integrate the maxima of the ELF, we
first need to transform the analytical representation of the
wavefunction into a grid of values. This is done by loading new scalar
fields as transformation of the `wfx` field, with the
[LOAD](/critic2/manual/fields/#c2-load) keyword. For instance, we
define a grid with 150 points in each direction containing the
electron density from the `wfx` file with:
~~~
load as "$wfx" 150 150 150 id rho
~~~
This loads a new field (with identifier `rho`) that is a grid in real
space instead of a sum of Gaussians. We now do the same with the ELF:
~~~
load as "elf(wfx)" sizeof rho id elf
~~~
In this case, the expression `elf(wfx)` has critic2 calculate the ELF
from the data in `wfx` at every point in the grid. Because we used
`sizeof rho`, the new grid will have the same number of points and
dimensions as the `rho` grid. Finally, we attach the identifier `elf`
to it.

These newly created scalar fields can be written to `.cube` files for
later use (in larger systems, it may take a while to generate
them). This is done with the [CUBE](/critic2/manual/graphics/#c2-cube)
keyword:
~~~
cube grid file rho.cube field rho
cube grid file elf.cube field elf
~~~
These two commands write new cube files containing the density
(`rho.cube`) and the ELF (`elf.cube`) represented by the corresponding
fields `rho` and `elf`. The `grid` keyword is used to tell critic to
use the same number of points and grid dimensions as contained in
those fields (it is possible to create smaller or bigger grids using
CUBE as well). Once these cube files have been written, subsequent
runs of the same input can simply start with:
~~~
molecule pyridine.wfx
load rho.cube id rho
load elf.cube id elf
~~~
which avoids having to recalculate the grid values.

To find the ELF maxima with YT, first we declare the `elf` grid as the
reference field:
~~~
reference elf
~~~
then, since we want to calculate the average number of electrons in
each ELF basin, we declare the `rho` field as an integrable quantity:
~~~
integrable rho
~~~
Finally, we run the integration:
~~~
yt nnm discard "$elf < 0.1"
~~~
The ELF has maxima at the bonds, and these maxima are non-nuclear,
since they are not associated to any particular atom. Therefore, we
need to use the `nnm` keyword. In addition, the DISCARD keyword is
used to disregard any maxima whose ELF value is lower than 0.1 (and,
therefore, not associated to any covalent bond or electron
pair). These may appear due to numerical inaccuracies in the
interstitial, and they would simply contaminate the output. The result
of the integration is:
~~~
* Integrated atomic properties
# (See key above for interpretation of column headings.)
# Integrable properties 1 to 3
# Id   cp   ncp   Name  Z   mult       Pop             Lap            $rho
  1    1    1      N1   7   --   1.69040343E-01 -3.36536386E-01  4.23168042E+00
  2    2    2      C2   6   --   3.16018270E-01 -6.60711404E-04  2.06332022E+00
  3    3    3      C3   6   --   3.20914232E-01  2.06364439E-02  2.37972397E+00
  4    4    4      C4   6   --   3.20914232E-01  2.06364439E-02  2.37972397E+00
  5    5    5      C5   6   --   3.19010120E-01 -1.22013954E-02  2.14206761E+00
  6    6    6      C6   6   --   3.19010120E-01 -1.22013954E-02  2.14206761E+00
  7    7    7      H7   1   --   5.34770421E+01 -6.97244745E-02  2.14582136E+00
  8    8    8      H8   1   --   5.26774462E+01 -1.29172804E-01  2.16747255E+00
  9    9    9      H9   1   --   5.26774462E+01 -1.29172804E-01  2.16747255E+00
  10   10   10    H10   1   --   5.21464355E+01 -1.83461044E-01  2.13683564E+00
  11   11   11    H11   1   --   5.21464355E+01 -1.83461044E-01  2.13683564E+00
  12    --   --    ??   --  --   4.87705842E+01  4.30200995E-01  2.78846605E+00
  13    --   --    ??   --  --   2.57120833E+01  4.73765512E-01  2.90356132E+00
  14    --   --    ??   --  --   2.57120833E+01  4.73765512E-01  2.90356132E+00
  15    --   --    ??   --  --   2.09584586E+01  8.29195352E-03  2.71656580E+00
  16    --   --    ??   --  --   2.09584586E+01  8.29195352E-03  2.71656580E+00
  17    --   --    ??   --  --   9.54503695E+00 -1.89498378E-01  2.31494522E+00
  18    --   --    ??   --  --   9.54503695E+00 -1.89498378E-01  2.31494522E+00
--------------------------------------------------------------------------------
  Sum                            4.26091455E+02 -6.92668145E-12  4.47516323E+01
~~~
There are several things to note. First, the column labeled "Pop"
represents the integral of the ELF in its own basins, and therefore
is not a very interesting quantity. The "Lap" field is the integral of
the Laplacian of the ELF; its use is only to make sure that the
integration is giving reasonable values (the integrated Laplacian
should be close to zero). The last column ("$rho") is the integral of
the electron density in the basins of the ELF. Note that the total
integrated number of electrons is 44.7 but should be 42 for this
molecule. This is because grids cannot represent very well the
electron density close to the nuclei. However, the electron
populations in the valence basins, labeled in the output with "??",
should be more or less correct.

YT has determined the position of the maxima and now we would like to
make a graphical representation to find where they are. This is done
using the [CPREPORT](/critic2/manual/cpsearch/#c2-cpreport) keyword:
~~~
cpreport pyridine_elf_basins.cml
~~~
This writes a `.cml` file that can be read by avogadro. The cml file
contains the atoms but also the position of the maxima labeled as
"Xn". To have avogadro understand


** pyridine_elf_basins.cri

From the wfx file for a pyridine molecule, calculate the density and
the ELF in a cube file spanning the molecule, then integrate its
basins and plot the positions of the maxima

** pyridine_elf_colormap.cri

Plot the ELF from the pyridine wfx file on the molecular plane.



## to file

* elf_basins
** Source: Gaussian wfx, abinit, VASP.
** System: gas-phase pyridine, urea molecular crystal, ice-packed graphene bilayer.
** Description

Calculate the ELF and integrate its attractor basins. Three examples
are provided: i) the ELF calculated by critic2 from a Gaussian wfx
file, ii) the integration of the ELF basins in the urea crystal, from the
ELF calculated by abinit, and iii) the integration of the charge
inside the ELF basins in a slab model of a graphene bilayer with
ice between the two layers (icecake).

** urea_crystal_elf_basins.cri

Load the ELF and the density for the urea crystal calculated by
abinit, then integrate the ELF basins and represent the ELF maxima in
a three-dimensional plot.

** icecake.cri

Load the ELF and the density for the ice-filled graphene bilayer
("icecake"). Then, integrate the ELF basins and represent the ELF
maxima in a three-dimensional plot. The spurious ELF maxima in the
vacuum, caused by numerical noise, are discarded using the DISCARD
option to YT. All ELF maxima are found, together with two spurious
maxima that would probably disappear if one used a finer grid.

