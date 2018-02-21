fixed = egalize_histogram(F,mmap.Data.raw(:,:,1,1));
moving = egalize_histogram(F,mmap.Data.raw(:,:,1,30));
figure; imshow(moving)

[D,moving_reg] = imregdemons(moving,fixed, [100,20,5]);

imshow(moving_reg-fixed)

Ref = NT.Image(fixed);

%%



fixed = egalize_histogram(F,mmap.Data.raw(:,:,1,1));

t=1;


figure
h = imshow(egalize_histogram(F,mmap.Data.raw(:,:,1,t)));

% Dxt= NaN(1,100);
% Dyt= NaN(1,100);

for t=1:100
    moving = egalize_histogram(F,mmap.Data.raw(:,:,1,t));
    moving = imtranslate(moving, [10*sin(t), 5*cos(t)]);
%     [D,moving_reg] = imregdemons(moving,fixed, [8,4,2], 'DisplayWaitBar', false, 'PyramidLevels', 3);
%     Dx=mean(mean(D(:,:,1))); Dxt(t) = Dx;
%     Dy=mean(mean(D(:,:,2))); Dyt(t) = Dy;
%     translated = imtranslate(moving, [-10*Dx, -10*Dy]);
%     movingRegistered = imregister(moving, fixed, 'affine', optimizer, metric);  

    [DX, DY] = Ref.fcorr(moving);
    translated = imtranslate(moving, [-DY, -DX]);
    set(h, 'Cdata', translated);
    drawnow
end


