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
    
    % data
    x = m.x;
    y = m.y;
    z = m.z;
    t = 1; %#ok<NASGU>
    Z = m.Z;
    T = 1; %#ok<NASGU>

    % create corresponding info
    save(outputInfo, 'x', 'y', 'z', 't', 'Z', 'T');

end
