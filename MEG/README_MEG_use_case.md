# MEG use case: receptor-informed priors for DCM

This folder contains a cleaned tutorial version of the MATLAB code used for the IJCAI 2026 MEG use case. The analysis asks whether receptor-informed intrinsic-connectivity estimates derived from iEEG CMC models can be transferred as prior expectations to a time-domain DCM of auditory MEG responses.

## Analysis logic

The baseline and receptor-informed models use the same prepared MEG data, five-source network architecture, CMC specification, data features, non-G prior expectations, prior covariance structure, and inversion function. They differ in the prior expectations assigned to the 50 intrinsic G parameters (5 sources x 10 G parameters).

- **Baseline:** `pE.G = 0` for all 50 intrinsic G parameters.
- **Receptor-informed:** `pE.G` is a source-specific 5 x 10 matrix obtained by spatially weighting receptor-informed iEEG posterior G estimates.

For each MEG source and Gaussian kernel width, the code:

1. calculates Euclidean distance from each iEEG contact to the MEG source;
2. converts distance to an unnormalised Gaussian weight, `exp(-d^2 / (2*sigma^2))`;
3. normalises the contact weights to sum to one;
4. calculates the weighted mean of the 10 iEEG posterior G estimates;
5. inserts the resulting source-specific values into `DCM.M.pE.G`;
6. inverts the otherwise matched DCM;
7. compares variational free energy with the matched baseline.

The tested kernel widths are 5, 10, 20, 30, 40, 50, 60, 70, 80, 90 and 100 mm.

## Scripts

### `MEG_01_baseline_DCM.m`
Creates and inverts the matched five-source, ten-G baseline model using the custom prior structure with zero-centred intrinsic G prior expectations.

### `MEG_02_receptor_informed_DCM.m`
Loads the receptor-informed iEEG CMC estimates and their MNI coordinates, constructs source-specific G priors across the 11 Gaussian kernel widths, inverts each matched receptor-informed DCM, and saves the free-energy comparison.

Run the baseline script first.

## Required data files

Place the following files in the `data/` directory:

- `DCM_20HC_standard_pitch_CMC_5source_ULRICH_UNINVERTED.mat`
  - prepared five-source MEG DCM containing the Standard and Pitch Deviant responses;
- `_DCM_ALL_44reg_PCA.mat`
  - historical receptor-informed iEEG DCM archive containing `DCM_ALL` and posterior `Ep.G` estimates;
- `D_seeg_table_PCA_win4PC_1stLev.xls`
  - MNI coordinates corresponding to the iEEG DCMs (`x_original`, `y_original`, `z_original`).

The historical archive used in the final MEG analysis contains 1,769 iEEG DCMs.

## Custom functions

The `functions/` directory contains the custom ten-G CMC functions required by the MEG inversion:

- `mmn_spm_dcm_erp_MP_eP.m`
- `mmn_spm_dcm_neural_priors.m`
- `mmn_spm_cmc_priors.m`
- `mmn_spm_dcm_x_neural.m`
- `mmn_spm_fx_cmc.m`

The function declarations in the supplied source files were aligned with their filenames in this cleaned tutorial copy. No intended model equations or prior values were changed during that naming cleanup.

## Software

The scripts require MATLAB and SPM. SPM should already be on the MATLAB path before running either script. The tutorial scripts initialise SPM with EEG defaults and add the local custom-functions directory at the beginning of the path.

## Outputs

Outputs are written to `output/`:

- matched baseline inverted DCM;
- receptor-informed prior matrices for each kernel width;
- inverted receptor-informed DCMs;
- CSV and MAT summaries containing `F` and `DeltaF` relative to the baseline.

## Scope of this tutorial code

This package begins from a prepared group-level five-source MEG DCM. Participant-level preprocessing, artefact rejection, robust averaging, group averaging, figure-generation code, and exploratory free-energy decomposition are intentionally excluded so that the example focuses on the prior-informed DCM comparison.
