function h = show(this, varargin)
%IMAGES.IMAGE.SHOW show the image
%*  IMAGES.IMAGE.SHOW() show the image.
%
%*  IMAGES.IMAGE.SHOW(FIG) show the image in figure FIG. The default is the
%   current figure.
%
%*  See also: Images.Image.

% === Input variables =====================================================

in = ML.Input(varargin{:});
in.addParamValue('fig', gcf, @isnumeric);
in.addParamValue('range', [], @isnumeric);
[in, unmin] = +in;

% =========================================================================

% --- Set figure
figure(in.fig);

% --- Default range
if isempty(in.range) || numel(unique(this.pix(:)))==2
    in.range = [min(this.pix(:)) max(this.pix(:))];
    
    if islogical(in.range)
        in.range = double(in.range);
    end
end

% --- Display
out = imshow(this.pix, in.range, 'InitialMagnification', 'fit', unmin{:});

% --- Adjustment
axis image ij on

% --- Output
if nargout
    h = out;
end