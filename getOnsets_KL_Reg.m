function getOnsets_KL_Reg(cfg)
% onsets and durations for each cue - target combination

nuisance = {'cue','response'};

onsets = [];
durations = [];

nSubjects = length(cfg.subjects);
load(fullfile(cfg.root,'Analyses','KL_vectors'),'KL_A_vector','KL_W_vector');


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
        
        % Work out which trials were valid
        onsets = results.presTime(:,3)-start;
        onsets = onsets / cfg.TR;
        durations = zeros(length(onsets),1)+cfg.dur;
        
        pmod{1} = nan(length(onsets),1);
        pmod{2} = nan(length(onsets),1);
        
        for c = 1:4
            for t = 1:3
                pmod{1}(cue{c}&stim{t}) = KL_W_vector(c,t);
                pmod{2}(cue{c}&stim{t}) = KL_A_vector(c,t);
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
        save(fullfile(outDir, file), 'onsets', 'durations','nuisance','pmod');
    end
end