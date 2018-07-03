function newCommand(this, varargin)

if ~get(this.Conn.Commands, 'BytesAVailable')
    return;
end

warning off
A = fread(this.Conn.Commands, get(this.Conn.Commands, 'BytesAVailable'));
warning on

in = strtrim(char(A'));
% fprintf('[%s]\n', strrep(in, newline, ' '));
instructions = strsplit(in, ';');

for i = 1:numel(instructions)
    
    % --- Preparation
    
    % Filter
    if ~numel(instructions{i}), continue; end

    % Display
    if this.verbose
        % fprintf('> %s\n', instructions{i});
    end
    
    % Split
    tmp = strsplit(instructions{i}, ':');
    key = strrep(tmp{1}, newline, '');
    value = tmp{2};
        
    % --- Process
    
    switch key
        
        case 'available'
            
            id = str2double(value)+1;
            this.Conn.Data(id).available = true;
%             fprintf('%i is now available\n', id);
            
        case 'time'

%             fprintf('> %s\n', instructions{i});
            this.sendData(1, 'image', 'z', 1, 't', str2double(value));
            
    end

end
   
