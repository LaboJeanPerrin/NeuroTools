function [v, u] = uconv(this, p, varargin)
%Focus.uconv Unit conversion 
%   [V, U] = FOCUS.UCONV(PNAME) Converts the property PNAME in standard 
%   units (seconds, meters). PNAME should be a string. V is the value in 
%   standard units and U is the corresponding unit.
%
%   [V, U] = FOCUS.UCONV(PNAME, UNIT) Converts the property PNAME in units
%   defined by UNIT. UNIT is a string that can be:
%   - Time:      us, ms, s
%   - Distances: um, mm, m
%
%   See also: Focus.

% === Inputs ==============================================================

in = ML.Input(p, varargin{:});
in.addRequired('p', @ischar);
in.addOptional('unit', '', @ischar);
in = +in;

% =========================================================================

% --- Get current value and unit
switch in.p
    case {'dx', 'dy', 'dt', 'exposure'}
        v = this.(in.p);
    case {'z', 't'}
        v = this.set.(in.p);
end
u = this.units.(in.p);

% --- Conversion to SU
switch u
    case 'us'
        v = v*1e-6;
        u = 's';
        
    case 'ms'
        v = v*1e-3;
        u = 's';
        
    case 'um'
        v = v*1e-6;
        u = 'm';
        
    case 'mm'
        v = v*1e-3;
        u = 'm';
end

% --- Specific conversion
if ~isempty(in.unit)
    
    % Checks
    if strcmp(u, 's') && ~ismember(in.unit, {'us', 'ms', 's'})
        error('Unknown unit for a time. Please chose a unit among ''us'', ''ms'' and ''s''.');
    end
    
    if strcmp(u, 'm') && ~ismember(in.unit, {'um', 'mm', 'm'})
        error('Unknown unit for a distance. Please chose a unit among ''um'', ''mm'' and ''m''.');
    end
    
    % Conversion
    switch in.unit
        case {'us', 'um'}, v = v*1e6;
        case {'ms', 'mm'}, v = v*1e3;
    end
    u = in.unit;
end