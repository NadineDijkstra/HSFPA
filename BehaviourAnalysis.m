function BehaviourAnalysis(cfg)

for sub = 1:length(cfg.subjects)
    
    disp(cfg.subjects(sub));
    
%% get the data - in scanner
data = str2fullfile(fullfile(cfg.subjects{sub},cfg.outputDir),'results*.mat');

if ~iscell(data); tmp = data; clear data; data{1} = tmp; clear tmp; end
T = []; RT = []; C = []; presTimes = []; targetDetection = zeros(length(data),2);
targetCatchTrials = []; tc_vec = [];
for d = 1:length(data)
    
    if strcmp(cfg.subjects{sub}, 'sub32') && d == 3
        continue
    end
    
    load(data{d},'trials','results');
    target(:,1) = trials(:,4); % presented
    
    P = trials(:,2) == 1; F = trials(:,3) == 1; % cued
    target(P&F,2) = 1; % prFace 
    target(P&~F,2) = 2; % prHouse 
    target(~P&F,2) = 3; % absFace
    target(~P&~F,2) = 4; % absHouse
    
    T = [T; target]; clear target
    RT = [RT; results.RT];
    C = [C; results.correct];    
    
    tmp(:,1) = results.presTime(:,2)-results.presTime(:,1); % cue presentation
    tmp(:,2) = results.presTime(:,4)-results.presTime(:,3); % target presentations
    presTimes = cat(1,presTimes,tmp);    
    
    tC = sum(results.correct(trials(1:length(results.correct),5)==1))/sum(trials(:,5)==1); 
    ntC = sum(results.correct(trials(1:length(results.correct),5)==0))/sum(trials(:,5)==0);
    targetDetection(d,1) = tC; targetDetection(d,2) = ntC;
    targetCatchTrials = [targetCatchTrials; trials(:,5)];
    
    tc_vec = [tc_vec, tC];
    
    fprintf('Block %d: target-trials %.2f correct - non-target-trials %.2f correct \n',d,tC,ntC);
    clear target results
end

% Some subjects had error recording correct on the very last trial. 
% Remove it from all arrays
if length(C) ~= length(RT)
    RT = RT(1:end - 1);
    T = T(1:end - 1, :);
    targetCatchTrials = targetCatchTrials(1:end - 1);
    presTimes = presTimes(1:end - 1, :);  
end

mean(tc_vec)
%% get accuracy and RT per condition - in scanner
condRT = zeros(4,3); condAcc = zeros(4,3); condIES = zeros(4,3); condTargetRT = zeros(4,3);
t = T; t(t(:,1)==0,1) = 3;
for cue = 1:4
    for target = 1:3
        idx = (t(:,2) == cue) & (t(:,1) == target);
        condRT(cue,target) = mean(RT(idx & C==1)); % only look at correct responses
        condAcc(cue,target) = mean(C(idx));
        condIES(cue,target) = condRT(cue,target)/condAcc(cue,target);
        condTargetRT(cue,target) = mean(RT(idx & targetCatchTrials==1));
    end
end

exp_A = (ismember(t(:,2),[1 2]) & ismember(t(:,1),[1,2])) | (ismember(t(:,2),[3 4]) & t(:,1)==3);
unexp_A = (ismember(t(:,2),[1 2]) & t(:,1) == 3) | (ismember(t(:,2),[3 4]) & ismember(t(:,1), [1,2]));    
exp_W = (ismember(t(:,2),[1 3]) & t(:,1) == 1) | (ismember(t(:,2),[2 4]) & t(:,1) == 2);
unexp_W = (ismember(t(:,2),[1 3]) & t(:,1) == 2) | (ismember(t(:,2),[2 4]) & t(:,2) == 1); 

targetRT(1) = mean(RT(exp_A & targetCatchTrials==1)); targetRT(2) = mean(RT(unexp_A & targetCatchTrials==1));
targetRT(3) = mean(RT(exp_W & targetCatchTrials==1)); targetRT(4) = mean(RT(unexp_W & targetCatchTrials==1));

%% calculate timing errors
timingErrors = find( (abs(presTimes(:,1)-0.5)>0.1) | (abs(presTimes(:,2)-0.1)>0.05) );

%% save 
outputDir = fullfile(cfg.root,cfg.subjects{sub},cfg.outputDir);
save(fullfile(outputDir,'B'),'T','C','condRT','condAcc','condIES','condTargetRT','targetRT', 'timingErrors','targetDetection');

clearvars -except cfg sub


end
