function DefineContrast(cfg)
% e.g.
% cfg = []; 
% cfg.subjects = subjects;
% cfg.root     = root;
% cfg.FLdir    = 'FirstLevel\Stimulus_Presence2';
% cfg.tconName  = {'presence','absence'};
% cfg.tconVec   = {[1 -1],[-1 1]};

nSubjects = length(cfg.subjects);
if isfield(cfg,'tconName'); nTCons = length(cfg.tconName); else; nTCons = 0; end
if isfield(cfg,'fconName'); nFCons = length(cfg.fconName); else; nFCons = 0; end

for sub = 1:nSubjects
    
    FLdir = fullfile(cfg.root,cfg.subjects{sub},cfg.FLdir);
    spm_file = fullfile(FLdir,'SPM.mat');    
    
    matlabbatch{1}.spm.stats.con.spmmat = {spm_file};
    
    % define the t-contrasts
    for tcon = 1:nTCons
        matlabbatch{1}.spm.stats.con.consess{tcon}.tcon.name = cfg.tconName{tcon};
        matlabbatch{1}.spm.stats.con.consess{tcon}.tcon.weights = cfg.tconVec{tcon};
        matlabbatch{1}.spm.stats.con.consess{tcon}.tcon.sessrep = 'replsc';
    end
    
    % define the f contrasts
    for fcon = 1:nFCons
        matlabbatch{1}.spm.stats.con.consess{fcon+tcon}.fcon.name = cfg.fconName{fcon};
        matlabbatch{1}.spm.stats.con.consess{fcon+tcon}.fcon.weights = cfg.fconVec{fcon};
        matlabbatch{1}.spm.stats.con.consess{fcon+tcon}.fcon.sessrep = 'replsc';
    end
    
    matlabbatch{1}.spm.stats.con.delete = 0;
    
    spm_jobman('run',matlabbatch)
    
end

