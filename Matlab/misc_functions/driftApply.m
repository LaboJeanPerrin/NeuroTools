function driftApply(F, m)
%driftApply creates a binary file with the translated values

% load drift
driftPath = fullfile(F.dir.IP, 'Drifts.mat');
load(driftPath, 'dx', 'dy')
    
% load mmap info
rawMatPath = fullfile(F.dir.files, [m.tag '.mmap.mat']);
load(rawMatPath, 'mmap', 'X', 'Y', 'Z', 'T');

% define output files
outputMmap = fullfile(F.dir.files, 'corrected.mmap');
outputMmapInfo = fullfile(F.dir.files, 'corrected.mmap.mat');

% write the binary file
fid = fopen(outputMmap, 'wb');
for t = T % along t
    for z = Z % along z
        fwrite(fid,...
            imtranslate(m(:,:,z,t),...
            [-dx(t), -dy(t)]),...
            'uint16');
    end
end
fclose(fid);

% the mmap did not change (keep the same mmap)
save(outputMmapInfo, 'mmap', 'X', 'Y', 'Z', 'T');

% TODO rm raw binary file

end