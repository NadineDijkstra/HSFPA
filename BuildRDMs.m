function [RDMs,reorder_vec,RDM_names] = BuildRDMs(nRuns)
% RDMs for HOSS imaging
%
% Uses code from Timo Flesch
% https://github.com/TimoFlesch/fmri_utils/blob/master/RSA/compute/fmri_rsa_compute_rdmSet_cval.m
%
% Steve Fleming 2021, adapted by Nadine Dijkstra 2022

addpath('D:\INFABS\MRI\Analyses\rsatoolbox-develop');
import rsa.*
import rsa.rdm.*

RDM_names = {'A PE','W PE',...
    'A prior','W prior','W stim'};

%% Reorder conditions to reflect nested hierarchy
% Now is condition x run x voxel where conditions are:
%    1 - {'prFace_Face'  }
%    2 - {'prHouse_Face' }
%    3 - {'abFace_Face'  }
%    4 - {'abHouse_Face' }
%    5 - {'prFace_House' }
%    6 - {'prHouse_House'}
%    7 - {'abFace_House' }
%    8 - {'abHouse_House'}
%    9 - {'prFace_Noise' }
%    10 - {'prHouse_Noise'}
%    11 - {'abFace_Noise' }
%    12 - {'abHouse_Noise'}

% New order (A, W, stim):
%    1 - {'prFace_Face'  }
%    5 - {'prFace_House' }
%    9 - {'prFace_Noise' }
%    2 - {'prHouse_Face' }
%    6 - {'prHouse_House'}
%    10 - {'prHouse_Noise'}
%    3 - {'abFace_Face'  }
%    7 - {'abFace_House' }
%    11 - {'abFace_Noise' }
%    4 - {'abHouse_Face' }
%    8 - {'abHouse_House'}
%    12 - {'abHouse_Noise'}

orthog = 0;
distance = 'euclidean';
reorder_vec = [1 5 9 2 6 10 3 7 11 4 8 12];

%% Build component model RDMs
% Stimulus encoding
A_stim = repmat([1 1 0; 1 1 0; 0 0 1],4,4); % don't need this because
% strongly correlated with W_stim
W_stim = repmat(eye(3),4,4);

% Prior encoding
W_prior = repmat([ones(3,3) zeros(3,3); zeros(3,3) ones(3,3)],2,2);
A_prior = [ones(6,6) zeros(6,6); zeros(6,6) ones(6,6)];

% Prediction error encoding
A_PE = [repmat([0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 1 0 0 1],2,1), repmat([0 0 0 0 0 0; 0 0 0 0 0 0; 1 1 0 1 1 0],2,1); ...
    repmat([0 0 1 0 0 1; 0 0 1 0 0 1; 0 0 0 0 0 0],2,1), repmat([1 1 0 1 1 0; 1 1 0 1 1 0; 0 0 0 0 0 0],2,1)];
W_PE = repmat([0 0 0 0 0 0; 0 1 0 1 0 0; 0 0 0 0 0 0; 0 1 0 1 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0],2,2);

%% Show RDMs
showRDMs = false;
if showRDMs
    figure;
    subplot(1,5,1);
    imagesc(1-W_prior); title('W prior'); axis square;
    subplot(1,5,2);
    imagesc(1-A_prior); title('A prior'); axis square;
    subplot(1,5,3);
    imagesc(1-W_stim); title('W stim'); axis square;
    subplot(1,5,4);
    imagesc(1-W_PE); title('W PE'); axis square;
    subplot(1,5,5);
    imagesc(1-A_PE); title('A PE'); axis square;
    colormap('summer');
end
%% Collect regressors
rdmSet = cat(3,repmat(A_PE,nRuns,nRuns),repmat(W_PE,nRuns,nRuns),...   
    repmat(A_prior,nRuns,nRuns),repmat(W_prior,nRuns,nRuns),...
    repmat(W_stim,nRuns,nRuns));

%% Build RDM regressors - concatenate A and W predictors
if orthog
    % Orthogonalise W and A sets separately then concatenate
    rdmSet = fmri_helper_orthogonaliseModelRDMs(rdmSet);
end

RDMs = [];
for i = 1:size(rdmSet, 3)
    RDMs = [RDMs vectorizeRDM(squeeze(rdmSet(:,:,i)))'];
end

%% CONVERT TO DISTANCE
RDMs = 1-RDMs;

% zscore
RDMs = zscore(RDMs);