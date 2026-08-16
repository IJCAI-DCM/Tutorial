% DCM Main and Data Exploration / Plots
% Housekeeping
%==========================================================================
clear all
H           = mni_housekeeping_IJCAI;
fs          = filesep;
Fdata       = H.Fdata;
Fdcm        = H.Fdcm;
% files       = cellstr(spm_select('List', Fdata, '^MNI.*\.edf$'));
filesEDF    = cellstr(spm_select('List', Fdata, '.*\.edf$'));

spm('defaults','eeg')


%% 1. Preprocessing - Convert .edf Files into .mat Files
%==========================================================================
% Extract Trials / Channels from .edf Files, Convert into .mat / .dat
% Access Files / Trials via e.g. D(1,:,1) or LFP(1,:,1)

for f = 1:length(filesEDF)
    file    = [Fdata fs filesEDF{f}];
    hdr     = ft_read_header(file);
    dat     = ft_read_data(file);
    
    for i = 1:length(hdr.label)
        ftdata.trial{1}     = dat(i,:);
        ftdata.time{1}      = [1:size(dat,2)] / hdr.Fs;
        ftdata.label        = 'lfp';
        
        % Adjust names according to trial number
        if i >= 100
            output          = strcat(file(1:end-5),'T',char(string(i)),'_',hdr.label(i),'.mat');
        else if i >= 10
            output          = strcat(file(1:end-5),'T0',char(string(i)),'_',hdr.label(i),'.mat');
            else     
                output      = strcat(file(1:end-5),'T00',char(string(i)),'_',hdr.label(i),'.mat');
            end 
        end
        
        D = spm_eeg_ft2spm(ftdata, output{1});
        save(D);
    end

end

files    = cellstr(spm_select('List', Fdata, '.*\.mat$'));


%% 2. Run DCM for specified .mat Files
%==========================================================================
for f = 1:length(files)

    % Set up DCM structure and invert baseline
    %==========================================================================
    DCM = [];

    sub = files{f}(1:end-4);
    % Fix directory of canonical forward matrix
    %--------------------------------------------------------------------------
    DCM.xY.Dfile        = [Fdata fs files{f}];

    % Load MEEG object and extract sampling rate and info
    %--------------------------------------------------------------------------
    LFP                 = spm_eeg_load(DCM.xY.Dfile);
    Fs                  = fsample(LFP);
    smpls               = size(LFP,2);
    timax               = linspace(0, smpls/Fs, smpls);
    clist               = condlist(LFP);
 
    for c = 1:length(clist)
        % Set up DCM details
        %--------------------------------------------------------------------------
        DCM.options.analysis    = 'CSD';   	% cross-spectral density 
        DCM.options.model       = 'CMC';    % structure cannonical microcircuit (for now)
        DCM.options.spatial    	= 'LFP';    % virtual electrode input   
        DCM.options.Tdcm        = [timax(1) timax(end)] * 1000;     % time in ms

        DCM.options.Fdcm    = [1 60];     	% frequency range  
        DCM.options.D       = 1;         	% frequency bin, 1 = no downsampling
        DCM.options.Nmodes  = 8;          	% number of eigenmodes
        DCM.options.han     = 0;         	% no hanning 
        DCM.options.trials  = c;            % index of ERPs within file

        DCM.Sname           = chanlabels(LFP);
        DCM.M.Hz            = DCM.options.Fdcm(1):DCM.options.D:DCM.options.Fdcm(2);
        DCM.xY.Hz           = DCM.M.Hz;

        %% - Create DCM Struct and specify DCM.options 
        %--------------------------------------------------------------------------
        DCM.A       = {1 1 1};
        DCM.B    	= {};
        DCM.C   	= sparse(length(DCM.A{1}),0);

        % Reorganise model parameters in specific structure
        %==========================================================================
        DCM.M.dipfit.Nm     = DCM.options.Nmodes;
        DCM.M.dipfit.model 	= DCM.options.model;
        DCM.M.dipfit.type   = DCM.options.spatial;
        DCM.M.dipfit.Nc     = size(LFP,1);
        DCM.M.dipfit.Ns     = length(DCM.A{1});

        % Load empirical priors
        %--------------------------------------------------------------------------
        % [pE,pC]             = mni_spm_cmc_priors(DCM.A,DCM.B,DCM.C);
        % load([Fdcm fs 'Priors' fs 'Priors.mat']);
        % pE                  = Priors.pE; % Prior Expectations, Ep - Post.
        % pC                  = Priors.pC; % Prior Covariances, Cp - Post.
        % 
        % DCM.M.pE    = pE;
        % DCM.M.pC    = pC;

        DCM.name            = [Fdcm fs 'DCM_' sub '.mat'];
        DCM                 = nae_spm_dcm_csd(DCM);
        DCM.xY.R            = diag(DCM.xY.R); 
        save(DCM.name, 'DCM');
        
    end

end


%% 3. Plot DCM fits and evidence
%==========================================================================

% Loading two example DCM structures
load([Fdcm fs 'DCM_Cuneus_T001_GD042Rs1W.mat'])
    DCM_1 = DCM;

load([Fdcm fs 'DCM_Cuneus_T002_GD048Ls_1W.mat'])
    DCM_2 = DCM;

% 1 - Plotting observations and model fit
figure 
    hold on
    % observations
        plot(abs(DCM_1.xY.y{1,1}), Color=[0 0 1]);
        plot(abs(DCM_2.xY.y{1,1}), Color=[1 0 0]);
    % model estimates
        plot(abs(DCM_1.Hc{1,1}),Color=[0 0 1], LineStyle = 'none', Marker = 'o');
        plot(abs(DCM_2.Hc{1,1}), Color=[1 0 0], LineStyle = 'none', Marker = 'o');
    
    % plotting vertical lines for frequency bands
    xline(4,':',{'delta'},'LabelHorizontalAlignment','left');
    xline(8,':',{'theta'},'LabelHorizontalAlignment','left');
    xline(13,':',{'alpha'},'LabelHorizontalAlignment','left');
    xline(30,':',{'beta'},'LabelHorizontalAlignment','left');
    xline(60,':',{'gamma'},'LabelHorizontalAlignment','left');
    
    % legends
        leg = {'DCM_1 - obs'; 'DCM_2 - obs'; 'DCM_1 - mod'; 'DCM_2 - mod'};
        legend({leg{1:4}},'Location','East');

    % axes labels 
        xlabel('Frequency')
        ylabel('Power')
        
hold off


% 2 - Plotting model evidence (free energy)
figure 
    hold on
    % free energy (evidence)
        FEs = [abs(DCM_1.F);abs(DCM_2.F)]; 
        
    % legends
        X = categorical({'DCM_1','DCM_2'});
        X = reordercats(X,{'DCM_1','DCM_2'});

    % plot
        bar(X,FEs);        

    % axes labels 
        ylabel('Model evidence')

hold off

