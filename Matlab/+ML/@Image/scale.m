function scale(this, sx, sy, varargin)
%IMAGES.IMAGE.SCALE image scaling
%*  IMAGES.IMAGE.SCALE(SX, SY) scales the current image by factors SX and 
%   SY.
%
%*  IMAGES.IMAGE.ROTATE(..., 'fill', FILL) specifies the filling value. The
%   default filling value is zero.
%
%*  IMAGES.IMAGE.ROTATE(..., 'full', true) changes the image size to keep 
%   all the pixel inside.
%
%*  See also: Images.Image, Images.Image.translate, Images.Image.rotate, Images.Image.shear.

% === Input variables =====================================================

in = inputParser;
in.addRequired('sx', @isnumeric);
in.addRequired('sy', @isnumeric);
in.addParamValue('fill', 0, @isnumeric);
in.addParamValue('full', false, @islogical);

in.parse(sx, sy, varargin{:});
in = in.Results;

% =========================================================================

% --- Transformation matrix

xform = [in.sx 0     0 ; ...
         0     in.sy 0 ; ...
         0     0     1];

% --- Transform
if in.full
    
    this.pix = imtransform(this.pix, maketform('affine', xform), ...
        'FillValues', in.fill);
    this.width = size(this.pix, 2);
    this.height= size(this.pix, 1);
    
else
    
    this.pix = imtransform(this.pix, maketform('affine', xform), ...
        'Xdata', [1 this.width], ...
        'Ydata', [1 this.height], ...
        'FillValues', in.fill);
    
end