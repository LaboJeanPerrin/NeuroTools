function ts = timestamp(this, varargin)
%[Image].timestamp Image timestamp
%   T = [IMAGE].TIMESTAMP() Returns the timestamp T from the current image.
%   T is a struct with fields:
%   - 't': the timestamp in us.
%
%   See also: Image, PCO.timestamp.

switch this.camera
    
    case 'PCO.Edge'
        ts = PCO.timestamp(this, varargin{:});
        
    case 'Andor_iXon'
        ts = struct('t', this.tstamp*1000);
        
    otherwise
        warning('No procedure is defined to get the image timestamp.');
        ts = NaN;
        
end