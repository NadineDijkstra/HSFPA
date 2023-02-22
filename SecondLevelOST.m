function SecondLevelOST(cfg)
% function SecondLevelOST(cfg)
% Second level One Sample Ttest
% e.g.
% cfg = [];
% cfg.root      = root;
% cfg.subjects  = subjects;
% cfg.dir       = 'FirstLevel\Stimulus_Presence';
% cfg.contrast  = 'con_0002.nii';
% [~, name] = fileparts(cfg.contrast);
% cfg.outputDir = fullfile(root,'GroupResults',cfg.dir,name);
% cfg.mask      = fullfile(root,'resliced_gm_mask.nii');


% get images 
nsubjects = length(cfg.subjects);
images = cell(nsubjects,1);
for sub = 1:nsubjects
    images{sub} = str2fullfile(fullfile(cfg.root,cfg.subjects{sub},cfg.dir),...
        cfg.contrast);
end

% specification
specification{1}.spm.stats.factorial_design.dir = {cfg.outputDir};
specification{1}.spm.stats.factorial_design.des.t1.scans = images;
specification{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
specification{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
specification{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
specification{1}.spm.stats.factorial_design.masking.im = 1;
specification{1}.spm.stats.factorial_design.masking.em = {cfg.mask};
specification{1}.spm.stats.factorial_design.globalc.g_omit = 1;
specification{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
specification{1}.spm.stats.factorial_design.globalm.glonorm = 1;

% run the model
spm_jobman('run',specification)

% estimate the model
spm_file = str2fullfile(cfg.outputDir,'SPM.mat');
estimation{1}.spm.stats.fmri_est.spmmat = {spm_file};
estimation{1}.spm.stats.fmri_est.method.Classical = 1;

spm_jobman('run',estimation)

% define the contrast to get t-values
getcontrast{1}.spm.stats.con.spmmat = {spm_file};
getcontrast{1}.spm.stats.con.consess{1}.tcon.name = 'main';
getcontrast{1}.spm.stats.con.consess{1}.tcon.weights = 1;
getcontrast{1}.spm.stats.con.delete = 1;

spm_jobman('run',getcontrast)