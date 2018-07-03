function out = getTimestamp(varargin)
%PCO.getTimestamp Extract timestamp from a PCO image
%   TS = PCO.getTimestamp(IMG) get the timestamp from a PCO image. TS is a
%   struct with fields:
%   - 't':      The timestamp (in microseconds)
%   - 'min':    The minute
%   - 'hour':   The hour
%   - 'day':    The day
%   - 'month':  The month
%   - 'year':   The year
%   - 'text':   The date, in text format
%
%   See also PCO.setTimestamp, PCO.rm_field

% --- Input variables -----------------------------------------------------

in = ML.Input;
in.img = @(x) ischar(x) | isnumeric(x);
in.verbose(true) = @islogical;
in = +in;

% -------------------------------------------------------------------------

% --- Get first pixels (raw)

if ischar(in.img)
    
    try
        
        % --- Get the NeuroTools toolkit path
        [~, tk] = ML.Projects.current;
        I = find(ismember({tk(:).name}, 'NeuroTools'));
        if numel(I)~=1
            error('PCO:getTimestamp:NoToolkit', 'The NeuroTools toolkit is not selected.');
        end
        
        [status, cmdout] = unix([tk(I).path 'Programs/C++/Hardware/PCO/ts ''' in.img '''']);
        if status
            error('PCO:getTimestamp:ImageReadError', cmdout);
        else
            
            % Awfull hack
            tmp = strsplit(cmdout, char(10));
            cmdout = strtrim(tmp{2});
            
            raw = uint16(str2double(strsplit(cmdout, ' ')));
        end
        
    catch ME
                
        if in.verbose
            warning(ME.identifier, ME.message);
        end
        
        in.img = imread(in.img);
    end
end

% Get raw bits
if isnumeric(in.img)
    raw = in.img(1,1:14);
end


% --- Preparation
out = struct('t', 0);
extract = @(n) double(mod(raw(n),16) + 10*idivide(raw(n),16));

% --- Process

% Get time in microseconds
for n = 11:14
    p = (14-n)*2;
    out.t = out.t + double(mod(raw(n),16))*10^p + double(idivide(raw(n),16))*10^(p+1);
end

% Get times
out.sec = out.t/10^6;
out.min = extract(10);
out.hour = extract(9);
out.day = extract(8);
out.month = extract(7);
out.year = extract(6) + extract(5)*100;

% Get number
out.num = extract(4) + 100*(extract(3) + 100*(extract(2) + 100*(extract(1))));

% Get final timestamp
out.t = out.t + 10^6*(60*(out.min + 60*out.hour));

% Text format
out.text = sprintf('%i-%i-%i %i:%i:%.06f', out.year, out.month, out.day, out.hour, out.min, out.sec);

