function indices = maskToIndex(F, Layer)
%maskToIndex returns the 1D indices for xy present in the mask for one layer

    maskPath = fullfile(F.dir.IP, 'mask.mat');
    load(maskPath, 'mask');

    indices = uint32(find(mask(:,:,Layer))); %#ok<IDISVAR,NODEF>

end
