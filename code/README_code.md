![alt text](https://github.com/IJCAI-DCM/Tutorial/blob/main/code/DCM_workflow.png)
---

### Description of workflow and code files

#### Files:

| Step | Description  | SPM Function | Documentation Link | Code Files |
| ------------- | ------------- | ------------- | ------------- | ------------- |
| 1 | inversion of CMC parameters            | spm_dcm_csd  | [Docs](https://github.com/spm/spm/blob/main/toolbox/dcm_meeg/spm_dcm_csd.m) | mni_dcm_IJCAI.m |
| 2 | group level modelling (PEB) <br> re-estimating 1st level | spm_dcm_peb <br> spm_dcm_peb_fit| [Docs](https://github.com/spm/spm/blob/main/spm_dcm_peb.m) | mni_peb_IJCAI.m |
| 3 | use case for normative priors          | custom | custom | [>>MNN MEG](https://github.com/IJCAI-DCM/Tutorial/tree/main/MEG) |

---


#### Details:
##### 1. DCM inversion for the CMCs (1st level):
- the posteriors are inverted for the canonical microcircuit (CMC) with standard priors to obtain baseline model fits and evidence (free energy)
- variational Laplace (priors with Gaussian form) is used to iteratively update priors to obtain the fit and evidence
- code files:
  - "mni_dcm_IJCAI.m": preparation of the .edf files (create > MEEG object), and CMC inversion with DCM
  - "mni_housekeeping_IJCAI.m": directory definitions (please define)
  - SPM_Edits: minor edits for the SPM standard functions
---

##### 2. Parameter optimisation with PEB (2nd level):
- Parametric empirical Bayes (PEB) is used to test hypotheses relating to group data - here receptor densities as regressors - to optimise evidence
- preprocessing: receptor densities (RD) were matched to iEEG locations in MNI space, RD were averaged regionally and across cortical layers
- steps: define the PEB model space, estimate PEB parameters (2nd level), re-estimate CMC 1st level parameters using adjusted priors
- code files:
  - "mni_peb_IJCAI.m": creation of an appropriate group DCM file, definition of PEB model space (hypotheses, regressors, 1st level parameters) 
---
  
##### 3. Use case for normative CMC priors: 
- to showcase how the CMC priors can be used (and generalise), we included a tutorial for the mismatch negativity paradigm > please see details in the MEG folder
- this illustrates how priors can be assigned to offer an informed alternative to naive priors, and how they can improve model evidence and interpretability
