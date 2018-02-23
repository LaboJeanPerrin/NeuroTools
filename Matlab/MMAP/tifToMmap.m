function tifToMmap(F, tag, kwargs)
%rawToMmap takes the tif images and write it in a 4D mmap file
% F is the focus on the run
% kwargs are key-word arguments to specify
%       x,y ROI (rectangle) TODO
%       z layers
%       t frames of interest TODO

% default values
X = 1:F.IP.height;          % x size
Y = 1:F.IP.width;           % y size
Z = [F.sets.id];            % id of all layers (ex 1:20)
T = 1:length(F.set.frames); % number of image per layer (ex 1:3000)

% parse input TODO write validation functions
p = inputParser;
p.addParameter('x', X);
p.addParameter('y', Y);
p.addParameter('z', Z);
p.addParameter('t', T);
p.parse(kwargs{:})

% replace default values by given ones
X = p.Results.x;
Y = p.Results.y;
Z = p.Results.z;
T = p.Results.t;
 
% define output files
outputMmap = fullfile(F.dir.files, [tag '.mmap']);
outputMmapInfo = fullfile(F.dir.files, [tag '.mmap.mat']);

w = waitbar(0, 'Converting TIF to mmap');

% write the binary file
fid = fopen(outputMmap, 'wb');
for t = T % along t
    for z = Z % along z
        F.select(F.sets(z).id);
        tmp = F.imageLoad(t);
%         tmp = tmp.crop(X,Y); % crop image TODO could be done with region ?
        fwrite(fid,tmp.pix,'uint16');
        waitbar(t/T(end))
    end
end
fclose(fid);

close(w)

% get the dimension of the 4D matrix
x = length(X); % width
y = length(Y); % heigth
z = length(Z); % number of layers of interest
t = length(T); % number of frames par layer

% map of the binary file
mmap = memmapfile(outputMmap,'Format',{'uint16',[x,y,z,t],'raw'}); %#ok<NASGU>
% save it to a matlab file
save(outputMmapInfo, 'mmap', 'X', 'Y', 'Z', 'T');

end