function show(this)

% --- Checks --------------------------------------------------------------

if isempty(this.stacks)
    warning('ViewSlider:NoStack', 'There is no stack to show.');
    return
end

% --- Create figure, axes and uicontrols ----------------------------------

% Get screen size
screensize = get(groot, 'Screensize');
 
% --- Figure

this.figure = figure('Name', 'ViewSlider', ...
    'menuBar', 'none',  ...
    'Color', this.bgcolor, ...
    'Units', 'pixels', ...
    'Position', [screensize(3:4)/2 0 0], ...
    'WindowButtonMotionFcn', @(~,~) this.updatePixelInfo, ...
    'WindowKeyPressFcn', @(~,e) this.keypressed(e));

% --- Visualization area

this.visu = axes('Units', 'pixels', 'visible', 'off', ...
    'ActivePositionProperty', 'position', ...
    'xlimmode','manual', 'ylimmode','manual', ...
    'zlimmode','manual', 'climmode','manual', ...
    'alimmode','manual');

% --- Info area

this.info = struct(...
    'imageNumber', uicontrol(this.figure, 'Style', 'text', 'BackgroundColor', this.bgcolor, 'ForegroundColor', [1 1 1], 'FontName', 'FixedWidth', 'HorizontalAlignment', 'left'), ...
    'pixelInfo', uicontrol(this.figure, 'Style', 'text', 'BackgroundColor', this.bgcolor, 'ForegroundColor', [1 1 1], 'FontName', 'FixedWidth', 'HorizontalAlignment', 'center'));

% --- Slider

if ~isnan(this.T)
    this.slider = uicontrol('style','slider', 'units', 'pixel', ...
        'Min', 1, 'Max', this.T, 'Value', 1, ...
        'SliderStep', [1 10]/(this.T-1));
    addlistener(this.slider, 'Value', 'PostSet', @(~,~) this.updateVisu);
end

% --- Rendering settings --------------------------------------------------

% Speed optimization
set(this.figure, 'doublebuffer', 'off');

% Grey levels
colormap(gray(256));

% Set figure size and display first image
this.setFigureSize();