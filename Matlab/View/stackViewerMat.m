function stackViewerMat(mask)

Z = size(mask,3);

f = figure('Visible','off'); 

z = 5;
img = mask(:,:,z);

h = imshow(img);
title(['z=' num2str(z)]);

% z slider
uicontrol('Style', 'slider',...
    'Min',1,'Max',Z,'Value',z,...
    'Position', [1160 300 20 200],...
    'Callback', @actualize_z);
    
f.Visible = 'on';
set(f, 'Position',[200 200 1280 900]);
    
    function actualize_z(source, ~)
        z = floor(source.Value);
        img = mask(:,:,z);
        set(h, 'Cdata', img);
        title(['z=' num2str(z)]);
        drawnow;
    end

end