function driftApply(F)
%driftApply creates a binary file with the translated values

    % load drift
    driftPath = fullfile(F.dir.IP, 'Drifts.mat');
    load(driftPath, 'dx', 'dy')

    % load mmap info
    m = Mmap(F, 'raw');

    % define output files
    output = fullfile(F.dir.files, 'corrected.bin');
    outputInfo = fullfile(F.dir.files, 'corrected.mat');

    w = waitbar(0, 'Applying computed drift');

    % write the binary file
    fid = fopen(output, 'wb');
    for t = m.T % along t
        for z = m.Z % along z
            fwrite(fid,...
                imtranslate(m(:,:,z,t),...
                [-dy(t), -dx(t)]),... %  x of image is y for matlab
                'uint16');
        end
        waitbar(t/m.t)
    end
    fclose(fid);

    close(w)

    x=m.x; %#ok<*NASGU>
    y=m.y;
    z=m.z;
    t=m.t;
    Z=m.Z;
    T=m.T;
    
    % save info to a matlab file
    save(outputInfo, 'x', 'y', 'z', 't', 'Z', 'T');

end