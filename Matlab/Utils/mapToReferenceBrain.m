function mapToReferenceBrain(F, m, mref, RefIndex)
%mapToReferenceBrain saves the deformation field to the reference brain

% x and y deformation map for each layer
Deformation=NaN(m.width, m.height, 2, 20);

for z = m.Z
    [Deformation(:,:,:,z),~] = imregdemons(m(:,:,z,RefIndex),mref(:,:,z,RefIndex), [8,4,2], 'PyramidLevels', 3);
end

deformationPath = fullfile(F.dir.IP, 'Deformation.mat');
save(deformationPath, 'Deformation');

end