function out = imageName(this, n, varargin)
%[Focus].iname Filename corresponding to an image.
%   OUT = [Focus].INAME(N) returns the filename corresponding to the image
%   number N.
%
%   [Focus].INAME(..., MODE) specifies the MODE, which can be 'abs'
%   (absolute) or 'rel' (relative, default). In absolute mode, N is assumed
%   to be the image number while in relative mode N is the frame number in 
%   the selected set.
%
%   See also: Focus, Focus.isave, Focus.iload, Focus.fname.

% === Input variables =====================================================

in = inputParser;
in.addRequired('n', @isnumeric);
in.addOptional('mode', 'rel', @ischar);

in.parse(n, varargin{:});
in = in.Results;

% =========================================================================

% --- Get image name
switch in.mode
    case 'rel'
        
        % --- Checks
        if ~isa(this.set, 'struct')
            warning('FOCUS:INAME', 'No set selected, aborting.');
            out = NaN;
            return
        end

        in.n = this.set.frames(in.n);
end

out = [this.Images this.IP.prefix num2str(in.n, this.IP.format) '.' this.IP.extension];
