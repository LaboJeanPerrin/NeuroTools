function XYZt(this, varargin)

% === Inputs ==============================================================

p = inputParser;
addRequired(p, 'data', @(x) isnumeric(x) || ischar(x));
addParameter(p, 'name', '', @ischar);
addParameter(p, 'cmap', [], @isnumeric);
addParameter(p, 't', 1, @isnumeric);
parse(p, varargin{:});
   
data = p.Results.data; 
name = p.Results.name; 
cmap = p.Results.cmap;
t = p.Results.t; 

% =========================================================================

% --- Name
if isempty(name)
    name = ['dataset_' num2str(numel(this.dataSet)+1)];
end

% --- Dimensions

if isnumeric(data)
    
    X = size(data,2);
    Y = 1384; % size(data,1);
    Z = size(data,3);
    T = size(data,4);
    
else
    
    ...
        
end

% --- Create dataset

i = numel(this.dataSet) + 1;

this.dataSet(i).type = 'XYZt';
this.dataSet(i).name = name;
this.dataSet(i).X = X;
this.dataSet(i).Y = Y;
this.dataSet(i).Z = Z;
this.dataSet(i).T = T;
this.dataSet(i).data = data;
this.dataSet(i).transform = NaN;
this.dataSet(i).cmap = cmap;
this.dataSet(i).visible = true;
this.dataSet(i).frozen = false;
this.dataSet(i).t = t;
this.dataSet(i).x2um = NaN;
this.dataSet(i).y2um = NaN;
this.dataSet(i).z2um = NaN;
this.dataSet(i).t2s = NaN;

% --- Send dataset
this.sendDataSet(i, 'sendData', true);