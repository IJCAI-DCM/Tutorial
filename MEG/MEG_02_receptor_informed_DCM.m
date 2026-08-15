%% MEG USE CASE 02: RECEPTOR-INFORMED DCM PRIORS
% IJCAI 2026 DCM Tutorial
%
% This script constructs source-specific intrinsic G prior expectations
% from receptor-informed iEEG CMC estimates, inverts otherwise matched
% five-source MEG DCMs across Gaussian spatial kernel widths, and compares
% their variational free energy with the matched baseline model.
%
% Required inputs:
%   data/DCM_20HC_standard_pitch_CMC_5source_ULRICH_UNINVERTED.mat
%   data/_DCM_ALL_44reg_PCA.mat
%   data/D_seeg_table_PCA_win4PC_1stLev.xls
%
% Required output from MEG_01_baseline_DCM.m:
%   output/DCM_20HC_standard_pitch_CMC_5source_MATCHED_10G_BASELINE_INVERTED.mat

clear;
clc;
format long g;

%% ------------------------------------------------------------------------
% SETUP
% -------------------------------------------------------------------------

code_directory = fileparts(mfilename('fullpath'));
functions_directory = fullfile(code_directory, 'functions');
data_directory = fullfile(code_directory, 'data');
output_directory = fullfile(code_directory, 'output');
model_output_directory = fullfile(output_directory, 'receptor_models');
prior_output_directory = fullfile(output_directory, 'receptor_priors');

assert(exist('spm', 'file') == 2, ...
    ['SPM is not on the MATLAB path. Add the tutorial SPM installation ' ...
     'to the MATLAB path before running this script.']);

addpath(functions_directory, '-begin');
spm('defaults', 'EEG');
spm_jobman('initcfg');
rehash toolboxcache;

required_functions = {
    'mmn_spm_dcm_erp_MP_eP'
    'mmn_spm_dcm_neural_priors'
    'mmn_spm_dcm_x_neural'
    'mmn_spm_cmc_priors'
    'mmn_spm_fx_cmc'
};

for function_index = 1:numel(required_functions)
    assert(exist(required_functions{function_index}, 'file') == 2, ...
        'Cannot find required function: %s', ...
        required_functions{function_index});
end

if ~exist(output_directory, 'dir'), mkdir(output_directory); end
if ~exist(model_output_directory, 'dir'), mkdir(model_output_directory); end
if ~exist(prior_output_directory, 'dir'), mkdir(prior_output_directory); end

template_file = fullfile( ...
    data_directory, ...
    'DCM_20HC_standard_pitch_CMC_5source_ULRICH_UNINVERTED.mat');

historical_dcm_file = fullfile( ...
    data_directory, ...
    '_DCM_ALL_44reg_PCA.mat');

coordinate_file = fullfile( ...
    data_directory, ...
    'D_seeg_table_PCA_win4PC_1stLev.xls');

baseline_file = fullfile( ...
    output_directory, ...
    'DCM_20HC_standard_pitch_CMC_5source_MATCHED_10G_BASELINE_INVERTED.mat');

assert(isfile(template_file), 'Prepared MEG DCM not found:\n%s', template_file);
assert(isfile(historical_dcm_file), 'Historical iEEG DCM file not found:\n%s', historical_dcm_file);
assert(isfile(coordinate_file), 'iEEG coordinate file not found:\n%s', coordinate_file);
assert(isfile(baseline_file), ...
    ['Matched baseline not found. Run MEG_01_baseline_DCM.m first.\n%s'], ...
    baseline_file);

% Gaussian kernel widths used in the final sensitivity analysis.
sigma_mm_values = [5 10 20 30 40 50 60 70 80 90 100];

%% ------------------------------------------------------------------------
% LOAD PREPARED MEG DCM AND SOURCE COORDINATES
% -------------------------------------------------------------------------

template_data = load(template_file, 'DCM');
DCM_template = template_data.DCM;

assert(strcmpi(DCM_template.options.model, 'CMC'), ...
    'Expected DCM.options.model to be CMC.');
assert(numel(DCM_template.Sname) == 5, ...
    'Expected five cortical sources.');

source_xyz = double(DCM_template.Lpos');
n_sources = size(source_xyz, 1);
assert(n_sources == 5, 'Expected five cortical sources.');

if isfield(DCM_template, 'g_rand')
    DCM_template = rmfield(DCM_template, 'g_rand');
end

%% ------------------------------------------------------------------------
% LOAD THE MATCHED BASELINE
% -------------------------------------------------------------------------

baseline_data = load(baseline_file, 'DCM');
DCM_baseline = baseline_data.DCM;

assert(isfield(DCM_baseline, 'F') && isfinite(DCM_baseline.F), ...
    'Baseline does not contain a valid free energy.');

F_baseline = double(DCM_baseline.F);
baseline_pE_G = full(double(DCM_baseline.M.pE.G));

assert(isequal(size(baseline_pE_G), [5 10]), ...
    'Baseline pE.G is not 5 x 10.');
assert(nnz(baseline_pE_G) == 0, ...
    'Baseline pE.G is not zero-centred.');

%% ------------------------------------------------------------------------
% LOAD RECEPTOR-INFORMED iEEG CMC ESTIMATES
% -------------------------------------------------------------------------

historical_data = load(historical_dcm_file);
assert(isfield(historical_data, 'DCM_ALL'), ...
    'Historical file does not contain DCM_ALL.');

DCM_ALL = historical_data.DCM_ALL;
n_contacts = numel(DCM_ALL);
contact_G = nan(n_contacts, 10);

for contact_index = 1:n_contacts

    if iscell(DCM_ALL)
        current_dcm = DCM_ALL{contact_index};
    else
        current_dcm = DCM_ALL(contact_index);
    end

    assert(isfield(current_dcm, 'Ep') && isfield(current_dcm.Ep, 'G'), ...
        'Historical DCM %d does not contain Ep.G.', contact_index);

    current_G = full(double(current_dcm.Ep.G));
    assert(numel(current_G) == 10, ...
        'Historical DCM %d does not contain 10 G estimates.', contact_index);

    contact_G(contact_index, :) = reshape(current_G, 1, 10);
end

assert(all(isfinite(contact_G(:))), ...
    'Historical G estimates contain NaN or Inf.');

%% ------------------------------------------------------------------------
% LOAD iEEG MNI COORDINATES
% -------------------------------------------------------------------------

coordinate_table = readtable(coordinate_file, ...
    'VariableNamingRule', 'preserve');

variable_names = coordinate_table.Properties.VariableNames;
x_index = find(strcmpi(variable_names, 'x_original'), 1);
y_index = find(strcmpi(variable_names, 'y_original'), 1);
z_index = find(strcmpi(variable_names, 'z_original'), 1);

assert(~isempty(x_index) && ~isempty(y_index) && ~isempty(z_index), ...
    'Could not find x_original, y_original and z_original coordinate columns.');

contact_xyz = [ ...
    double(coordinate_table{:, x_index}), ...
    double(coordinate_table{:, y_index}), ...
    double(coordinate_table{:, z_index}) ...
];

assert(size(contact_xyz, 1) == n_contacts, ...
    'Number of coordinate rows does not match number of iEEG DCMs.');
assert(all(isfinite(contact_xyz(:))), ...
    'iEEG coordinates contain NaN or Inf.');

fprintf('\nLoaded %d receptor-informed iEEG CMC estimates.\n', n_contacts);

%% ------------------------------------------------------------------------
% CONSTRUCT PRIORS, INVERT MODELS AND COMPARE FREE ENERGY
% -------------------------------------------------------------------------

n_sigma = numel(sigma_mm_values);
free_energy = nan(n_sigma, 1);
delta_F = nan(n_sigma, 1);

for sigma_index = 1:n_sigma

    sigma_mm = sigma_mm_values(sigma_index);
    fprintf('\n------------------------------------------------------------\n');
    fprintf('Gaussian kernel width: sigma = %g mm\n', sigma_mm);

    % Each row will contain the 10 intrinsic G prior expectations for one
    % of the five MEG sources.
    receptor_pE_G = zeros(n_sources, 10);

    for source_index = 1:n_sources

        % Euclidean distance from every iEEG contact to this MEG source.
        coordinate_difference = ...
            contact_xyz - source_xyz(source_index, :);
        distances_mm = sqrt(sum(coordinate_difference .^ 2, 2));

        % Gaussian spatial weighting. Smaller sigma values penalise
        % distance more strongly; larger values produce broader weighting.
        weights = exp( ...
            -(distances_mm .^ 2) ./ (2 * sigma_mm ^ 2));

        % Normalise so that the contact weights sum to one for this source.
        weights = weights ./ sum(weights);
        assert(abs(sum(weights) - 1) < 1e-12, ...
            'Normalised Gaussian weights do not sum to one.');

        % Weighted mean of the 10 iEEG posterior G estimates.
        receptor_pE_G(source_index, :) = weights' * contact_G;
    end

    assert(isequal(size(receptor_pE_G), [5 10]), ...
        'Receptor-informed G prior matrix is not 5 x 10.');
    assert(all(isfinite(receptor_pE_G(:))), ...
        'Receptor-informed G prior matrix contains NaN or Inf.');

    % Start from the same prepared MEG DCM used for the baseline.
    DCM = DCM_template;

    % Generate exactly the same complete custom ten-G prior structure as
    % for the baseline, then replace only the intrinsic G expectations.
    [pE, pC] = mmn_spm_dcm_neural_priors( ...
        DCM.A, DCM.B, DCM.C, DCM.options.model);

    DCM.M.pE = pE;
    DCM.M.pC = pC;
    DCM.M.pE.G = sparse(receptor_pE_G);

    % Audit the controlled comparison: the prior covariance structure is
    % identical to the baseline, and the only prior-expectation field that
    % differs is pE.G.
    assert(isequaln(DCM.M.pC, DCM_baseline.M.pC), ...
        'Prior covariance structure differs from the matched baseline.');

    pE_with_baseline_G = DCM.M.pE;
    pE_with_baseline_G.G = DCM_baseline.M.pE.G;
    assert(isequaln(pE_with_baseline_G, DCM_baseline.M.pE), ...
        'A non-G prior expectation differs from the matched baseline.');

    assert(isequaln(DCM.A, DCM_template.A), 'A matrices changed.');
    assert(isequaln(DCM.B, DCM_template.B), 'B matrices changed.');
    assert(isequaln(DCM.C, DCM_template.C), 'C matrix changed.');
    assert(isequaln(DCM.Lpos, DCM_template.Lpos), 'Source locations changed.');
    assert(isequaln(DCM.xU, DCM_template.xU), 'Experimental inputs changed.');
    assert(isequaln(DCM.options, DCM_template.options), 'DCM options changed.');

    % Save the source-specific receptor-informed prior matrix.
    prior_file = fullfile( ...
        prior_output_directory, ...
        sprintf('MEG_receptor_G_priors_sigma_%gmm.mat', sigma_mm));
    save(prior_file, 'receptor_pE_G', 'sigma_mm', 'source_xyz', '-v7.3');

    % Invert the receptor-informed DCM.
    DCM = mmn_spm_dcm_erp_MP_eP(DCM);

    assert(isfield(DCM, 'F') && isfinite(DCM.F), ...
        'Inverted receptor-informed model has invalid free energy.');

    free_energy(sigma_index) = double(DCM.F);
    delta_F(sigma_index) = free_energy(sigma_index) - F_baseline;

    model_file = fullfile( ...
        model_output_directory, ...
        sprintf('DCM_RECEPTOR_SIGMA_%gmm_INVERTED.mat', sigma_mm));
    save(model_file, 'DCM', '-v7.3');

    fprintf('F = %.12f | Delta F vs baseline = %+.12f\n', ...
        free_energy(sigma_index), delta_F(sigma_index));
end

%% ------------------------------------------------------------------------
% SAVE MODEL-EVIDENCE SUMMARY
% -------------------------------------------------------------------------

results = table( ...
    sigma_mm_values(:), ...
    free_energy, ...
    delta_F, ...
    'VariableNames', {'SigmaMm', 'FreeEnergy', 'DeltaFvsBaseline'});

writetable(results, ...
    fullfile(output_directory, 'MEG_receptor_model_evidence.csv'));

save(fullfile(output_directory, 'MEG_receptor_model_evidence.mat'), ...
    'results', 'F_baseline');

fprintf('\n============================================================\n');
fprintf('MODEL-EVIDENCE SUMMARY\n');
fprintf('============================================================\n');
fprintf('Matched baseline F = %.12f\n\n', F_baseline);
disp(results);
