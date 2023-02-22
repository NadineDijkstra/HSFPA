%% Simulate trial sequence for imaging experiment with variable priors
% on presence/absence and category

clear all

% targets
mu = [0.5 1.5; 1.5 0.5; 0.5 0.5];  % possible Gaussians over X corresponding to each world state

% priors
Aprior = [0.8 0.2];
Wprior = [0.8 0.2];

% settings
Ntrials = 600;
Nsubj = 30;
Sigma = [0.1 0; 0 0.1]; 

% Index into mu (target)
cond = [ones(1,Ntrials/3) ones(1,Ntrials/3).*2 ones(1,Ntrials/3).*3];

acc    = zeros(Nsubj,4,3); % per condition

KL_A_group = []; KL_w_group = []; 
decision_group = []; cue_group = []; cond_group = []; correct_group = []; 
for s = 1:Nsubj

    % Generate sensory samples
    for i = 1:length(cond)
        X(i,:) = mvnrnd(mu(cond(i),:), Sigma, 1);
    end

    j=1; % for all four kinds of cues
    for a = 1:length(Aprior)
        for w = 1:length(Wprior)

            % Invert model for each trial under different priors
            decisionA = []; decisionW = [];
            for i = 1:length(cond)
                [post_w, post_A, KL_w(i), KL_A(i)] = HOSS_evaluate(X(i,:), mu, Sigma, Aprior(a), Wprior(w));
                decisionA(i) = post_A(2) > 0.5;
                decisionW(i) = post_w(1) >= post_w(2);             
                
                cue_group = [cue_group, j];%
            end
            cond_group = [cond_group, cond];
                        
            % compute decision
            decision = zeros(1,length(cond));
            decision(decisionA == 1 & decisionW == 1) = 1;
            decision(decisionA == 1 & decisionW == 0) = 2;
            decision(decisionA == 0) = 3;            
           
            % compute accuracy
            C = decision == cond; 
            for r = 1:3
                acc(s,j,r) = sum(cond==r & C)/sum(cond==r);
            end            
            
            % calculate surpisal
            KL_A_group = [KL_A_group,KL_A];
            KL_w_group = [KL_w_group,KL_w];

            % decisions
            decision_group = [decision_group, decision];
            correct_group  = [correct_group, C];         
            
             % We only take correct trials here 
            KL_w_vector(j,1,s) = mean(KL_w(decision == 1 & C));
            KL_A_vector(j,1,s) = mean(KL_A(decision == 1 & C));
            KL_w_vector(j,2,s) = mean(KL_w(decision == 2 & C));
            KL_A_vector(j,2,s) = mean(KL_A(decision == 2 & C));
            KL_w_vector(j,3,s) = mean(KL_w(decision == 3 & C));
            KL_A_vector(j,3,s) = mean(KL_A(decision == 3 & C));            
            
            clear KL_A KL_W
            j=j+1;
        end
    end
    
end

%% Plot KL all conditions
mean_KL_w_vector = nanmean(KL_w_vector, 3);
sem_KL_w_vector = nanstd(KL_w_vector, 0, 3)./sqrt(Nsubj);
mean_KL_A_vector = nanmean(KL_A_vector, 3);
sem_KL_A_vector = nanstd(KL_A_vector, 0, 3)./sqrt(Nsubj);

figure; 
subplot(2,1,1)
barwitherr(sem_KL_w_vector,mean_KL_w_vector)
legend('a1/w1', 'a1/w2', 'a0')
set(gca, 'XTick', 1:4, 'XTickLabel', {'a1w1', 'a1w2', 'a0w1', 'a0w2'})
title('w layer');
subplot(2,1,2)
barwitherr(sem_KL_A_vector,mean_KL_A_vector)
legend('a1/w1', 'a1/w2', 'a0')
set(gca, 'XTick', 1:4, 'XTickLabel', {'a1w1', 'a1w2', 'a0w1', 'a0w2'})
title('A layer')

save KL_vectors mean_KL_w_vector mean_KL_A_vector