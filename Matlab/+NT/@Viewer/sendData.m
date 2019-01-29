function sendData(this, varargin)

% === Inputs ==============================================================

p = inputParser;
addRequired(p, 'index', @isnumeric);
addRequired(p, 'dataType', @(x) ismember(x, {'image', 'vertex', 'face', 'cmap'}));
addParameter(p, 'z', 1, @isnumeric);
addParameter(p, 't', 1, @isnumeric);
parse(p, varargin{:});
   
dataType = p.Results.dataType; 
index = p.Results.index;
z = p.Results.z;
t = p.Results.t;

% =========================================================================

% --- Prepare data

data = this.dataSet(index).data(:,:,z,t);
data(1383:1384,:) = 0;
data = data';

% --- Find data channel

id = this.findAvailableDataConnection();
% fprintf('id choosen for time %i: %i\n', t, id);

if isnan(id)
    if this.warnings
        warning('NT.Viewer.sendData', '%s', 'Could not find an available connection.');
    end
    return;
end

% --- Send data

% Lock connection
this.Conn.Data(id).available = false;

% Send data info
pref = ['data:' num2str(id) ':'];

this.sendCommand([pref 'type:' dataType ';' ...
    pref 'index:' num2str(index) ';' ...
    pref 'z:' num2str(z) ';' ...
    pref 't:' num2str(t) ';' ...
    pref 'size:' num2str(numel(data)) ';' ...
    pref 'check']);

% Send data
fwrite(this.Conn.Data(id).conn, data(:));
