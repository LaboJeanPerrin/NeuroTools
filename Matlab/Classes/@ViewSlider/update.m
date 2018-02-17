function update(this, varargin)

% --- Get z index
k = round(get(this.slider, 'Value'));

% --- Display image
% 
if ~isempty(varargin) && strcmp(varargin{1}, 'reset')
    axes(this.axes);
    this.img = image(this.prepare(k));
    axis off
else
    % image('CData', this.prepare(this.stack(1:this.zoom:end,1:this.zoom:end,zi)));
    image('CData', this.prepare(k));
end
% axis off

% --- Update info
set(this.info.imageNumber, 'string', [num2str(k) ' / ' num2str(this.Nframes)]);
% set(this.info.pixelInfo, 'string', [num2str(k) 'ooooooooooooooooooooo']);

% --- Display refresh
drawnow limitrate

% --- Update pixel info
this.updatePixelInfo