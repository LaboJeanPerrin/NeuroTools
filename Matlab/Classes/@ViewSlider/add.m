function add(this, varargin)

% --- Inputs --------------------------------------------------------------

% Validation
p = inputParser;
addRequired(p, 'stack', @(x) isnumeric(x) || ischar(x));
addParameter(p, 'range', NaN, @isnumeric);
addParameter(p, 'color', [1 1 1], @isnumeric);
parse(p, varargin{:});

% -------------------------------------------------------------------------

% Assignation
i = numel(this.stack)+1;
this.stack(i).data = p.Results.stack;
this.stack(i).range = p.Results.range;
this.stack(i).color = p.Results.color;

% Number of frames

if isnan(this.Nframes)
    this.Nframes = size(this.stack(i).data,3);
else
    if (this.Nframes ~= size(this.stack(i).data,3))
        warning('ViewSlider:add', 'Inconsistent number of frames.');
    end
end

% Manage range

if all(isnan(this.stack(i).range))
    this.autoRange(i);
end
this.stack(i).range = double(this.stack(i).range);
