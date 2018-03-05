function stackViewer(F, tag)
%stackViewer is analog to imageJ hyperstack
% it allows to visualize the brain and browse z and t directions

    m = Mmap(F, tag);

    f = figure('Visible','off'); 

    z = m.Z(1);
    t = m.T(1);

    img = m(:,:,z,t)';

    h = imshow(img, [400 700]);
    title(['z=' num2str(z) '   t=' num2str(t)]);

    % z slider
    uicontrol('Style', 'slider',...
        'Min',m.Z(1),'Max',m.Z(end),'Value',z,...
        'Position', [1160 300 20 200],...
        'Callback', @actualize_z);

    if m.t > 1
        % t slider
        uicontrol('Style', 'slider',...
            'Min',m.T(1),'Max',m.T(end),'Value',t,...
            'Position', [20 40 1100 20],...
            'Callback', @actualize_t);
    end

        f.Visible = 'on';
        set(f, 'Position',[200 200 1280 900]);
    
    function actualize_z(source, ~)
        z = floor(source.Value);
        img = m(:,:,z,t)';
        set(h, 'Cdata', img);
        title(['z=' num2str(z) '   t=' num2str(t)]);
        drawnow;
    end

    function actualize_t(source, ~)
        t = floor(source.Value);
        img = m(:,:,z,t)';
        set(h, 'Cdata', img);
        title(['z=' num2str(z) '   t=' num2str(t)]);
        drawnow;
    end
end
