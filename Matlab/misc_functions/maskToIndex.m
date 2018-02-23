function indices = maskToIndex(F, Layer)
%maskToIndex returns the 1D indices for xy present in the mask for one layer

maskPath = fullfile(F.dir.files, 'mask.mat');
load(maskPath, 'mask');

indices = find(mask(:,:,Layer)); %#ok<IDISVAR,NODEF>

end
