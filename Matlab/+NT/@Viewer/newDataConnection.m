function id = newDataConnection(this)

% --- Parameters

id = numel(this.Conn.Data) + 1;

% --- Create new connection

% this.sendCommand(['data:' num2str(id) ':new']);

this.Conn.Data(id).conn = tcpip('localhost', this.port);
set(this.Conn.Data(id).conn, 'OutputBufferSize', intmax);
this.Conn.Data(id).available = false;

% --- Open connection

try
    fopen(this.Conn.Data(id).conn);
    if this.verbose
        fprintf('  [[\bconnnection]\b] Data %i\n', id);
    end
    this.Conn.Data(id).available = true;
catch ME
    if this.warnings
        warning(ME.identifier, '%s', ME.message);
    end
    id = NaN;
end

