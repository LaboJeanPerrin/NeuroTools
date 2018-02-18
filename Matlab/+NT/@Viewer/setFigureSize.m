function setFigureSize(this)

% --- Dimensions of the visualization area --------------------------------

this.visuWidth = 0;
this.visuHeight = 0;

for i = 1:numel(this.stacks)
    this.visuWidth = max(this.visuWidth, ceil(this.stacks(i).size(2)/this.zoom));
    this.visuHeight = max(this.visuHeight, ceil(this.stacks(i).size(1)/this.zoom));
end

% --- Update figure and axes sizes ----------------------------------------

if isnan(this.T)
    
    % Visualization area
    set(this.visu, 'position', [0 0 this.visuWidth this.visuHeight]);
    drawnow
    
    % Figure
    fpos = get(this.figure, 'Position');
    wsize = [this.visuWidth this.infosHeight+this.visuHeight];
    set(this.figure, 'Position', [fpos(1:2)+fpos(3:4)/2-wsize/2 wsize]);
            
    % Info area
    set(this.info.imageNumber, 'position', [5 this.visuHeight this.visuWidth/6 this.infosHeight-4]);
    set(this.info.pixelInfo, 'position', [this.visuWidth/3 this.visuHeight this.visuWidth/3 this.infosHeight-4]);
    
else
    
    % Visualization area
    set(this.visu, 'position', [0 this.sliderHeight this.visuWidth this.visuHeight]);
    drawnow
    
    % Figure
    fpos = get(this.figure, 'Position');
    wsize = [this.visuWidth this.infosHeight+this.visuHeight+this.sliderHeight];
    set(this.figure, 'Position', [fpos(1:2)+fpos(3:4)/2-wsize/2 wsize]);
            
    % Slider
    set(this.slider, 'position', [0 0 this.visuWidth this.sliderHeight]);

    % Info area
    set(this.info.imageNumber, 'position', [5 this.sliderHeight+this.visuHeight this.visuWidth/6 this.infosHeight-4]);
    set(this.info.pixelInfo, 'position', [this.visuWidth/3 this.sliderHeight+this.visuHeight this.visuWidth/3 this.infosHeight-4]);

end


% Update image
this.updateVisu('reset');