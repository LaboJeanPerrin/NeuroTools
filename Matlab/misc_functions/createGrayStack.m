function createGrayStack(F)
%createGrayStack creates a gray stack (mean along t)

    m = Mmap(F, 'corrected');

    output = fullfile(F.dir.IP, 'graystack.bin');
    outputInfo = fullfile(F.dir.IP, 'graystack.mat');

    fid = fopen(output, 'wb');

    for z = m.Z
        fwrite(fid, mean(m(:,:,z,1:77:1500), 4), 'uint16');
    end

    fclose(fid);
    
    x = m.x;
    y = m.y;
    z = m.z;
    Z = m.Z;

    % create corresponding mmap info
    mmap = memmapfile(output,...
        'Format',{'uint16', [x, y, z],'bit'}); %#ok<NASGU>
    save(outputInfo, 'mmap', 'x', 'y', 'z', 'Z');

end
