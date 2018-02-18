function xyz(this, varargin)

% --- Inputs --------------------------------------------------------------

% Validation
p = inputParser;
addRequired(p, 'stack', @(x) isnumeric(x) || ischar(x));
addParameter(p, 'range', NaN, @isnumeric);
addParameter(p, 'color', [1 1 1], @isnumeric);
parse(p, varargin{:});

% -------------------------------------------------------------------------

% --- Assignation

i = numel(this.stacks)+1;

this.stacks(i).mode = 'xyz';

switch class(p.Results.stack)    
    case 'char'
        this.stacks(i).type = 'paf';
        this.stacks(i).data = NT.Paf(p.Results.stack);
        this.stacks(i).size = this.stacks(i).data.size;
    otherwise
        this.stacks(i).type = 'array';
        this.stacks(i).data = p.Results.stack;
        this.stacks(i).size = size(this.stacks(i).data);
end

% Make sure that the three dimensions are present
if numel(this.stacks(i).size)==2
    this.stacks(i).size(end+1) = 1; 
end

this.stacks(i).range = p.Results.range;
this.stacks(i).color = p.Results.color;

% --- Dimensions

this.X = max(this.T, this.stacks(i).size(1));
this.Y = max(this.T, this.stacks(i).size(2));
this.Z = max(this.Z, this.stacks(i).size(3));

% --- Initial position

this.x = max(1,round(this.stacks(i).size(1)/2));
this.y = max(1,round(this.stacks(i).size(2)/2));
this.z = max(1,round(this.stacks(i).size(3)/2));

% --- Manage range

if all(isnan(this.stacks(i).range))
    this.autoRange(i);
end
this.stacks(i).range = double(this.stacks(i).range);