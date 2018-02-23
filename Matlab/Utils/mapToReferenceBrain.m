function mapToReferenceBrain(F, m, mref, RefIndex)
%mapToReferenceBrain saves the deformation field to the reference brain

% x and y deformation map for each layer
defMap=zeros(m.width, m.height, 2, 20);

for z = m.Z
    [defMap(:,:,:,z),~] = imregdemons(m(:,:,z,RefIndex),mref(:,:,z,RefIndex), [8,4,2], 'PyramidLevels', 3);
end

defMapPath = fullfile(F.dir.IP, 'defMap.mat');
save(defMapPath, 'defMap');

end