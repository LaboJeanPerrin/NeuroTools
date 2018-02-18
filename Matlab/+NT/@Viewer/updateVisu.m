function updateVisu(this, varargin)

% --- Display image

if ~isempty(varargin) && strcmp(varargin{1}, 'reset')
    axes(this.visu);
    this.image = image(this.prepareVisu);
    axis off
else
    image('CData', this.prepareVisu);
end

% Update info
if isnan(this.T)
    
    set(this.info.imageNumber, 'string', '1 / 1');
    
else
    
    % Get frame number
    k = round(get(this.slider, 'Value'));
            
    set(this.info.imageNumber, 'string', [num2str(k) ' / ' num2str(this.T)]);
end

% Display refresh
drawnow limitrate

% Update pixel info
this.updatePixelInfo