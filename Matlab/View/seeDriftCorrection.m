function seeDriftCorrection(F)
%seeDriftCorrection computes and display translated images in real time

    driftPath = fullfile(F.dir.IP, 'Drifts.mat');
    load(driftPath, 'dx', 'dy')
    
    m = Mmap(F, 'raw');
    
    figure
    h = imshow(equalize_histogram(m(:,:,F.set.id,1)'));
    for t = m.T
        img = imtranslate(equalize_histogram(m(:,:,5,t)'), [-dx(t), -dy(t)]);
        set(h, 'Cdata', img);
        drawnow
    end
    
    clear gcf
end
