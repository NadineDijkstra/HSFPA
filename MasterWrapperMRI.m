% Add paths
clear all;
restoredefaultpath;
    
addpath('D:\infabs\MRI\Analyses');
addpath(genpath('D:\infabs\MRI\Analyses\dataQuality-1.5'));
addpath(genpath('D:\infabs\MRI\Analyses\MetaLabCore-master'));
addpath(genpath('D:\infabs\MRI\Analyses\spm'));
addpath(genpath('D:\ifnabs\MRI\Analyses\rsatoolbox-develop'));
addpath('D:\infabs\MRI\Analyses\Utilities');

root = 'D:\infabs\MRI';

cd(root)

% Subjects
% Excluded:
% sub01     Low target accuracy
% sub02     No behavioural data recorded during scanning
% sub04     Low target accuracy
% sub12     Low target accuracy
% sub23     Low target accuracy
% sub28 	Low target accuracy
% sub36 	Low target accuracy
subjects = {'sub01', 'sub02', 'sub03', 'sub04', 'sub05', 'sub06', 'sub07', 'sub08', 'sub09', 'sub10', ...
    'sub11', 'sub12', 'sub13', 'sub14', 'sub15', 'sub16', 'sub17', 'sub18', 'sub19' 'sub20', 'sub21', ...
    'sub22', 'sub23', 'sub24', 'sub25', 'sub26', 'sub27', 'sub28', 'sub29', 'sub30', 'sub31', 'sub32', ...
    'sub33', 'sub34', 'sub35', 'sub36'};
nsubjects = length(subjects);

% Included subjects
which_subjects = [3, 5, 6, 8, 9, 11, 13, 14, 15, 16, 17, 18,...
    19, 20, 21, 22, 24, 25, 26, 27, 29, 30, 31, 32, 33, 34, 35];

%% 0. Behaviour

cfg = [];
cfg.subjects = subjects(which_subjects);
cfg.root = root;
cfg.outputDir = 'raw/Behaviour';

BehaviourAnalysis(cfg)

%% 1. DICOM IMPORT

fil_subject_details

% Add details to fil_subject_details then run
for SID = which_subjects
    % Get the tar file of raw data (2020)
    ARCHIVE = str2fullfile(fullfile('\\charm\data\quattro\2020\',...
        sprintf('%s.%s', subj{4}.date, subj{4}.scanid(1:end-2))),'*.tar');    
    
    Import_Archive(ARCHIVE,fullfile(root,subj{4}.name,'raw'));
end

% Organise
cfg = [];
cfg.which_subjects = which_subjects;
cfg.which_scans = {'loc', 'struc', 'func', 'fm'};
cfg.dir_root = root;
cfg.n_fun = 6;
cfg.n_dum = 4;
cfg.spm_dir = '\\Blur\infabs\MRI\Analyses\spm';

fil_mri_organise(cfg);

% Convert each functional run to a 4D nifti
convert_4D(which_subjects, root);

%% 2. Data Quality - Has to be on unix

% Check movie of raw data in FSLeyes

% Set origin of structural to Anterior Commisure and reorient all functionals

%% 3. Preprocessing

% Fieldmap
fil_fieldmap_preprocess(which_subjects);

nslices = 48;
for sub = subjects(which_subjects)
    spatial_preprocessingBatch('dir_base', root, 'dir_spm', '\\blur\infabs\MRI\Analyses\spm', ...
        'subjects', sub, 'n_sess', 6, 'TR', 3.36, 'nslices', nslices, 'sliceorder',[1:1:nslices]);
end

% Check motion
for iSess = 1:6
    CheckMovement(['D:\infabs\MRI\sub31\Functional\sess' int2str(iSess)])
end

%% 4. Univariate First-Level 
% Define KL regressors as well as all 12 conditons for RSA

%% 4.1 Get onsets
cfg = [];
cfg.subjects = subjects(which_subjects);
cfg.TR       = 3.36;
cfg.root     = root;
cfg.dur      = 0.1; 

% KL regressor specific indices
cfg.outDir = 'FirstLevel\KL_reg_onset';
getOnsets_KL_Reg(cfg)

% all 12 conditions for RSA
cfg.outDir = 'FirstLevel\AllConditions';
getOnsets_All_Conditions(cfg)

%% 4.2 Specify and estimate first level
cfg = [];
cfg.subjects = subjects(which_subjects);
cfg.root     = root;
cfg.TR       = 3.36;
cfg.scanDir  = 'Functional';
cfg.scanPrefix  = 'swua*'; % smoothed and normalized

% KL regressors
cfg.FLdir    = 'FirstLevel\KL_reg_onset';
FirstLevelKLregsNuisance(cfg);

% all 12 conditions
cfg.FLdir    = 'FirstLevel\AllConditions';
FirstLevelConditionsNuisance(cfg);

%% 4.3 Define first level contrasts
cfg = []; 
cfg.subjects = subjects(which_subjects);
cfg.root     = root;

% KL regs
cfg.FLdir    = 'FirstLevel\KL_reg_onset';
cfg.tconName  = {'W_level','A_level'};
cfg.tconVec   = {[0 1],[0 0 1]};
DefineContrast(cfg)

% for the twelve conditions
cfg.FLdir    = 'FirstLevel\AllConditions';
cfg.tconName  = {'cond1','cond2','cond3','cond4','cond5','cond6','cond7','cond8','cond9','cond10','cond11','cond12'};
cfg.tconVec   = {[1],[0 1],[0 0 1],[0 0 0 1],[0 0 0 0 1],[0 0 0 0 0 1],[0 0 0 0 0 0 1],[0 0 0 0 0 0 0 1],[0 0 0 0 0 0 0 0 1],[0 0 0 0 0 0 0 0 0 1],[0 0 0 0 0 0 0 0 0 0 1],[0 0 0 0 0 0 0 0 0 0 0 1]};
DefineContrast(cfg)

%% 5. Univeriate Second-Level
% Look at KL regressors at the second level

%% 5.1 One sample t-test with SPM
cfg = [];
cfg.root      = root;
cfg.subjects  = subjects(which_subjects);

cfg.mask      = fullfile(root,'Analyses','ROIs','posterior_maskN.nii');
cfg.dir       = 'FirstLevel\KL_reg_onset';
cfg.contrast  = 'con_0001.nii';
[~, name] = fileparts(cfg.contrast);
cfg.outputDir = fullfile(root,'GroupResults',cfg.dir,name);
SecondLevelOST(cfg)

cfg.mask      = fullfile(root,'Analyses','ROIs','frontal_maskN.nii');
cfg.dir       = 'FirstLevel\KL_reg_onset';
cfg.contrast  = 'con_0002.nii';
[~, name] = fileparts(cfg.contrast);
cfg.outputDir = fullfile(root,'GroupResults',cfg.dir,name);
SecondLevelOST(cfg)

% create mask
cfg = [];
cfg.inputfile = fullfile(root,'GroupResults','FirstLevel','KL_reg_onset','con_0001','spmT_0001.nii');
cfg.threshold = 3.43; % uncorrect t-value p < 0.001
cfg.outputfile = fullfile(root,'Analyses','ROIs','KL_W_visual.nii');
cfg.atlas = fullfile(root,'Analyses','ROIs','AAL','rROI_MNI_V4.nii');
cfg.atlasLabels = 5401;%5022;%[2000:2322, 3001, 3002]; % make mask within this region 
CreateMask(cfg); 

% plot all 12 conditions within mask 
cfg = [];
cfg.root  = root;
cfg.subjects = subjects(which_subjects); 
cfg.FLdir = 'FirstLevel/AllConditions';
cfg.mask  = fullfile(root,'Analyses','ROIs','KL_w_visual.nii');
PlotAllConditions(cfg)

%% 6. Representational similar analysis
% Use RSA to characterize representational structure of A and W level PEs

%% 6.1 Searchlight RSA (first-level)
cfg = [];
cfg.root = root;
cfg.delPrev = false; % delete previous files
cfg.betas = 'FirstLevel/AllConditions'; % betas per condition per run
cfg.radius = 4; % same as decoding
cfg.outputdir = 'RSA/Main'; % just A and W 
for sub = 1:length(which_subjects) % run over subjects
    fprintf('Running subject %s \n',subjects{which_subjects(sub)});
    cfg.subjectID = subjects{which_subjects(sub)};
    SearchlightRSA(cfg);
end

%% 6.2 Get the contrasts
[~,~,RDM_names] = BuildRDMs(1);
dummy           = zeros(length(RDM_names),1);

% contrast RSA
cfg = [];
cfg.root     = root; 
cfg.subjects = subjects(which_subjects);
for c = 1:length(RDM_names)
    cfg.images{c} = sprintf('RSA/Main/%s.nii',RDM_names{c});
    cfg.contrastNames{c} = RDM_names{c};  
    contrastVec = dummy; contrastVec(c) = 1;
    cfg.contrastVecs{c} = contrastVec;
end
RSAcontrasts(cfg);

%% 6.3 Second level
cfg = [];
cfg.root      = root;
cfg.subjects  = subjects(which_subjects);
cfg.mask      = fullfile(root,'resliced_gm.nii');

cfg.dir       = 'RSA/Main';
for c = 1:length(RDM_names)
    cfg.contrast  = [RDM_names{c} '.nii'];
    cfg.outputDir = fullfile(root,'GroupResults',cfg.dir,RDM_names{c});
    SecondLevelOST(cfg)
end

%% 6.4 Multi-dimensional scaling (MDS)
% look at MDS within significant regions
cfg = [];
cfg.root      = root;
cfg.subjects  = subjects(which_subjects);
cfg.betas     = 'FirstLevel/AllConditions'; % betas per condition per run
cfg.RSAdir    = 'GroupResults/RSA';
RSA_MDS_ROIs(cfg); 