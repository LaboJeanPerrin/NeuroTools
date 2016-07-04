clc

% === Parameters ==========================================================

pref = '/home/ljp/Science/Projects/Neurofish/Data/2016-05-12/Run 02/Images/CA_50uM_1000ms_3D0_';
format = '%05i';
suff = '.tif';

Nf = 2000;

output = '/home/ljp/Science/Projects/NeuroTools/Data/xyt.dat';

% =========================================================================

% --- Get file infos

Imf = imfinfo([pref num2str(0, format) suff]);
W = Imf.Width;
H = Imf.Height;

fid = fopen(output, 'w');

% --- Header

fwrite(fid, uint16([W H]), 'uint16');
fwrite(fid, uint32(Nf), 'uint32');

% --- Images
for i = 0:Nf-1
    tic
    Img = imread([pref num2str(i, format), suff]);
    toc
    fwrite(fid, Img, 'uint16');
end

fclose(fid);