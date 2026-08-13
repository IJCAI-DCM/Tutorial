![alt text](https://github.com/IJCAI-DCM/Tutorial/blob/main/code/DCM_workflow.png)
---

### Description of workflow and code files

#### Files:

| Step | Description  | SPM Function | Documentation Link | Code Files |
| ------------- | ------------- | ------------- | ------------- | ------------- |
| 1 | inversion of CMC parameters            | spm_dcm_csd  | [Docs](https://github.com/spm/spm/blob/main/toolbox/dcm_meeg/spm_dcm_csd.m) | ... |
| 2 | group level modelling (PEB)            | spm_dcm_peb  | [Docs](https://github.com/spm/spm/blob/main/spm_dcm_peb.m) | ... |
| 3 | re-estimating 1st level                | spm_dcm_peb_fit  | [Docs](https://github.com/spm/spm/blob/main/spm_dcm_peb_fit.m) | ... |
| 4 | use case for normative priors          | custom | custom | ... |

---



#### Details:
##### 1. DCM inversion for the CMCs (1st level):
- the posteriors are inverted for the canonical microcircuit (CMC) with standard priors to obtain baseline model fits and evidence (free energy)
- variational Laplace (priors with Gaussian form) is used to iteratively update priors to obtain the fit and evidence
- code files: ...
---

##### 2. Parameter optimisation with PEB (2nd level):
- Parametric empirical Bayes (PEB) is used to test hypotheses relating to group data - here receptor densities as regressors - to optimise evidence
- preprocessing: receptor densities (RD) were matched to iEEG locations in MNI space, RD were averaged regionally and across cortical layers
- code files: ...
---
  
##### 3. Use case for normative CMC priors: 
- ...
