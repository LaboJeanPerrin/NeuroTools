
function driftApply(F, m)
%driftApply creates a binary file with the translated values

% load drift
driftPath = fullfile(F.dir.IP, 'Drifts.mat');
load(driftPath, 'dx', 'dy')
    
% load mmap info
rawMatPath = fullfile(F.dir.files, [m.tag '.mmap.mat']);
load(rawMatPath, 'X', 'Y', 'Z', 'T');

% define output files
outputMmap = fullfile(F.dir.files, 'corrected.mmap');
outputMmapInfo = fullfile(F.dir.files, 'corrected.mmap.mat');

w = waitbar(0, 'Applying computed drift');

% write the binary file
fid = fopen(outputMmap, 'wb');
for t = T % along t
    for z = Z % along z
        fwrite(fid,...
            imtranslate(m(:,:,z,t),...
            [-dx(t), -dy(t)]),...
            'uint16');
    end
    waitbar(t/T(end)) %#ok<COLND>
end
fclose(fid);

close(w)

% get the dimension of the 4D matrix
x = length(X); % width
y = length(Y); % heigth
z = length(Z); % number of layers of interest
t = length(T); % number of frames par layer

% save the mmap with the correct filename
mmap = memmapfile(outputMmap,'Format',{'uint16',[x,y,z,t],'raw'}); %#ok<NASGU>
save(outputMmapInfo, 'mmap', 'X', 'Y', 'Z', 'T');

% TODO rm raw binary file

end