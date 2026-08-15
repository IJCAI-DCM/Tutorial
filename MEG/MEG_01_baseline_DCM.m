%% MEG USE CASE 01: MATCHED BASELINE DCM
% IJCAI 2026 DCM Tutorial
%
% This script inverts the matched five-source, ten-G baseline DCM.
% The intrinsic G prior expectations are the canonical zero-centred values.
% The same custom prior and inversion functions are used in the
% receptor-informed analysis (MEG_02_receptor_informed_DCM.m).
%
% Required input:
%   data/DCM_20HC_standard_pitch_CMC_5source_ULRICH_UNINVERTED.mat
%
% Output:
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

if ~exist(output_directory, 'dir')
    mkdir(output_directory);
end

input_file = fullfile( ...
    data_directory, ...
    'DCM_20HC_standard_pitch_CMC_5source_ULRICH_UNINVERTED.mat');

output_file = fullfile( ...
    output_directory, ...
    'DCM_20HC_standard_pitch_CMC_5source_MATCHED_10G_BASELINE_INVERTED.mat');

assert(isfile(input_file), ...
    'Prepared five-source DCM not found:\n%s', input_file);

%% ------------------------------------------------------------------------
% LOAD PREPARED FIVE-SOURCE MEG DCM
% -------------------------------------------------------------------------

input_data = load(input_file, 'DCM');
assert(isfield(input_data, 'DCM'), ...
    'Input file does not contain a variable named DCM.');

DCM = input_data.DCM;

assert(strcmpi(DCM.options.model, 'CMC'), ...
    'Expected DCM.options.model to be CMC.');
assert(numel(DCM.Sname) == 5, ...
    'Expected five cortical sources.');

% The final analysis used a deterministic prior-centred inversion.
if isfield(DCM, 'g_rand')
    DCM = rmfield(DCM, 'g_rand');
end

%% ------------------------------------------------------------------------
% GENERATE THE MATCHED TEN-G PRIOR STRUCTURE
% -------------------------------------------------------------------------

[pE, pC] = mmn_spm_dcm_neural_priors( ...
    DCM.A, DCM.B, DCM.C, DCM.options.model);

assert(isequal(size(pE.G), [5 10]), ...
    'Expected pE.G to be 5 x 10.');
assert(isequal(size(pC.G), [5 10]), ...
    'Expected pC.G to be 5 x 10.');
assert(nnz(full(pE.G)) == 0, ...
    'Baseline intrinsic G prior expectations are not zero-centred.');

% Store the complete custom ten-G prior structures in the DCM.
DCM.M.pE = pE;
DCM.M.pC = pC;

fprintf('\nMatched baseline prepared.\n');
fprintf('Intrinsic G prior matrix: %d sources x %d parameters\n', ...
    size(DCM.M.pE.G, 1), size(DCM.M.pE.G, 2));
fprintf('Non-zero entries in baseline pE.G: %d\n', ...
    nnz(full(DCM.M.pE.G)));

%% ------------------------------------------------------------------------
% INVERT BASELINE DCM
% -------------------------------------------------------------------------

fprintf('\nInverting matched baseline DCM...\n');
DCM = mmn_spm_dcm_erp_MP_eP(DCM);

assert(isfield(DCM, 'F') && isfinite(DCM.F), ...
    'Inverted baseline does not contain a valid free energy.');
assert(isfield(DCM, 'Ep') && isfield(DCM.Ep, 'G'), ...
    'Inverted baseline does not contain posterior Ep.G.');
assert(isequal(size(DCM.Ep.G), [5 10]), ...
    'Posterior Ep.G is not 5 x 10.');

save(output_file, 'DCM', '-v7.3');

fprintf('\nBaseline inversion complete.\n');
fprintf('Free energy F = %.12f\n', DCM.F);
fprintf('Saved to:\n%s\n', output_file);
