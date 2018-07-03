function out = dilate(this, varargin)
%[Image].dilate Dilates the image
%   [Image].DILATE() Dilates the image with the default structuring element
%
%   [Image].DILATE(..., 'v', true) turns verbose on.
%
%   IMG = [Image].DILATE(...) returns a new instance of image object.
%
%   See also: ML.Image, ML.Image.threshold, ML.Image.erode.

% === Input variables =====================================================

in = ML.Input(varargin{:});
in.addParamValue('type', 'disk', @(x) ismember(x,{'disk'}));
in.addParamValue('size', 10, @isnumeric);
in.addParamValue('v', false, @islogical);
in = +in;

% =========================================================================

% --- Verbose
if in.v
    T = ML.Time.Display;
    T.start(['Dilating (''' in.type ''',' num2str(in.size) ')']);
end

% --- Processing
tmp = imdilate(this.pix, strel(in.type, in.size));

% --- Output
if nargout
    out = ML.Image(tmp);
else
    this.pix = tmp;
end

% --- Verbose
if in.v
    T.stop;
end
