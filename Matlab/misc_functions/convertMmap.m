%convertMmap is a small utility to help convert mmap
% this script is done to be edited
clc
% inputmap
m = Mmap(F, 'raw');
% input mat map
inputMmap = fullfile(F.dir.files, [m.tag '.mmap.mat']);
% outputmap
outputMmap = fullfile(F.dir.files, 'raw.mmap');
% output mat map
outputMmapinfo = fullfile(F.dir.files, 'raw2.mmap.mat');

w = waitbar(0, 'Converting mmap');

% write the binary file
fid = fopen(outputMmap, 'wb');
for t = T % along t
    for z = Z % along z
        for y = Y
        fwrite(fid,...
            mmap.Data.bit(y,:,z,t),...
            'uint16');
        end
    end
    waitbar(t/T(end))
end
fclose(fid);

close(w)

% load inputmap variables
load(inputMmap)

% get the dimension of the 4D matrix
x = length(X); % width
y = length(Y); % heigth
z = length(Z); % number of layers of interest
t = length(T); % number of frames par layer

% save the mmap with the correct filename
mmap = memmapfile(outputMmap,'Format',{'uint16',[x,y,z,t],'raw'}); 
save(outputMmapinfo, 'mmap', 'X', 'Y', 'Z', 'T');

clearvars -except F m param