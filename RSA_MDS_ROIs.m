function RSA_MDS_ROIs(cfg)
% function RSA_MDS_ROIs(cfg);
%
% plots the representational structure of the data within the ROIs that
% revealed a significant effect in the searchlight RSA analysis (see
% 'searchlightRSA.m' for more details).
%
% cfg is a configuration structure containing the following fields
% cfg.root      = root directory
% cfg.subjects  = cell array with subject identifiers
% cfg.betas     = location of the first-level results containing betas per condition per run
% cfg.RSAdir    = directory where second level RSA results are saved on
% which to base the ROI selection

% Some utils
distance = 'euclidean';
zscor_xnan = @(x) bsxfun(@rdivide, bsxfun(@minus, x, mean(x,'omitnan')), std(x, 'omitnan'));
[~,reorder_vec] = BuildRDMsJustAandW(1);
shortCondNames = {'pFF','pFH','pFN','pHF','pHH','pHN',...
    'aFF','aFH','aFN','aHF','aHH','aHN'}; % based on new order

%% Which ROI(s) to plot?
ROInames{1} = {'Rectus_L','Rectus_R'};
ROInames{2} = {'Calcarine_L','Calcarine_R','Lingual_L','Lingual_R'};
ROInames{3} = {'Rectus_L','Rectus_R'};
ROInames{4} = {'Calcarine_L','Calcarine_R','Lingual_L','Lingual_R'};
Tmaps{1}    = fullfile('GroupResults','RSA','Main','A prior','spmT_0001.nii');
Tmaps{2}    = fullfile('GroupResults','RSA','Main','W stim','spmT_0001.nii');
Tmaps{3}    = fullfile('GroupResults','RSA','Main','A PE','spmT_0001.nii');
Tmaps{4}    = fullfile('GroupResults','RSA','Main','W PE','spmT_0001.nii');
nROIs       = length(ROInames);
ROI_vois     = cell(nROIs,1);

% getting the volume indices (vois)
cfgROI = [];
cfgROI.root = root;
cfgROI.atlas = 'D:\Templates\Templates\atlas\aal';
cfgROI.tthresh = 5.98;

for r = 1:nROIs
    cfgROI.atlasNames = ROInames{r};
    cfgROI.tmap = Tmaps{r};
    [ROI_vois{r}] = GetROIindices(cfgROI);
end

%% Get neural RDMs per region per subject
nSubjects = length(cfg.subjects);
nConds    = 12; nRDMs = 5;
neural_RDMs = zeros(nROIs,nSubjects,nConds,nConds);
regBetas   = zeros(nROIs,nSubjects,nRDMs);

for sub = 1:nSubjects

    fprintf('Calculating RDM for subject %d/%d \n',sub,nSubjects)

    % get betas
    if strcmp(cfg.subjects{sub}, 'sub32')
        nSess = 4;
    else
        nSess = 6;
    end

    % get predictor RDMs
    RDMs = BuildRDMsJustAandWDis(nSess);

    % condition info
    load(fullfile(cfg.root,cfg.subjects{sub},cfg.betas,'SPM.mat'),'SPM');

    % collect betas per condition and per run
    ROIbetas   = cell(nROIs,1);
    for r = 1:nROIs; ROIbetas{r}   = zeros(nConds,nSess,sum(ROI_vois{r}(:))); end
    
    for s = 1:nSess

        % cond idx
        % sub32 has blocks [1, 2, 4, 5]
        sess = s;
        if strcmp(cfg.subjects{sub}, 'sub32')
            if s == 3 || s ==4
                sess = s + 1;
            end
        end
        cond_idx = find(contains(SPM.xX.name(:),sprintf('Sn(%d)',sess)));
        cond_idx = cond_idx(1:nConds); % first 12 regressors;

        % loop over conditions
        for c = 1:nConds
            cond_id = cond_idx(c);
            [hdr,tmp] = read_nii(fullfile(cfg.root,cfg.subjects{sub},...
                cfg.betas,sprintf('beta_%04d.nii', cond_id)));
            for r = 1:nROIs
                ROIbetas{r}(c,s,:) = tmp(ROI_vois{r}>0);
            end
        end
    end

    % reoder conditions
    for r = 1:nROIs
        ROIbetas{r} = ROIbetas{r}(reorder_vec,:,:);
    end

    %% Get RDM per ROI
    for r = 1:nROIs

        % concatenate runs
        b = squeeze(ROIbetas{r}(:,1,:));
        for runID = 2:size(ROIbetas{r},2)
            b = cat(1,b,squeeze(ROIbetas{r}(:,runID,:)));
        end

        % remove all nans
        b = b(:,~any(isnan(b)));

        % calculate RDM
        neural_RDM = squareform(pdist(b,distance));

        % nan all within run comparisons
        for iiRun = 1:nConds:(nConds*nSess)
            neural_RDM(iiRun:iiRun+nConds-1,iiRun:iiRun+nConds-1) = NaN;
        end

        % zscore
        %neural_RDM = (neural_RDM-nanmean(neural_RDM(:)))./nanstd(neural_RDM(:));

        % do the GLMs to compare
        b = glmfit(RDMs, zscor_xnan(rsa.rdm.vectorizeRDM(neural_RDM))', 'normal');
        regBetas(r,sub,:) = b(2:end);

        % average over runs
        tmp = reshape(neural_RDM,[nConds,nSess,nConds,nSess]);
        tmp = squeeze(nanmean(nanmean(tmp,4),2)); 
        tmp(1:(nConds+1):end) = nan; % nan diagonal
        neural_RDMs(r,sub,:,:) = tmp;
    end

end

%% Plot the results
[~,~,RDM_names] = BuildRDMsJustAandW(1);
reorder_RDMs = [4 3 5 2 1]; RDM_names = RDM_names(reorder_RDMs);
regBetas = regBetas(:,:,reorder_RDMs);

newCondOrder = {'aFH','aHF','pFH','pHF','pFN','pHN','aFF','aHH','pFF','pHH','aFN','aHN'};
reorderCond = nan(nConds,1); for c = 1:nConds; reorderCond(c) = find(contains(shortCondNames,newCondOrder{c})); end

ROInames = {'A prior','W stim','A PE',' W PE'};
for r = 1:nROIs
    
    % results regression
    figure(r);
    subplot(2,2,1); % betas
    errorbar(squeeze(mean(regBetas(r,:,:),2)),...
        squeeze(std(regBetas(r,:,:)))./sqrt(nsubjects),'k')
    set(gca, 'XLim', [0 nRDMs+1], 'XTick', 1:nRDMs, 'XTickLabel', RDM_names)
    title(ROInames{r}); ylabel('beta'); ylim([-0.07 0.02])

    % RDMs
    mean_RDM = squeeze(mean(neural_RDMs(r,:,:,:),2));        

    % MDS
    mean_RDM(1:(nConds+1):end) = 0;

    figure(r); subplot(2,2,2);
    Y = cmdscale(mean_RDM,2);
    scatter(Y(:,1),Y(:,2),40,'filled')
    text(Y(:,1),Y(:,2)+1,shortCondNames);
      
end







