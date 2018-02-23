function createGrayStack(F, m)
%createGrayStack creates a gray stack (mean along t)

    outputMmap = fullfile(F.dir.IP, 'graystack.mmap');
    outputMmapInfo = fullfile(F.dir.IP, 'graystack.mmap.mat');

    fid = fopen(outputMmap, 'wb');

    for z = m.Z
        fwrite(fid, mean(m(:,:,z,1:100:1500), 4), 'uint16');
    end

    fclose(fid);

    % create corresponding mmap info
    mmap = memmapfile(outputMmap,...
        'Format',{'uint16',[F.IP.height F.IP.width length(m.Z)],'raw'}); %#ok<NASGU>
    save(outputMmapInfo, 'mmap');

end