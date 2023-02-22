function getOnsets_PerTrial(cfg)
% Valid / Invalid regressors
% Type indicates identity or presence

nuisance = {'cue','response'};

nSubjects = length(cfg.subjects);

for SID = 1:nSubjects

    % Find behavioural data
    behDir = fullfile(cfg.root, cfg.subjects{SID}, 'raw', 'Behaviour');
    behFiles = dir(fullfile(behDir, 'results_block*'));
    outDir = fullfile(cfg.root, cfg.subjects{SID}, cfg.outDir);
    if ~exist(outDir,'dir'); mkdir(outDir); end
    
    % Extract onsets and durations for each block
    for iBlock = 1:length(behFiles)
        
        if strcmp(cfg.subjects{SID}, 'sub32') && iBlock == 3
            continue;
        end
        
        file  = sprintf('Onsets_%d.mat', iBlock);
        load(fullfile(behDir, behFiles(iBlock).name),'trials','results');
        start = results.startTime;
        
        nTrials = length(trials); names = cell(nTrials,1);
        for iTrial = 1:nTrials
            names{iTrial} = sprintf('T%d', iTrial);
        end
        
        onsets = cell(length(names),1);
        durations = cell(length(names),1);
        
        % Get onsets        
        for iTrial = 1:length(names)
            onsets{iTrial,1} = results.presTime(iTrial, 3) - start;
        end
        
        % Convert to scans
        for i = 1:length(names)
            onsets{i} = onsets{i} / cfg.TR;
            durations{i} = zeros(length(onsets{i}),1)+cfg.dur;
        end
        
         % Get nuisance regressors
        nuisance{2,1} = (results.presTime(:,1) - start) / cfg.TR;  % cue onset
        nuisance{3,1} = ones(length(results.presTime),1)*0.5; 
        
        response_idx  = trials(:,5)==1; % responses catch trials 
        nuisance{2,2} = (results.presTime(response_idx,3) - start + ...
            results.RT(response_idx)) / cfg.TR;
        nuisance{3,2} = ones(sum(response_idx),1)*0.1;
        
        % Save to cond file 
        save(fullfile(outDir, file), 'names', 'onsets', 'durations','nuisance');
    end
end