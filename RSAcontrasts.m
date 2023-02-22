function RSAcontrasts(cfg)
% function RSAcontrasts(cfg);
%
% define contrast vectors per subject to to test against 0 at the second 
% level with SecondLevelOST.m

nSubs = length(cfg.subjects);
nIma  = length(cfg.images);
nCon  = length(cfg.contrastNames);

RSA_path = fileparts(cfg.images{1});

% loop over subs
for sub = 1:nSubs

    fprintf('Defining contrast images for sub %s \n',cfg.subjects{sub})

    % load images
    images = cell(nIma,1);
    for i = 1:nIma
        [V,images{i}] = read_nii(fullfile(cfg.root,cfg.subjects{sub},...
            cfg.images{i}));
    end

    % define contrasts
    for c = 1:nCon

        conImage = zeros([V.dim nIma]);
        for i = 1:nIma
            conImage(:,:,:,i) = images{i}.*cfg.contrastVecs{c}(i);
        end
        conImage = squeeze(sum(conImage,4)); % combine
        
        % save
        write_nii(V,conImage,fullfile(cfg.root,cfg.subjects{sub},...
            RSA_path,[cfg.contrastNames{c} '.nii']))
    end


end