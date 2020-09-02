---
layout: single
title: "Interpolation of Satellite Data"
permalink: /gibbs2/manual/interpolation/
excerpt: "Interpolation of Satellite Data."
sidebar:
  - repo: "gibbs2"
    nav: "gibbs2_manual"
toc: false
toc_label: "Interpolation of Satellite Data"
toc_sticky: true
---

~~~
PHASE ... [INTERPOLATE f1.i [f2.i ...]]
~~~
In the definition of a phase, it is possible to declare satellite data
(e.g. internal atomic coordinates, cell parameters,...) using the
optional INTERPOLATE keyword. The `f1.i`, `f2.i`, etc. integers are
the columns in the external data file that contain the data to be
interpolated. 

The points at which the satellite data are interpolated can be
specified with the global INTERPOLATE keyword:
~~~
INTERPOLATE
 [P]
 p1.r p2.r ..
 p3.r ..
 V
 v1.r v2.r ..
 PT
 p1.r t1.r p2.r t2.r ...
ENDINTERPOLATE
~~~
The values at which the interpolation takes place are enclosed in a
INTERPOLATE...ENDINTERPOLATE environment. If P is used as the first
line in the INTERPOLATE environment, then the values (p1, p2, ...) are
interpreted as static pressures. If V is used, then the values are
interpreted as volumes. Lastly, if PT is used, values are read in
pairs: first the pressure and then the temperature. 

Interpolation can also be applied using the command:
~~~
INTERPOLATE INPUT [STATIC]
~~~
When the INPUT keyword is used, the pressure and temperature range
used in the calculation of thermodynamic properties is also used for
the interpolation. If the additional STATIC keyword is used, use the
volumes of the static energy-volume grid.

The number of points in the energy-volume grid can be increased using
the optional PHASE keyword:
~~~
PHASE ... EXTEND
~~~
Each phase has a maximum calculable pressure, determined by the slope
of the energy-volume curve at the first (smallest) volume. If the
maximum pressure of any phase is smaller than the requested pressure
range, then the pressure range is automatically reduced. In some
cases, this behavior is undesirable. A phase with the EXTEND
keyword will not reduce the user-input pressure range.

