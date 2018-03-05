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

%% mmaplin creation

inputMmap = fullfile(F.dir.files, 'corrected.mat');
mmapfile = fullfile(F.dir.files, 'corrected.bin');
load(inputMmap)

    mmaplin = memmapfile(mmapfile,'Format',{'uint16',[x*y,z,t],'bit'}); 
    imshow(reshape(equalize_histogram(mmaplin.Data.bit(:,1,1)), [x y])');
    
   
    save(inputMmap, 'x', 'y', 'z', 't', 'Z', 'T');
    
        indices = maskToIndex(F, 3);
    
    buffer = zeros(x,y);
    buffer(indices) = mmaplin.Data.bit(indices,1,1);
    imshow(equalize_histogram(buffer)');
    
    
%%
    
m = Mmap(F, 'corrected');

imshow(equalize_histogram(m(:,:,3,1))')
    
buffer = zeros(x,y);
buffer(indices) = m(indices,3,1);
imshow(equalize_histogram(buffer)');









