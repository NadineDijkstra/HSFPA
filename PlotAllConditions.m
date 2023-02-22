function PlotAllConditions(cfg)

nSub = length(cfg.subjects);

cueNames = {'prFace','prHouse','abFace','abHouse'};
targetNames = {'Face','House','Noise'};
Act  = nan(nSub,length(targetNames),length(cueNames)); 

% get the mask indices
[~,mask] = read_nii(cfg.mask);
mask = mask > 0;

%Act = nan(nSub,12);

% get contrasts all conditions
for sub = 1:nSub
    
    fprintf('Getting data for subject %d out of %d...\n',sub,nSub)
    
    counter = 1;
    for target = 1:length(targetNames)
        for cue = 1:length(cueNames)
            [~,tmp] = read_nii(fullfile(cfg.root,cfg.subjects{sub},...
                cfg.FLdir,sprintf('spmT_%04d.nii',counter)));
            Act(sub,target,cue) = mean(tmp(mask(:)));
            %Act(sub,counter) = mean(tmp(mask(:)));
            counter = counter + 1;
            
        end
    end

    % zscore per subject
    Act(sub,:) = zscore(Act(sub,:));
end

% plot the things
% all 12 conditions
figure;
subplot(2,2,1:2)
barwitherr(squeeze(std(Act,1))'./sqrt(nSub),squeeze(mean(Act,1))');
set(gca,'XTickLabels',cueNames);
legend(targetNames);
title('All conditions')

% expectations A
exp = [1,1; 1,2; 2,1; 2,2; 3,3; 3,4];
unexp = [1,3; 1,4; 2,3; 2,4; 3,1; 3,2];
expA = []; unexpA = [];
for i = 1:size(exp,1)
    expA = [expA, squeeze(Act(:,exp(i,1),exp(i,2)))];
    unexpA = [unexpA, squeeze(Act(:,unexp(i,1),unexp(i,2)))];
end
expA = squeeze(mean(expA,2)); unexpA = squeeze(mean(unexpA,2));
subplot(2,2,3);
barwitherr([std(expA-unexpA)]./sqrt(nSub),[mean(expA-unexpA)])
ylabel('Expected-unexpected')
[~,p,~,stats] = ttest(expA,unexpA);
title(sprintf('Expectations A, t(%d) = %.3f, p: %.8f',stats.df,stats.tstat,p));
ylim([-0.6 0.6])

% expectations W 
exp = [1,1; 1,3; 2,2; 2,4];
unexp = [1,2; 1,4; 2,1; 2,3];
expW = []; unexpW = [];
for i = 1:size(exp,1)
    expW = [expW, squeeze(Act(:,exp(i,1),exp(i,2)))];
    unexpW = [unexpW, squeeze(Act(:,unexp(i,1),unexp(i,2)))];
end
expW = squeeze(mean(expW,2)); unexpW = squeeze(mean(unexpW,2));
subplot(2,2,4);
barwitherr([std(expW-unexpW)]./sqrt(nSub),[mean(expW-unexpW)])
ylabel('Expected-unexpected')
[~,p,~,stats] = ttest(expW,unexpW);
title(sprintf('Expectations W, t(%d) = %.3f, p: %.8f',stats.df,stats.tstat,p));
ylim([-0.6 0.6])


