

t=1;


figure
h = imshow(egalize_histogram(F,mmap.Data.raw(:,:,1,t)));


for t=1:1500
    set(h, 'Cdata', egalize_histogram(F,mmap.Data.raw(:,:,1,t)));
    drawnow
end

%%


indices = maskToIndex(F, Layer); % get indices of interest
[X,Y] = ind2sub([F.IP.height F.IP.width], indices);


%% [doublePtr, doublePtr, int32Ptr, int32Ptr, doublePtr, int32Ptr, int32Ptr] runquantile(doublePtr, doublePtr, int32Ptr, int32Ptr, doublePtr, int32Ptr, int32Ptr)
    
tic  
for i=1:10000 
IN = mmap.Data.raw(:,1)';
OUT = uint16(zeros(size(IN)))';

% in / out / longueur / window


[~, OUT] = calllib('caTools', 'runquantile', IN, OUT, length(IN), int32(100), 0.1, int32(1), int32(1));
end
toc

plot(IN); hold on; plot(OUT);