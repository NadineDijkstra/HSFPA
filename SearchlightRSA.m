function SearchlightRSA(cfg)
% function SearchlightRSA(cfg)
%

if strcmp(cfg.subjectID, 'sub32')
    nSess = 4;
else
    nSess = 6;
end

% Output Dir
outputDir = fullfile(cfg.root,cfg.subjectID,cfg.outputdir);
if ~exist(outputDir,'dir'); mkdir(outputDir); end

% Delete previous files
if cfg.delPrev
    prev_files = str2fullfile(outputDir,'*.nii');
    if ~isempty(prev_files)
        fprintf('Deleting previous files \n')
        for f = 1:length(prev_files)
        delete(prev_files{f})
        end
    end
end

% Get the RDM regressors
[RDMs,reorder_vec,RDM_names] = BuildRDMs(nSess);
nConds = length(reorder_vec);

nRDMs  = size(RDMs,2);

% Which distance to use
distance = 'euclidean';

zscor_xnan = @(x) bsxfun(@rdivide, bsxfun(@minus, x, mean(x,'omitnan')), std(x, 'omitnan'));

%% Get the searchlight indices
slradius = cfg.radius;

% load grey matter mask and functional
[~,GM]     = read_nii('\\blur\infabs\MRI\resliced_gm.nii');
[~,stat_mask] = read_nii(fullfile(cfg.root,cfg.subjectID,cfg.betas,'mask.nii'));
mask       = squeeze(GM > 0.1 & stat_mask>0);

% infer the searchlight indices
[~,mind,cind] = searchlightIndices(mask,slradius);

nSearchlights = length(mind);

%% Get the neural betas
% condition info
load(fullfile(cfg.root,cfg.subjectID,cfg.betas,'SPM.mat'),'SPM');

% collect betas per condition and per run
betas   = zeros(nConds,nSess,sum(mask(:)));
for s = 1:nSess    

    % cond idx
    % sub32 has blocks [1, 2, 4, 5]
    sess = s;
    if strcmp(cfg.subjectID, 'sub32')
        if s == 3 || s ==4
            sess = s + 1;
        end
    end
    cond_idx = find(contains(SPM.xX.name(:),sprintf('Sn(%d)',sess)));
    cond_idx = cond_idx(1:nConds); % first 12 regressors;      
            
    % loop over conditions
    for c = 1:nConds
        cond_id = cond_idx(c);
        [hdr,tmp] = read_nii(fullfile(cfg.root,cfg.subjectID,...
            cfg.betas,sprintf('beta_%04d.nii', cond_id)));
        betas(c,s,:) = tmp(mask>0);
    end    
end

% reoder conditions
betas = betas(reorder_vec,:,:);

%% Do RSA per searchlight
RSA_betas = cell(nRDMs,1); 
for n = 1:numel(RSA_betas)
    RSA_betas{n} = zeros(size(mask));
end
for s = 1:nSearchlights

    if s >= (nSearchlights/10) && mod(s,round((nSearchlights/10))) == 0
        fprintf('\t Progress: %d percent of searchlights \n',round((s/nSearchlights)*100))
    end

    % create neural RDM
    searchlight_act = betas(:,:,mind{s});

    % concatenate runs:
    b = squeeze(searchlight_act(:,1,:));
    for runID = 2:size(searchlight_act,2)
        b = cat(1,b,squeeze(searchlight_act(:,runID,:)));
    end

    % calculate RDM
    neural_RDM = squareform(pdist(b,distance));

    % nan all within run comparisons
    nConds = size(searchlight_act,1);
    nRuns = size(searchlight_act,2);
    for iiRun = 1:nConds:(nConds*nRuns)
        neural_RDM(iiRun:iiRun+nConds-1,iiRun:iiRun+nConds-1) = NaN;
    end

    % vectorize and zscore
    neural_RDM = rsa.rdm.vectorizeRDM(neural_RDM);
    neural_RDM = zscor_xnan(neural_RDM)';
    
    % regression
    regBetas = glmfit(RDMs,neural_RDM,'normal');

    % save non-constant betas
    for r = 1:nRDMs
        RSA_betas{r}(cind{s}) = regBetas(r+1);
    end

end

%% Write niftis of betas
for r = 1:nRDMs
    write_nii(hdr,RSA_betas{r},fullfile(outputDir,[RDM_names{r} '.nii']));
end

