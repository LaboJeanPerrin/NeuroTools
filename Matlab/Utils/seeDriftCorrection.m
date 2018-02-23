function seeDriftCorrection(F)
    driftPath = fullfile(F.dir.IP, 'Drifts.mat');
    load(driftPath, 'dx', 'dy')
    
    m = Mmap(F, 'raw');
    
    figure
    h = imshow(equalize_histogram(F,m(:,:,5,1)));
    for t = m.T
        img = imtranslate(equalize_histogram(F,m(:,:,5,t)), [-dx(t), -dy(t)]);
        set(h, 'Cdata', img);
        drawnow
    end
    
    clear gcf
end
