function out = erode(this, varargin)
%[Image].erode Erodes the image
%   [Image].ERODE() Erodes the image with the default structuring element
%
%   [Image].ERODE(..., 'v', true) turns verbose on.
%
%   IMG = [Image].ERODE(...) returns a new instance of image object.
%
%   See also: ML.Image, ML.Image.threshold; ML.Image.dilate.

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
    T.start(['Eroding (''' in.type ''',' num2str(in.size) ')']);
end

% --- Processing
tmp = imerode(this.pix, strel(in.type, in.size));


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
