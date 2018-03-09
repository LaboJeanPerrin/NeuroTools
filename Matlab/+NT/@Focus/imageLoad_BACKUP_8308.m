function Img = imageLoad(this, n, varargin)
%[Focus].iload Image load
%   IMG = [Focus].ILOAD(N) Returns image number N.
%
%   [Focus].ILOAD(..., MODE) specifies the MODE, which can be 'abs'
%   (absolute) or 'rel' (relative, default). In absolute mode, N is assumed
%   to be the image number while in relative mode N is the frame number in 
%   the selected set.
%
%   See also: Focus.

% === Input variables =====================================================

in = inputParser;
in.addRequired('n', @isnumeric);
in.addOptional('mode', 'rel', @ischar);

in.parse(n, varargin{:});
in = in.Results;

% =========================================================================

<<<<<<< HEAD:Matlab/+NT/@Focus/imageLoad.m
Img = Image(this.imageName(in.n, in.mode));
=======
Img = NT.Image(this.imageName(in.n, in.mode));
>>>>>>> easyRLS:Matlab/+NT/@Focus/imageLoad.m
Img.camera = this.IP.camera;
Img.range = this.IP.range;

switch this.IP.camera
    case 'Andor_iXon'
        Img.tstamp = this.set.t(in.n);
end
