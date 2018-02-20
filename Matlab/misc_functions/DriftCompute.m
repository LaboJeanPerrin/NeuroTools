function DriftCompute(F, Layers_stack_ref, Layers, ind_Refstack)

% --- Define reference image ---
F.select(F.sets(Layers(1)).id);
Img1 = F.imageLoad(ind_Refstack);
tmp3D = zeros(Img1.height,Img1.width,size(Layers_stack_ref,2)); % preallocate tmp3D
counter = 1;
for i = Layers_stack_ref
    F.select(F.sets(i).id);
    Ref = F.imageLoad(ind_Refstack);
    tmp3D(:,:,counter) = Ref.pix;
    counter = counter +1;
end
Ref.pix = max(tmp3D(:,:,:),[],3);
figure;imshow(rescalegd2(Ref.pix));
title([F.name])

bbox = [45   914    53   566];
Ref.region(bbox);

% --- Drift correction ---
tmp3D(:) = 0;
dx = zeros(1,N_img_layer);
dy = zeros(1,N_img_layer);
for k = 1 : N_img_layer
    % Calculate z-projection of stack at first time point
    counter = 1;
    for i = Layers_stack_ref
        F.select(F.sets(i).id);
        Img = F.imageLoad(k);
        tmp3D(:,:,counter) = Img.pix;
        counter = counter +1;
    end
    Img.pix = max(tmp3D(:,:,:),[],3);

    Img.region(bbox);

    [DX, DY] = Ref.fcorr(Img);
    Img.translate(-DY, -DX);
    dx(k) = DX;
    dy(k) = DY;

    if ~mod(k,50)
        plot(k-49:k,dy(k-49:k),'b*');hold on;plot(k-49:k,dx(k-49:k),'*r');
        title([F.name]);
        pause(0.1)
    end   
end
clear tmp3D
% --- Save ---
for i = Layers
    % --- Save bbox ---
    Dmat = F.matfile(['IP/', num2str(i) ,'/DriftBox']);
    Dmat.save(bbox, 'Bounding box for drift correction ([x1 x2 y1 y2])');
    % --- Save Drift.mat ---
    dmat = F.matfile(['IP/', num2str(i) ,'/Drifts']);
    dmat.save(dx, 'Drift in the x-direction, at each time step [pix]');
    dmat.save(dy, 'Drift in the y-direction, at each time step [pix]');
end

end