function update(this, varargin)

% --- Get z index
k = round(get(this.slider, 'Value'));

% --- Display image
if ~isempty(varargin) && strcmp(varargin{1}, 'reset')
    this.img = image(this.prepare(k));
else
    % image('CData', this.prepare(this.stack(1:this.zoom:end,1:this.zoom:end,zi)));
    image('CData', this.prepare(k));
end

axis off
drawnow limitrate