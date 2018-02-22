function stackViewer(F, m)
% 
% 
% à faire proprement, mais l'idée est là
% 
% 
% 

Z = m.Z;
T = m.T;

f = figure('Visible','off'); 

z=Z(1);
t=T(1);

img = egalize_histogram(F,m(:,:,z,t));

h = imshow(img);
title(['z=' num2str(z) '   t=' num2str(t)]);

% z slider
uicontrol('Style', 'slider',...
    'Min',Z(1),'Max',Z(end),'Value',z,...
    'Position', [1160 300 20 200],...
    'Callback', @actualize_z);

% t slider
uicontrol('Style', 'slider',...
    'Min',T(1),'Max',T(end),'Value',t,...
    'Position', [20 40 1100 20],...
    'Callback', @actualize_t);
    
f.Visible = 'on';
set(f, 'Position',[200 200 1280 900]);
    
    function actualize_z(source, ~)
        z = floor(source.Value);
        img = egalize_histogram(F,m(:,:,z,t));
        set(h, 'Cdata', img);
        title(['z=' num2str(z) '   t=' num2str(t)]);
        drawnow;
    end

    function actualize_t(source, ~)
        t = floor(source.Value);
        img = egalize_histogram(F,m(:,:,z,t));
        set(h, 'Cdata', img);
        title(['z=' num2str(z) '   t=' num2str(t)]);
        drawnow;
    end
end