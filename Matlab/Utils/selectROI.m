function selectROI(F, m, RefIndex)
%selectROI is the utility to select the region of interest
% display each layer and asks user to draw ROI
% F focus
% m Mmap
% RefIndex index of reference stack

% TODO other proposition
% 1- loads existing ROI file if exists
% 2- for each layer, try to guess ROI
% 3- if gess is not good, let the user draw manually

% TODO map to the reference brain
mask = false(m.width, m.height, 20);
for z = m.Z
    imshow(equalize_histogram(F, m(:,:,z,RefIndex)))
    mask(:,:,z) = roipoly;
end
maskPath = fullfile(F.dir.IP, 'mask.mat');
save(maskPath, 'mask');

close gcf

end