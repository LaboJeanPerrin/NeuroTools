function load_KVU(this, varargin)

% === Inputs ==============================================================

p = inputParser;
addRequired(p, 'filename', @ischar);
parse(p, varargin{:});
in = p.Results;

% === File parsing ========================================================

% --- Get file content ----------------------------------------------------
fid = fopen(in.filename);
tmp = textscan(fid, '%s', 'delimiter', '\n');
fclose(fid);
File = tmp{1};

% --- Parse file ----------------------------------------------------------

for i = 1:numel(File)
    
    % --- Get line
    line = File{i};
    
    % --- Skip empty lines and comments
    if isempty(line) || strcmp(line(1), '#')
        continue
    end
    
    % --- Parse line
    res = regexp(line, '^([^\s]+)\s+([^\s]+)(\s+.+)?', 'tokens');
    key = res{1}{1};
    value = res{1}{2};
    unit = strtrim(res{1}{3});
    
    if isvarname(key)
        
        this.KVU.(key) = value;
        if ~isempty(unit)
            this.Units.KVU.(key) = unit;
        end
        
    else
        warning('Parameters:KVU:IncorrectKey', ['The key ''' key ''' is not valid.']);
    end
    
end