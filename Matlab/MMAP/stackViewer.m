function stackViewer(F, mmap)
% 
% 
% à faire proprement, mais l'idée est là
% 
% 
% 

zmax = mmap.Format{2}(3);
tmax = mmap.Format{2}(4);

f = figure('Visible','off'); 

z=1;
t=1;

img = mmap.Data.raw(:,:,z,t);
img = img - F.IP.range(1);
img = img / (F.IP.range(2) - F.IP.range(1)) * 20;

h = imshow(img);
title(['z=' num2str(z) '   t=' num2str(t)]);


uicontrol('Style', 'slider',...
    'Min',1,'Max',zmax,'Value',z,...
    'Position', [100 10 600 20],...
    'Callback', @actualize_z);

uicontrol('Style', 'slider',...
    'Min',1,'Max',tmax,'Value',t,...
    'Position', [100 40 600 20],...
    'Callback', @actualize_t);
    
    
f.Visible = 'on';
    
    function actualize_z(source, ~)
        z = floor(source.Value);
        img = egalize_histogram(F,mmap.Data.raw(:,:,z,t));
        set(h, 'Cdata', img);
        drawnow;
        title(['z=' num2str(z) '   t=' num2str(t)]);
    end

function actualize_t(source, ~)
        t = floor(source.Value);
        img = egalize_histogram(F,mmap.Data.raw(:,:,z,t));
        set(h, 'Cdata', img);
        drawnow;
        title(['z=' num2str(z) '   t=' num2str(t)]);
    end
end