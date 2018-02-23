function maskViewer(F)
%maskViewer shows the mask contour on the brain

    m = Mmap(F, 'corrected');

    maskPath = fullfile(F.dir.IP, 'mask.mat');
    load(maskPath, 'mask');

    f = figure('Visible','off');

    z = m.Z(1);
    img = equalize_histogram(m(:,:,z,10)');

    h = imshow(img);
    title(['z=' num2str(z)]);

    % z slider
    uicontrol('Style', 'slider',...
        'Min',m.Z(1),'Max',m.Z(end),'Value',z,...
        'Position', [1160 300 20 200],...
        'Callback', @actualize_z);

    f.Visible = 'on';
    set(f, 'Position',[200 200 1280 900]);
    hold on; [~,cont] = contour(mask(:,:,z)');
    
    function actualize_z(source, ~)
        z = floor(source.Value);
        img = equalize_histogram(m(:,:,z,10)');
        set(h, 'Cdata', img);
        delete(cont); [~,cont] = contour(mask(:,:,z)'); %#ok<IDISVAR>
        title(['z=' num2str(z)]);
        drawnow;
    end

end