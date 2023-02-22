function getOnsets_All_Conditions(cfg)
% onsets and durations for each cue - target combination

nuisance = {'cue','response'};

cueNames = {'prFace','prHouse','abFace','abHouse'};
targetNames = {'Face','House','Noise'};

nSubjects = length(cfg.subjects);


for SID = 1:nSubjects

    onsets = cell(length(cueNames), length(targetNames));
    durations = cell(length(cueNames), length(targetNames));
    names  = cell(length(cueNames), length(targetNames));

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
        load(fullfile(behDir, behFiles(iBlock).name), 'trials', 'results');
        start = results.startTime;
        
        % Cue indices
        cue{1} = trials(:, 2) == 1 & trials(:, 3) == 1; % prFace
        cue{2} = trials(:, 2) == 1 & trials(:, 3) == 0; % prHouse
        cue{3} = trials(:, 2) == 0 & trials(:, 3) == 1; % abFace
        cue{4} = trials(:, 2) == 0 & trials(:, 3) == 0; % abHouse
        
        % Stim indices
        stim{1} = trials(:, 4) == 1; % Face
        stim{2} = trials(:, 4) == 2; % House
        stim{3} = trials(:, 4) == 0; % Noise
        
        % Assign trials to conditions
        for c = 1:length(cueNames)
            for t = 1:length(targetNames)
                trl_idx = cue{c} & stim{t};
                onsets{c,t} = (results.presTime(trl_idx,3)-start)/cfg.TR;
                durations{c,t} = zeros(length(onsets{c,t}),1)+cfg.dur;
                names{c,t} = sprintf('%s_%s',cueNames{c},targetNames{t});
            end
        end      

                
        % Get nuisance regressors
        nuisance{2,1} = (results.presTime(:,1) - start) / cfg.TR;  % cue onset
        nuisance{3,1} = ones(length(results.presTime),1)*0.5; 
        
        response_idx  = trials(:,5)==1;
        nuisance{2,2} = (results.presTime(response_idx,3) - start + ...
            results.RT(response_idx)) / cfg.TR;
        nuisance{3,2} = ones(sum(response_idx),1)*0.1;
        
        % Save to cond file 
        save(fullfile(outDir, file), 'onsets', 'durations','nuisance','names');
    end
end