function show(this)

% --- Checks --------------------------------------------------------------

if isempty(this.stack)
    warning('ViewSlider:NoStack', 'There is no stack to show.');
    return
end

% --- Create figure, axes and uicontrols

% Figure
this.fig = figure('Name', 'ViewSlider', ...
    'menuBar', 'none',  ...
    'Units', 'pixels', ...
    'WindowKeyPressFcn', @(~,e) this.keypressed(e));

% Axes
this.axes = axes('Units', 'pixels', 'visible', 'off', ...
    'ActivePositionProperty', 'position', ...
    'xlimmode','manual', 'ylimmode','manual', ...
    'zlimmode','manual', 'climmode','manual', ...
    'alimmode','manual');

% Slider
this.slider = uicontrol('style','slider', 'units', 'pixel', ...
    'Min', 1, 'Max', this.Nframes, 'Value', 1, ...
    'SliderStep', [1 10]/(this.Nframes - 1));
addlistener(this.slider, 'Value', 'PostSet', @(~,~) this.update);

% --- Rendering settings

% Speed optimization
set(this.fig,'doublebuffer','off');

% Grey levels
colormap(gray(256));

% --- Set figure size and display first image
this.setFigureSize();