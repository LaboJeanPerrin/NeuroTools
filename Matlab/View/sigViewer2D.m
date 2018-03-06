function sigViewer2D(F, tag, Layers)
%stackViewer2D aims to produce the same result as stackViewer, but for 2D mmaps

m = {};
mgray = Mmap(F, 'IP/graystack');

    for z = Layers %#ok<*FXUP>
        m{z} = struct(); %#ok<*AGROW>
        inputInfo = fullfile(F.dir.IP, tag, [num2str(z, '%02d') '.mat']);
        load(inputInfo, 'mmap', 'indices', 'T');
        m{z}.indices = indices;
        m{z}.mmap = mmap;
    end

    f = figure('Visible','off'); 

    z = Layers(1);
    t = T(1);

    img = NaN(1018,634);
    img(m{z}.indices) = m{z}.mmap.Data.bit(t,:);
    imgh = img';

    h = imshow(imgh, [-.5 2]);
    title(['z=' num2str(z) '   t=' num2str(t)]);

    % z slider
    uicontrol('Style', 'slider',...
        'Min',Layers(1),'Max',Layers(end),...
        'SliderStep', [1/(Layers(end)-Layers(1)) 1/(Layers(end)-Layers(1))], 'Value',z,...
        'Position', [1160 300 20 200],...
        'Callback', @actualize_z);

    if length(T) > 1
        % t slider
        uicontrol('Style', 'slider',...
            'Min', T(1),'Max', T(end),...
            'SliderStep', [1/(T(end)-T(1)) 1/(T(end)-T(1))], 'Value',t,...
            'Position', [20 40 1100 20],...
            'Callback', @actualize_t); %#ok<*COLND>
    end

        f.Visible = 'on';
        set(f, 'Position',[200 200 1280 900]);
    
    function actualize_z(source, ~)
        z = floor(source.Value);
        img = NaN(1018,634);
        img(m{z}.indices) = m{z}.mmap.Data.bit(t,:);
        imgh = img';
        set(h, 'Cdata', imgh);
        title(['z=' num2str(z) '   t=' num2str(t)]);
        drawnow;
    end

    function actualize_t(source, ~)
        t = floor(source.Value);
        img = NaN(1018,634);
        img(m{z}.indices) = m{z}.mmap.Data.bit(t,:);
        imgh = img';
        set(h, 'Cdata', imgh);
        title(['z=' num2str(z) '   t=' num2str(t)]);
        drawnow;
    end


    
end
