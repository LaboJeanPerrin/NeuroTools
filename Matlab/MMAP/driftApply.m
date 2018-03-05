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

    x=m.x;
    y=m.y;
    z=m.z;
    t=m.t;
    Z=m.Z; %#ok<NASGU>
    T=m.T; %#ok<NASGU>

    % map the binary file x y and indices
    mmap = memmapfile(output,'Format',{'uint16',[x,y,z,t],'bit'}); %#ok<NASGU>
    mmaplin = memmapfile(output,'Format',{'uint16',[x*y,z,t],'bit'}); %#ok<NASGU>
    % save it to a matlab file
    save(outputInfo, 'mmap', 'mmaplin', 'x', 'y', 'z', 't', 'Z', 'T');

end