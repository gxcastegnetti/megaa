%% megaa_bf_avgOutput
% Takes subjective chi-squared nifti maps computed by the beamformer and
% average them across subjects in a new nifti file.

clear
close all

restoredefaultpath, clear RESTOREDEFAULTPATH_EXECUTED
fs = filesep;

addpath('/Users/gcastegnetti/Desktop/tools/matlab/spm12')

spm eeg

subs = [1:5 7:9 11:25];
folder = '/Users/gcastegnetti/Desktop/stds/MEGAA/analysis/MEG_data/bf/freq1-49';

filenames = spm_select('List', folder, '^mv.*\.nii$');

for s = 1:numel(subs)
    
    chiMapFile = [folder filesep filenames(s,:)];
    chiMap(:,:,:,s) = spm_read_vols(spm_vol(chiMapFile));
    
end

chiMapMetadata = spm_vol(chiMapFile);
chiMapMetadata.fname = [folder,filesep,'chiMapAvg.nii'];

% Write chi-map
% --------------------------------------------------
% spm_write_vol(chiMapMetadata, nanmean(chiMap,4));

% Create t-map
% --------------------------------------------------
tMap = zeros(size(chiMap,1),size(chiMap,2),size(chiMap,3));
for x = 1:size(chiMap,1)
    disp(['x = ',num2str(x)])
    for y = 1:size(chiMap,2)
        for z = 1:size(chiMap,3)
            if ~isnan(sum(chiMap(x,y,z,:)))
                [~,~,~,stats] = ttest(squeeze(chiMap(x,y,z,:)));
                tMap(x,y,z) = stats.tstat;
            end
        end
    end
end

tMapMetadata = spm_vol(chiMapFile);
tMapMetadata.fname = [folder,filesep,'tMap.nii'];
tMapMetadata.descrip =  'R-map';
spm_write_vol(tMapMetadata, tMap);