function selectROI(F, RefIndex)
%selectROI is the utility to select the region of interest
% display each layer and asks user to draw ROI
% F focus
% RefIndex index of reference stack

    m = Mmap(F, 'corrected');

    mask = false(m.x, m.y, 20);
    for z = m.Z
        imshow(equalize_histogram(m(:,:,z,RefIndex)'))
        mask(:,:,z) = roipoly';
    end
    maskPath = fullfile(F.dir.IP, 'mask.mat');
    save(maskPath, 'mask');

    close gcf

end