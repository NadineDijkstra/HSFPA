function FirstLevelConditionsNuisance(cfg)
% function FirstLevelConditionsNuisance(cfg)
% e.g
% cfg = []; 
% cfg.subjects = subjects;
% cfg.root     = root;
% cfg.FLdir    = 'FirstLevel\Stimulus_Presence2';
% cfg.tconName  = {'presence','absence'};
% cfg.tconVec   = {[1 -1],[-1 1]};


nsubjects = length(cfg.subjects);

for sub = 1:nsubjects
    
    FLdir = fullfile(cfg.root,cfg.subjects{sub},cfg.FLdir);
    scanDir = fullfile(cfg.root,cfg.subjects{sub},cfg.scanDir);
    fprintf('Processing subject %s out of %d \n', cfg.subjects{sub},nsubjects);
    
    %% Model specification
    
    if ~exist(fullfile(FLdir,'SPM.mat'),'file')
        
        % basic info for model set-up
        specification{1}.spm.stats.fmri_spec.dir = {FLdir};
        specification{1}.spm.stats.fmri_spec.timing.units = 'scans';
        specification{1}.spm.stats.fmri_spec.timing.RT = cfg.TR;
        specification{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
        specification{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
        
        % load the onsets etc.
        onsets = str2fullfile(FLdir,'Onsets*');
        nSess  = length(onsets);
        
        % define regressors per session
        for sess = 1:nSess
            
            if strcmp(cfg.subjects{sub}, 'sub32') && sess > 2
                % sub32 has blocks [1, 2, 4, 5]
                fprintf('\t Specifying sessions %d out of %d \n', sess, nSess)
                sessionDir = fullfile(scanDir,sprintf('sess%d',sess + 1));
                regressors = load(fullfile(FLdir,sprintf('Onsets_%d.mat',sess + 1)));
                PhysioFile = dir(fullfile('\\blur\infabs\MRI\', cfg.subjects{sub}, '\Physio\', sprintf('*%d.smr', sess + 1)));
                regrFile = fullfile(sessionDir, sprintf('mov&physio_sess%d.mat', sess + 1));
            else
                fprintf('\t Specifying sessions %d out of %d \n', sess, nSess)
                sessionDir = fullfile(scanDir,sprintf('sess%d',sess));
                regressors = load(fullfile(FLdir,sprintf('Onsets_%d.mat',sess)));
                PhysioFile = dir(fullfile('\\blur\infabs\MRI\', cfg.subjects{sub}, '\Physio\', sprintf('*%d.smr', sess)));
                regrFile = fullfile(sessionDir, sprintf('mov&physio_sess%d.mat', sess));
            end         
            
            % specify the scans
            scans = str2fullfile(sessionDir,cfg.scanPrefix);
            specification{1}.spm.stats.fmri_spec.sess(sess).scans = scans';
            
            % specify the onsets etc for the different regressors
            nRegs      = numel(regressors.names);
            for reg = 1:nRegs
                specification{1}.spm.stats.fmri_spec.sess(sess).cond(reg).name = regressors.names{reg};
                specification{1}.spm.stats.fmri_spec.sess(sess).cond(reg).onset = regressors.onsets{reg};
                specification{1}.spm.stats.fmri_spec.sess(sess).cond(reg).duration = regressors.durations{reg};
                specification{1}.spm.stats.fmri_spec.sess(sess).cond(reg).tmod = 0;
                specification{1}.spm.stats.fmri_spec.sess(sess).cond(reg).pmod = struct('name', {}, 'param', {}, 'poly', {});
                specification{1}.spm.stats.fmri_spec.sess(sess).cond(reg).orth = 1;
            end            
            
            % specify nuisance regressors
            nNuisance = size(regressors.nuisance,2);
            for n = 1:nNuisance                
                specification{1}.spm.stats.fmri_spec.sess(sess).cond(reg+n).name = regressors.nuisance{1,n};
                specification{1}.spm.stats.fmri_spec.sess(sess).cond(reg+n).onset = regressors.nuisance{2,n};
                specification{1}.spm.stats.fmri_spec.sess(sess).cond(reg+n).duration = regressors.nuisance{3,n};
                specification{1}.spm.stats.fmri_spec.sess(sess).cond(reg+n).tmod = 0;
                specification{1}.spm.stats.fmri_spec.sess(sess).cond(reg+n).pmod = struct('name', {}, 'param', {}, 'poly', {});
                specification{1}.spm.stats.fmri_spec.sess(sess).cond(reg+n).orth = 1;
            end
            
            % derivative of realignment parameters
            rpFile = dir(fullfile(sessionDir, 'rp*'));
            fid = fopen(fullfile(rpFile.folder, rpFile.name), 'r');
            rp = fscanf(fid, ' %e %e %e %e %e %e', [6, inf])';
            fclose(fid);
            R = rp;
            R(:, 7:12) = [zeros(1, 6) ; diff(R)];
            
            % physiological regressors
            % Wrong for sub 01-03,
            if ismember(cfg.subjects{sub}, {'sub01', 'sub02', 'sub03'})
                fprintf('Skipping physio regressors for %s\n', cfg.subjects{sub});
            else                 
                
                try
                    P = BuildPhysioVolumeTriggerSMR(fullfile(PhysioFile.folder, PhysioFile.name), 48, 5, 24, 0);
                catch
                    % check physio regressors are the right length, if not use the
                    % stop before option.
                    if length(P) > length(scans')
                        P = BuildPhysioVolumeTriggerSMR(fullfile(PhysioFile.folder, PhysioFile.name), 48, 5, 24, 1);
                        fprintf('Mismatched lengths, used ''stop before'' option\n');
                    elseif length(P) < length(scans')
                        P(end:length(scans'), :) = 0;
                    end
                    R(:, 13:26) = P;
                end
            end
            
            % remove columns where no data was recorded
            emptyColumns = R(2,:)==0; fprintf('\t Columns %s are empty, removing these from R matrix... \n', int2str(find(emptyColumns)))
            R = R(:,~emptyColumns);
            
            % save movement and physio regressors
            save(regrFile, 'R');
            
            % add movement and physiological regressors
            specification{1}.spm.stats.fmri_spec.sess(sess).multi = {''};
            specification{1}.spm.stats.fmri_spec.sess(sess).regress = struct('name', {}, 'val', {});
            specification{1}.spm.stats.fmri_spec.sess(sess).multi_reg = {regrFile};
            specification{1}.spm.stats.fmri_spec.sess(sess).hpf = 128;
            
            % add WM and CSF regressors
            [~,wm_mask] = read_nii(fullfile(cfg.root,'resliced_wm.nii'));
            [~,csf_mask] = read_nii(fullfile(cfg.root,'resliced_csf.nii'));
            wm = zeros(length(scans),1); csf = zeros(length(scans),1);
            for n = 1:length(scans)
                if mod(n,10) == 0
                    fprintf('Calculating wm and csf for scan %d out of %d \n',n,length(scans))
                end
                [~,scan] = read_nii(scans{n});
                wm(n)    = mean(scan(wm_mask>0.7));
                csf(n)   = mean(scan(csf_mask>0.7));
                clear scan
            end
            specification{1}.spm.stats.fmri_spec.sess(sess).regress(1).name = 'wm';
            specification{1}.spm.stats.fmri_spec.sess(sess).regress(1).val = wm;
            specification{1}.spm.stats.fmri_spec.sess(sess).regress(2).name = 'csf';
            specification{1}.spm.stats.fmri_spec.sess(sess).regress(2).val = csf;

            clear scans
        end
        
        specification{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
        specification{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
        specification{1}.spm.stats.fmri_spec.volt = 1;
        specification{1}.spm.stats.fmri_spec.global = 'None';
        specification{1}.spm.stats.fmri_spec.mthresh = 0.8;
        specification{1}.spm.stats.fmri_spec.mask = {''};
        specification{1}.spm.stats.fmri_spec.cvi = 'AR(1)';   
        
        % run the model
        spm_jobman('run',specification)
    end
    
    if ~exist(fullfile(FLdir,'beta_0001.nii'),'file')        
        
        % estimate the model
        spm_file = str2fullfile(FLdir,'SPM.mat');
        estimation{1}.spm.stats.fmri_est.spmmat = {spm_file};
        estimation{1}.spm.stats.fmri_est.method.Classical = 1;
        
        spm_jobman('run',estimation)
        
        fprintf('Running model estimation for subject %d \n',sub)
        
    end
end