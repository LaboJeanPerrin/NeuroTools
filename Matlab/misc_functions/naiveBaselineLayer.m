function naiveBaselineLayer(F, m, Layer)
%naiveBaseline computes naively the baseline for only one layer and stores it to a file

% make a directory to store baseline (could already exist)
mkdir(fullfile(F.dir.IP, 'baseline'));
outputMmap = fullfile(F.dir.IP, 'baseline', [num2str(Layer, '%02d') '_baseline.mmap']);
outputMmapInfo = fullfile(F.dir.IP, 'baseline', [num2str(Layer, '%02d') '_baseline.mmap.mat']);

% get indices from mask
indices = maskToIndex(F, Layer);

fid = fopen(outputMmap, 'wb');

for i = indices' % for all pixel in layer's ROI
    [x,y] = ind2sub([F.IP.height F.IP.width], i); % get the x,y corresponding position
    naiveBaseline(m(x,y,Layer, :), fid, i); % let the baseline being written number after number
end

fclose(fid);

% map the binary file and save info
mmap = memmapfile(outputMmap,'Format',{'uint16',[length(indices), length(m.T)],'raw'}); %#ok<NASGU>
save(outputMmapInfo, 'mmap');


end