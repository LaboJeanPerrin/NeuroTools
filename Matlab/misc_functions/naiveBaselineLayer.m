function naiveBaselineLayer(F, m, Layer)
%naiveBaseline computes naively the baseline for only one layer and stores it to a file

% make a directory to store baseline (could already exist)
mkdir(fullfile(F.dir.IP, 'baseline'));
outputMmap = fullfile(F.dir.IP, 'baseline', [num2str(Layer, '%02d') '_baseline.mmap']);
outputMmapInfo = fullfile(F.dir.IP, 'baseline', [num2str(Layer, '%02d') '_baseline.mmap.mat']);

% get indices from mask
indices = maskToIndex(F, Layer);

fid = fopen(outputMmap, 'wb');

w = waitbar(0, 'Computing baseline');

for i = 1:length(indices) % for all pixel in layer's ROI
    [x,y] = ind2sub([F.IP.height F.IP.width], indices(i)); % get the x,y corresponding position
    naiveBaseline(squeeze(m(x,y,Layer, :)), fid); % let the baseline being written number after number
    waitbar(i/length(indices), w, [num2str(i) ' / ' num2str(length(indices))] ) % waitbar
end

close(w)

fclose(fid);

% map the binary file and save info
mmap = memmapfile(outputMmap,'Format',{'uint16',[length(indices), length(m.T)],'raw'}); %#ok<NASGU>
save(outputMmapInfo, 'mmap');


end