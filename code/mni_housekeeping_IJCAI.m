function H = mni_housekeeping
% to define paths and folders 

fs          = filesep;

if strcmp(computer, 'PCWIN64'), Fbase = 'G:\Shared drives\...'; % specify path for Win 
else                            Fbase = '/Shared drives/...';   % specify path for Mac
end

Fscripts    = [Fbase fs '01_Code'];
Fdata       = [Fbase fs '02_Data'];
Fedf        = [Fbase fs '02_Data/EDF_Files'];

Fanalysis   = [Fbase fs '03_Output'];
Fdcm        = [Fanalysis fs 'DCM'];

addpath(genpath(Fscripts));
spm('defaults', 'eeg');

H.Fbase     = Fbase;
H.Fanalysis = Fanalysis;
H.Fscripts  = Fscripts;
H.Fdcm      = Fdcm;
H.Fdata     = Fdata;