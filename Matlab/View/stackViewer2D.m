function stackViewer2D(F, Layers)
%stackViewer2D aims to produce the same result as stackViewer, but for 2D mmaps

m = {};
mgray = Mmap(F, 'IP/graystack');

    for z = Layers
            m{z} = Mmap2D(F, 'signalStacks', z);
    end

    f = figure('Visible','off'); 

    z = Layers(1);
    t = m{z}.T(1);

    img = mgray(:,:,z);
    img(m{z}.indices) = m{z}(t,:);
    imgh = equalize_histogram(img');

    h = imshow(imgh);
    title(['z=' num2str(z) '   t=' num2str(t)]);

    % z slider
    uicontrol('Style', 'slider',...
        'Min',Layers(1),'Max',Layers(end),'Value',z,...
        'Position', [1160 300 20 200],...
        'Callback', @actualize_z);

    if m{z}.t > 1
        % t slider
        uicontrol('Style', 'slider',...
            'Min',m{z}.T(1),'Max',m{z}.T(end),'Value',t,...
            'Position', [20 40 1100 20],...
            'Callback', @actualize_t);
    end

        f.Visible = 'on';
        set(f, 'Position',[200 200 1280 900]);
    
    function actualize_z(source, ~)
        z = floor(source.Value);
        img = mgray(:,:,z);
        img(m{z}.indices) = m{z}(t,:);
        imgh = equalize_histogram(img');
        set(h, 'Cdata', imgh);
        title(['z=' num2str(z) '   t=' num2str(t)]);
        drawnow;
    end

    function actualize_t(source, ~)
        t = floor(source.Value);
        img = mgray(:,:,z);
        img(m{z}.indices) = m{z}(t,:);
        imgh = equalize_histogram(img');
        set(h, 'Cdata', imgh);
        title(['z=' num2str(z) '   t=' num2str(t)]);
        drawnow;
    end


    
end
