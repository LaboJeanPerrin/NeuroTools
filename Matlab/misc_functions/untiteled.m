

t=1;


figure
h = imshow(egalize_histogram(F,mmap.Data.raw(:,:,1,t)));


for t=1:1500
    set(h, 'Cdata', egalize_histogram(F,mmap.Data.raw(:,:,1,t)));
    drawnow
end