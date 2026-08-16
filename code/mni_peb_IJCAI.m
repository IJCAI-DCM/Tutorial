% PEB over all DCMs - Relative Receptor Densities
%==========================================================================
% Case: 4 Receptors (AMPA, NMDA, GABAa, GABAb), 44 Regions (AR data)
% Conditions: static (always on), + iterations of receptors

%==========================================================================
% PEB - SEEG DCMs and Autoradiography Receptor Densities
%==========================================================================
%% 1.1 Housekeeping + Data Import
%--------------------------------------------------------------------------

D           = mni_housekeeping_IJCAI;
fs          = filesep;
Fdata       = D.Fdata;
Fdcm        = D.Fdcm;

% Load DCM_ALL if already available
load([Fdcm fs '_DCM_ALL_6rec_44reg.mat'], 'DCM_ALL');

% Load file with region information (Frauscher)
F_region_names          = [D.Fbase fs 'RegionInformation.csv'];
region_names_F          = readtable(F_region_names);
region_names_F(:,2)     = replace(region_names_F{:,2},'''','');

% Load file with receptor information (densities)
D_seeg_table = readtable([D.Fbase fs 'D_seeg_table_PCA_win4PC_1stLev.xls']);
D_seeg_table(:,1) = replace(D_seeg_table{:,1},'''','');


% Define receptors, column-names, extract ranges for relative densities 
%--------------------------------------------------------------------------

rec_names = {'AMPA', 'NMDA', 'GABAa', 'GABAb'}; 

for i=1 : length(rec_names)
    table_col = ...
        strcat(rec_names{i},'_allLayers');
    rec_columns(i) = ...
        find(string(D_seeg_table.Properties.VariableNames) == table_col);
    rec_ranges.(strcat(rec_names{i},'_max')) = ...
        max(D_seeg_table{:,rec_columns(i)});
    rec_ranges.(strcat(rec_names{i},'_min')) = ...
        min(D_seeg_table{:,rec_columns(i)});
end


%% 1.2 Create DCM cell array (ONLY if it doesn't exist)
%==========================================================================
% Locate and determine DCM files to be loaded 
filesDCM    = cellstr(spm_select('List', Fdcm, '^DCM.*\.mat$'));

% Annotations in DCM_ALL structure (_DCM_ALL.annot)
for i=1 : length(filesDCM)
    load(filesDCM{i});
    DCM_ALL{i,1} = DCM;
  
    % Add name of DCM / measurement
    DCM_ALL{i}.annot.file = filesDCM{i};
    
    % Add Frauscher region (region_F) and channel name 
    underscores_1 = ...
        strfind(filesDCM{i}, '_');
    DCM_ALL{i}.annot.region_F = ...
        filesDCM{i}(underscores_1(1)+1:underscores_1(2)-1);
    DCM_ALL{i}.annot.channel = ...
        filesDCM{i}(underscores_1(3)+1:end-5);
    
    % Add AR and Frauscher region IDs (use D_seeg_table)
    idx = find(strcmp(D_seeg_table{:,1}, DCM_ALL{i}.annot.channel)==1);
    % Regions: AR-Receptor (col 16, 44 reg), Frauscher (col 5, 38reg)
    DCM_ALL{i}.annot.region = D_seeg_table{idx,17};
    DCM_ALL{i}.annot.region_id = D_seeg_table{idx,16};
    DCM_ALL{i}.annot.region_id_F = D_seeg_table{idx,5};
    clear idx;
    
    % Add (abs, rel) receptor (density) information to DCMs 
    idx = find(strcmp(D_seeg_table{:,1}, DCM_ALL{i}.annot.channel)==1);
    for j=1 : length(rec_names)
        % Define help strings for receptor names
        rec_dens        = strcat(rec_names{j},'_dens');
        rec_relative    = strcat(rec_names{j},'_relative');
        rec_min         = strcat(rec_names{j},'_min');
        rec_max         = strcat(rec_names{j},'_max');
        
        % Add abs, rel receptor information
        DCM_ALL{i}.annot.(rec_dens) ...
            = D_seeg_table{idx,rec_columns(j)};
        DCM_ALL{i}.annot.(rec_relative) = ...
            (DCM_ALL{i}.annot.(rec_dens) - rec_ranges.(rec_min)) / ...
            (rec_ranges.(rec_max) - rec_ranges.(rec_min));
    end 
    
    clear idx;
    clear DCM;
end

% save([Fdcm fs '_DCM_ALL_4rec_44reg.mat'], 'DCM_ALL');


%% 2. PEB Analysis
%==========================================================================
% Make second level model space / define conditions (design matrix)
%--------------------------------------------------------------------------

% Extracting condition data from DCM_ALL annotations
for i=1 : length(DCM_ALL)
    sum_data.regions(i) = DCM_ALL{i}.annot.region_id;
    
    for j=1 : length(rec_names)
       rec_relative = ...
           strcat(rec_names{j},'_relative');
       sum_data.(rec_relative)(i) = ...
           DCM_ALL{i}.annot.(rec_relative);
    end
end

% Define PEB inputs (DCMs, models / variations, fields / free model parameters)
FCM         = DCM_ALL;

% Define all conditions / fields in PEB
X                 = [ones(1,length(DCM_ALL)); ...
    sum_data.AMPA_relative; sum_data.NMDA_relative;
    sum_data.GABAa_relative; sum_data.GABAb_relative]';
cond_all            = X;
cond_names          = {'Static', rec_names{:}};
cond_names_short    = {'B', 'A', 'N', 'Ga', 'Gb'};


% Create design matrices for combinations of fields / conditions
% vec: columns for conditions, comb_size: number of combinations (PEBs)
vec = 2:1:size(cond_all,2);
comb_size = 1;
for i=1 : length(vec)
   comb_size = comb_size + size(nchoosek(vec,i),1);
end

% Create matrix (des_mat) with all possible combinations of conditions
des_mat = [ones(comb_size,1), zeros(comb_size,4)];
row_idx = 2;
for i=1 : length(vec)
    comb = nchoosek(vec,i);
    for j=1 : size(comb,1) 
        for k=1 : size(comb,2)
            des_mat(row_idx, comb(j,k))=1;
        end
        row_idx = row_idx + 1;
    end
end

% Create structure (cond) with data fields (combinations) for X (experiments)
for i=1 : size(des_mat,1)
    cnt_true = 1;
    for j=1 : size(des_mat,2)
        if des_mat(i,j) == 1
            help_mat(:,cnt_true) = X(:,j);
            cnt_true = cnt_true + 1;
        end
    end
    cond.idx{i} = help_mat; 
    help_mat = [];
end

clear i j k idx row_idx vec help help_mat cnt_true underscores_1; 


%% 2.1 Parameter Incl / Excl
%==========================================================================
% Time constant parameters mab_spm_fx_cmc
%--------------------------------------------------------------------------
% G(:,1)  ss -> ss (-ve self)  4    MOD
% G(:,2)  sp -> ss (-ve rec )  4    INH
% G(:,3)  ii -> ss (-ve rec )  4    INH
% G(:,4)  ii -> ii (-ve self)  4    MOD
% G(:,5)  ss -> ii (+ve rec )  4    EXC
% G(:,6)  dp -> ii (+ve rec )  2    EXC
% G(:,7)  sp -> sp (-ve self)  4    MOD
% G(:,8)  ss -> sp (+ve rec )  4    EXC
% G(:,9)  ii -> dp (-ve rec )  2    INH
% G(:,10) dp -> dp (-ve self)  1    MOD
% 
% The order in the DCM structure is as follows
% j     = [7 2 3 4 5 6 8 9 10 1];
% i.e.     M I I M E E E I M  M
% new   =  1 2 3 4 5 6 7 8 9 10

fields{1}   = {'T(1)', 'T(2)', 'T(3)', 'T(4)'};     % time constants
fields{2}   = {'G(2)', 'G(3)', 'G(8)'};             % inh connections
fields{3}   = {'G(5)', 'G(6)', 'G(7)'};             % exc connections
fields{4}   = {'G(1)', 'G(4)', 'G(9)', 'G(10)'};    % mod connections
fields{5}   = {fields{1}{:}, fields{2}{:}};         % time and inh
fields{6}   = {fields{1}{:}, fields{3}{:}};         % time and exc
fields{7}   = {fields{1}{:}, fields{4}{:}};         % time and mod
fields{8}   = {fields{1}{:}, fields{2}{:}, fields{4}{:}};   % time, inh, and mod
fields{9}   = {fields{1}{:}, fields{2}{:}, fields{3}{:}};   % time, inh, and exc
fields{10}   = {fields{2}{:}, fields{3}{:}};         % inh and exc
fields{11}   = {fields{2}{:}, fields{4}{:}};         % inh and mod
fields{12}  = {fields{3}{:}, fields{4}{:}};         % exc and mod
fields{13}  = {fields{2}{:}, fields{3}{:}, fields{4}{:}}; % all coupling
fields{14}  = {fields{1}{:}, fields{2}{:}, fields{3}{:}, fields{4}{:}}; % all 

labels  = { 't', 'g_i', 'g_e', 'g_m', ...
            't, g_i', 't, g_e', 't, g_m', 't, g_i, g_m', 't, g_i, g_e', ...
            'g_i, g_e', 'g_i, g_m', 'g_e, g_m', 'g_{all}', 'all'};

        
%% 2.2 PEB for DCM
%==========================================================================

% Define models
    % Design matrices > cond.idx (DCM)

% Model names
for i=1 : length(des_mat)
    names_idx = find(des_mat(i,:));
    Mnames{i} = strcat(cond_names_short{names_idx});
end

Xnames      = cond_names;

% Run PEBs
for i=1 : size(des_mat,1)
    X           = cond.idx{i};
    M.X         = X;
    M.Xnames    = Xnames;
    M.Q         = 'all';
    [PEB ~]   = spm_dcm_peb(FCM, M, fields{end});
    PEB.Mname   = Mnames(i);
    peb(i)      = PEB;
    clear PEB RCM;
end

% save([Fdcm fs '_PEB_BMC_ANGaGb_16.mat'], 'peb');


%% 2.2a Simple plots
%==========================================================================

% Load existing PEB analysis
% load([Fdcm fs '_PEB_BMC_ANGaGb_16.mat'], 'peb');

F = [peb(:).F];

% Delivering top k models with highest FE
[k_max i_max] = maxk(F,5);

figure
    boxplot(F,[peb(:).Mname], 'LabelOrientation','inline');
    xlabel('PEB Model / RD-Data included');
    ylabel('Free Energy');

% 4 Receptors
    xline(1.5,':',{'BL + 1 R'},'LabelHorizontalAlignment','right');
    xline(5.5,':',{'BL + 2 R'},'LabelHorizontalAlignment','right');
    xline(11.5,':',{'BL + 3 R'},'LabelHorizontalAlignment','right');
    xline(15.5,':',{'BL + 4 R'},'LabelHorizontalAlignment','right');



