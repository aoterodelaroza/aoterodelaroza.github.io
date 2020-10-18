---
layout: single
title: "Reference data"
permalink: /refdata/
excerpt: >-
  Repository of reference data for quantum chemistry.
sidebar:
  - repo: "refdata"
    nav: "refdata" 
search: true
toc: true
toc_label: "Reference data"
toc_sticky: true
---

### Non-covalent interactions

#### Kannemann and Becke Set (KB49, KB65) {#KB65}

*Systems*: non-covalent binding energies of small molecular dimers.\\
*Level*: mixed (see the [data page](/refdata/nci/kb/) for level and references).\\
*Number*: 65 including noble-gas dimers, 49 without.\\
*Source*: 
[structures (KB65)](https://github.com/aoterodelaroza/refdata/tree/master/20_kb65), 
[din (KB65)](https://github.com/aoterodelaroza/refdata/blob/master/10_din/kb65.din), 
[structures (KB49)](https://github.com/aoterodelaroza/refdata/tree/master/20_kb49), 
[din (KB49)](https://github.com/aoterodelaroza/refdata/blob/master/10_din/kb49.din)\\
*Reference*: [Kannemann and Becke, *J. Chem. Theory Comput.* **6** (2010) 1081](http://dx.doi.org/10.1021/ct900699r)

#### Two-body and Three-body Interaction Energies (3B69) {#x3B69}

*Systems*: non-covalent two-body and three-body interaction energies of trimers from molecular crystal structures.\\
*Level*: CCSD(T)/CBS (HF=aQZ, MP2=aTZ, CC=aDZ).\\
*Number*: 69 trimers, 207 dimers.\\
*Source*: [structures](https://github.com/aoterodelaroza/refdata/tree/master/20_3b69), 
[din (trimer CCSD(T))](https://github.com/aoterodelaroza/refdata/blob/master/10_din/3b69-ccsd_t.din), 
[din (force field dispersion three-body)](https://github.com/aoterodelaroza/refdata/blob/master/10_din/3b69-ffdisp.din), 
[din (trimer HF)](https://github.com/aoterodelaroza/refdata/blob/master/10_din/3b69-hf.din), 
[din (trimer MP2)](https://github.com/aoterodelaroza/refdata/blob/master/10_din/3b69-mp2.din), 
[din (dimer CCSD(T))](https://github.com/aoterodelaroza/refdata/blob/master/10_din/3b69-dimers-ccsd_t.din)\\
*Reference*: [Jan Řezáč et al., *J. Chem. Theory Comput.* **11** (2015) 3065](https://doi.org/10.1021/acs.jctc.5b00281)

#### S22 set (S22) {#S22}

*Systems*: non-covalent binding energies of small molecular dimers.\\
*Level*: CCSD(T)/CBS (see the [KB data page](/refdata/nci/kb/) for details).\\
*Number*: 22 dimers.\\
*Source*: [structures](https://github.com/aoterodelaroza/refdata/tree/master/20_s22), 
[din](https://github.com/aoterodelaroza/refdata/blob/master/10_din/s22.din)\\
*Reference*: \\
Structures and original set: [Jurecka et al., *Phys. Chem. Chem. Phys.* **8** (2006) 1985](https://doi.org/10.1039/B600027D),\\
Revised values: [Marshall et al., *J. Chem. Phys.* **135** (2011) 194102](https://doi.org/10.1063/1.3659142).
