function autoROI(F, Fref)
%autoROI applies back the transformation to the reference brain
% F focus on current brain
% Fref focus on reference brain

    % loads the deformation map for the current brain
    defMapPath = fullfile(F.dir.IP, 'defMap.mat');
    load(defMapPath,'defMap');

    % loads the ROI for the reference brain
    refROIPath = fullfile(Fref.dir.IP, 'mask.mat');
    load(refROIPath, 'mask');

    autoMask = false(size(mask)); %#ok<NODEF>
    for z = 1:20
        autoMask(:,:,z) = imwarp(mask(:,:,z), defMap(:,:,:,z)); %#ok<IDISVAR,NODEF>
    end

    % stores the autoMask in the mask variable
    mask = autoMask; %#ok<NASGU>

    % saves the obtained mask
    autoMaskPath = fullfile(F.dir.IP, 'mask.mat');
    save(autoMaskPath, 'mask');

end