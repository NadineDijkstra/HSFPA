function CreateMask(cfg)
% CreateMask(cfg)
%
% cfg.inputfile = map to base mask on
% cfg.threshold = if negative < if positive > 
% cfg.outputfile = where to write the output
% cfg.atlas = (optional) use atlas region to mask within
% cfg.atlasLabels = (optional) - which atlas regions to use


% get the map
[hdr,map] = read_nii(cfg.inputfile);

% threshold
if cfg.threshold < 0 
    thresholded_map = map < cfg.threshold;
elseif cfg.threshold > 0 
    thresholded_map = map > cfg.threshold;
end

% mask within atlas region
if isfield(cfg,'atlas') && isfield(cfg,'atlasLabels')
    [hdrA,atlas] = read_nii(cfg.atlas);

    if any(hdrA.dim ~= hdr.dim)
        fprintf('Altas is not in same dimension as map, reslicing... \n')
        matlabbatch{1}.spm.spatial.coreg.write.ref = {cfg.inputfile};
        matlabbatch{1}.spm.spatial.coreg.write.source = {cfg.atlas};
        matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 0;
        matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
        matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
        matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'r';
        spm_jobman('run',matlabbatch)

        [atlas_dir,atlas_name] = fileparts(cfg.atlas);
        new_atlas = fullfile(atlas_dir,['r' atlas_name '.nii']);
        [hdrA,atlas] = read_nii(new_atlas);
    end

    % find atlas region
    atlas_mask = ismember(atlas,cfg.atlasLabels);
    if sum(atlas_mask(:))==0
        warning('No voxels matching atlas found... \n')
    end

    % mask within
    thresholded_map = thresholded_map & atlas_mask;
end

% check if anything survives
if sum(thresholded_map(:)) == 0
    error('No voxels survived!')
else
    % write mask
    write_nii(hdr,thresholded_map,cfg.outputfile)
end
