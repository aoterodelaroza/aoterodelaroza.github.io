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

#### S22x5 set (S22x5) {#S22x5}

*Systems*: non-covalent binding energies of small molecular dimers. 5 intermolecular distances per dimer.\\
*Level*: CCSD(T)/CBS (same as the [S22](#S22)).\\
*Number*: 22x5=110 dimers.\\
*Source*: [structures](https://github.com/aoterodelaroza/refdata/tree/master/20_s22x5), 
[din](https://github.com/aoterodelaroza/refdata/blob/master/10_din/s22x5.din)\\
*Reference*: [Lucie Gráfová et al., *J. Chem. Theory Comput.* **6** (2010) 2365](https://doi.org/10.1021/ct1002253).\\
See the [S22](#S22) for the reference where the structures at the equilibrium geometries were proposed.

#### S22x7 set (S22x7) {#S22x7}

*Systems*: non-covalent binding energies of small molecular dimers. 7 intermolecular distances per dimer.\\
*Level*: DW-CCSD(T\*\*)-F12/CBS (MP2/a{Q,5}Z + ΔDW-CCSD(T\*\*)-F12/aDZ).\\
*Number*: 22x7=154 dimers.\\
*Source*: [structures](https://github.com/aoterodelaroza/refdata/tree/master/20_s22x7), 
[din](https://github.com/aoterodelaroza/refdata/blob/master/10_din/s22x7.din)\\
*Reference*: [Sherill et al., *J. Phys. Chem. Lett.* **7** (2016) 2197](https://doi.org/10.1021/acs.jpclett.6b00780).\\
See the [S22](#S22) for the reference where the structures at the equilibrium geometries were proposed.\\
*Note*: This is a superset of the S22x5 with 70% and 80% equilibrium intermolecular distances.

#### S66 set (S66) {#S66}

*Systems*: non-covalent binding energies of small molecular dimers of biological importance.\\
*Level*: CCSD(T)/CBS (HF/aQZ + ΔMP2(Helgaker:aTZ/aQZ) + ΔCCSD(T)(aDZ), with counterpoise) 
except for the hydrogen-bonded systems (MP2/aQZ + ΔCCSD(aTZ) + Δ(T)(aDZ), with half-counterpoise).\\
*Number*: 66 dimers.\\
*Source*: [structures](https://github.com/aoterodelaroza/refdata/tree/master/20_s66), 
[din](https://github.com/aoterodelaroza/refdata/blob/master/10_din/s66.din)\\
*Reference*: \\
Structures and original set: [Jan Řezáč et al. *J. Chem. Theory Comput.* **7** (2011) 2427](https://doi.org/10.1021/ct2002946),\\
Corrected reference energies for hydrogen-bonded dimers: [G. A. DiLabio et al. *Phys. Chem. Chem. Phys.* **15** (2013) 12821](https://doi.org/10.1039/C3CP51559A).

#### S66x8 set (S66x8) {#S66x8}

*Systems*: non-covalent binding energies of small molecular dimers of biological importance; 8 intermolecular distances for each dimer.\\
*Level*: CCSD(T)/CBS.\\
*Number*: 66x8=528 dimers.\\
*Source*: [structures](https://github.com/aoterodelaroza/refdata/tree/master/20_s66x8), 
[din](https://github.com/aoterodelaroza/refdata/blob/master/10_din/s66x8.din)\\
*Reference*: 
Structures and original set: [Jan Řezáč et al. *J. Chem. Theory Comput.* **7** (2011) 3466](https://doi.org/10.1021/ct200523a),\\
Revised values: [Brauer et al., *Phys. Chem. Chem. Phys.* **18** (2016) 20905](https://doi.org/10.1039/C6CP00688D).\\
See the [S66](#S66) for the reference where the structures at the equilibrium geometries were proposed.

#### S66x10 set (S66x10) {#S66x10}

*Systems*: non-covalent binding energies of small molecular dimers of biological importance; 10 intermolecular distances for each dimer.\\
*Level*: CCSD(T)/CBS.\\
*Number*: 66x10=660 dimers.\\
*Source*: [structures](https://github.com/aoterodelaroza/refdata/tree/master/20_s66x10), 
[din](https://github.com/aoterodelaroza/refdata/blob/master/10_din/s66x10.din)\\
*Reference*: [Brauer et al., *Phys. Chem. Chem. Phys.* **18** (2016) 20905](https://doi.org/10.1039/C6CP00688D).\\
*Reference*: [Sherill et al., *J. Phys. Chem. Lett.* **7** (2016) 2197](https://doi.org/10.1021/acs.jpclett.6b00780).\\
See the [S66](#S66) for the reference where the structures at the equilibrium geometries were proposed.
*Note*: This is a superset of the S66x8 with 70% and 80% equilibrium intermolecular distances.\\


#### HB375x10 set (HB375x10) {#HB375x10}

*Systems*: dimers with OH, NH, and CH hydrogen bonds, and similar molecules without them; 10 intermolecular distances for each dimer.\\
*Level*: CCSD(T)/CBS (MP2(extrapol. aQZ/a5Z) + ΔCCSD(T)(heavy-aTZ), with counterpoise).\\
*Number*: 375x10 = 3750 dimers.\\
*Source*: [structures](https://github.com/aoterodelaroza/refdata/tree/master/20_hb375x10), 
[din](https://github.com/aoterodelaroza/refdata/blob/master/10_din/hb375x10.din)\\
*Reference*: [Jan Řezáč, *J. Chem. Theory Comput.* **16** (2020) 6305](https://doi.org/10.1039/C3CP51559A).\\
*Note*: this set is part of the [NCI atlas](http://www.nciatlas.org/) by J. Řezáč.

#### iHB100x10 set (iHB100x10) {#iHB100x10}

*Systems*: charged hydrogen-bonded dimers with C, H, N, and O only; 10 intermolecular distances for each dimer.\\
*Level*: CCSD(T)/CBS (MP2(extrapol. aQZ/a5Z) + ΔCCSD(T)(heavy-aTZ), with counterpoise).\\
*Number*: 100x10 = 1000 dimers.\\
*Source*: [structures](https://github.com/aoterodelaroza/refdata/tree/master/20_ihb100x10), 
[din](https://github.com/aoterodelaroza/refdata/blob/master/10_din/ihb100x10.din)\\
*Reference*: [Jan Řezáč, *J. Chem. Theory Comput.* **16** (2020) 6305](https://doi.org/10.1039/C3CP51559A).\\
*Note*: this set is part of the [NCI atlas](http://www.nciatlas.org/) by J. Řezáč.

#### HB300SPX set (HB300SPX) {#HB300SPX}

*Systems*: hydrogen-bonded dimers with S, P, and halogen atoms; 10 intermolecular distances for each dimer.\\
*Level*: CCSD(T)/CBS (MP2(extrapol. aQZ/a5Z) + ΔCCSD(T)(heavy-aTZ), with counterpoise).\\
*Number*: 300x10 = 3000 dimers.\\
*Source*: [structures](https://github.com/aoterodelaroza/refdata/tree/master/20_hb300spx), 
[din](https://github.com/aoterodelaroza/refdata/blob/master/10_din/hb300spx.din)\\
*Reference*: [Jan Řezáč, *J. Chem. Theory Comput.* **16** (2020) 6305](https://doi.org/10.1039/C3CP51559A).\\
*Note*: this set is part of the [NCI atlas](http://www.nciatlas.org/) by J. Řezáč.

