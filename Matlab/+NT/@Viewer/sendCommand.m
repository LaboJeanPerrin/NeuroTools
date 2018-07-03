function sendCommand(this, varargin)

% === Inputs ==============================================================

p = inputParser;
addRequired(p, 'command', @ischar);
parse(p, varargin{:});
   
command = p.Results.command; 

% =========================================================================

fwrite(this.Conn.Commands, [command ';']);