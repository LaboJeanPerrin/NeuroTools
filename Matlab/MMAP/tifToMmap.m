function mmap = tifToMmap(F, kwargs)
%rawToMmap takes the tif images and write it in a 4D mmap file
% F is the focus on the run
% kwargs are key-word arguments to specify
%       x,y ROI (rectangle)
%       z layers
%       t frames of interest

% default values
X = 1:F.IP.height;          % x size
Y = 1:F.IP.width;           % y size
Z = [F.sets.id];            % id of all layers (ex 1:20)
T = 1:length(F.set.frames); % number of image per layer (ex 1:3000)

% parse input
p = inputParser;
p.addParameter('x', X); % TODO write validation function
p.addParameter('y', Y); % TODO write validation function
p.addParameter('z', Z); % TODO write validation function
p.addParameter('t', T); % TODO write validation function
p.parse(kwargs{:})

% replace default values by given ones
X = p.Results.x;
Y = p.Results.y;
Z = p.Results.z;
T = p.Results.t;
 
% define output files
outputMmap = fullfile(F.dir.files, 'raw.mmap');
outputMmapInfo = fullfile(F.dir.files, 'raw.mmap.mat');

% write the binary file
fid = fopen(outputMmap, 'wb');
for t = T % along t
    for z = Z % along z
        F.select(F.sets(z).id);
        tmp = F.imageLoad(t);
%         tmp = tmp.crop(X,Y); % crop image TODO
        fwrite(fid,tmp.pix,'double');
    end
end
fclose(fid);

% get the dimension of the 4D matrix
x = length(X); % width
y = length(Y); % heigth
z = length(Z); % number of layers of interest
t = length(T); % number of frames par layer

% return the map of the binary file
mmap = memmapfile(outputMmap,'Format',{'double',[x,y,z,t],'raw'});
% save it to a matlab file
save(outputMmapInfo, 'mmap', 'X', 'Y', 'Z', 'T');

end