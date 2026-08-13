### Description of data files

#### Files:
1. iEEG sample files: e.g. Cuneus_W.edf, Cuneus_T001_GD042Rs1W.dat / .mat ([>> Source](https://mni-open-ieegatlas.research.mcgill.ca/), Frauscher et al. 2018)
2.  receptor densities: "receptor_densities.xls" ([>> Source](https://www.frontiersin.org/journals/neuroanatomy/articles/10.3389/fnana.2017.00078/full#supplementaryMaterial), Zilles and Palomero-Gallagher, 2017)
3. summary file: "D_seeg_table_PCA_win4PC_1stLev.xls" ([>> Source](https://onlinelibrary.wiley.com/doi/full/10.1002/hbm.70393), Stoof et al. 2025)
4. DCM CMC examples: e.g., "DCM_Cuneus_T001_GD042Rs1W.mat" ([>> Source](https://onlinelibrary.wiley.com/doi/full/10.1002/hbm.70393), Stoof et al. 2025)
---

#### Details:
##### 1. intracranial EEG:
- the iEEG data sample is part of the Open iEEG Atlas, accessible via the Loris platform of the Montreal Neurological Institute (MNI)
- the atlas contains ca. 1800 traces of 60s lengths, collected from putatively non-pathological tissue under standardised conditions (resting wakefulness EEG with eyes closed)
- .edf and .mat / .dat sample files for the cuneus region are included for testing the code / workflow
- raw: Cuneus_W.edf, data formated in the European Data Format (EDF) standard for medical time series
- SPM: Cuneus_T001_GD042Rs1W.dat / .mat, data converted to an SPM M/EEG object: .dat includes the timeseries, .mat the object description
---

##### 2. neurotransmitter receptor densities:
- the receptor densities (RD) were derived using post-mortem autoradiography on the entire brains of three donors (Jülich Forschungszentrum, then part of the Human Brain Project)
- 15 RDs in 3 strata of different neurotransmitter systems were collected (GABA, Glu (glutamate), ACh (acetylcholine), NA (noradrenaline), DA (dopamine), 5-HT (serotonin))
- raw: receptor_densities.xls contains the formatted data extracted from the supplementary table 2 of Zilles and Palomero-Gallagher (2017)
---
  
##### 3. summary file (iEEG assigned RD, normative CMC priors):
- the file contains processed data from our study (Stoof et al. 2025) to make the use of both the RD and derived normative CMC parameters easier; the normative CMC priors were shown to be effective to guide the variational inference towards better solution (avoid local optima in the evidence landscape) (please use the priors in the .xls)
- included:
  - iEEG names, MNI location, adjusted MNI location, assigned receptor density label (as iEEG and RD data had diff. regions and coordinate systems)
  - iEEG assigned 15 RD which were determined by the cortical region (RD were averaged within a region and over cortical layers)
  - 1st level DCM CMC parameters which were inverted using a single (non-connected) CMC for each iEEG trace
  - principal components (PC) as a lower-dimensional embedding of the RD data to capture variability and reduce complexity
  - 2nd level (PEB) CMC coupling parameters posteriors (after group-level estimation) and priors (after re-estimation > to be used) 
---
  
##### 4. DCM CMC examples:
- these files are examples for the estimated DCM CMC model for the two cuneus traces in the frequency domain
- the DCM object is a matlab structure ([>> description](https://github.com/spm/spm/blob/main/spm_dcm_estimate.m)), and following fields should be highlighted: 

| Description  | Field |
| ------------- | ------------- |
| observed power spectral density (PSD) (input)      | DCM.xY.y  |
| estimated (model fit) for PSD (output)            | DCM.Hc  |
| model priors                                      | DCM.M.pE, DCM.M.pC  |
| model posteriors                                  | DCM.Ep, DCM.Cp  |
| model evidence                                    | DCM.F  |

  
