function shear(this, shx, shy, varargin)
%IMAGES.IMAGE.SHEAR image shear
%*  IMAGES.IMAGE.SHEAR(SHX, SHY) shears the current image by factors SHX 
%   and SHY.
%
%*  IMAGES.IMAGE.SHEAR(..., 'fill', FILL) specifies the filling value. The 
%   default filling value is zero.
%
%*  IMAGES.IMAGE.SHEAR(..., 'full', true) changes the image size to keep 
%   all the pixel inside.
%
%*  See also: Images.Image, Images.Image.translate, Images.Image.rotate, Images.Image.scale.

% === Input variables =====================================================

in = inputParser;
in.addRequired('shx', @isnumeric);
in.addRequired('shy', @isnumeric);
in.addParamValue('fill', 0, @isnumeric);
in.addParamValue('full', false, @islogical);

in.parse(shx, shy, varargin{:});
in = in.Results;

% =========================================================================

% --- Transformation matrix

xform = [1       -in.shy 0 ; ...
         -in.shx 1       0 ; ...
         0       0       1];

% --- Transform
if in.full
    
    this.pix = imtransform(this.pix, maketform('affine', xform), ...
        'FillValues', in.fill);
    this.width = size(this.pix, 2);
    this.height= size(this.pix, 1);
    
else
    
    tmp = imtransform(this.pix, maketform('affine', xform), ...
        'FillValues', in.fill);
    this.pix  = tmp(1:this.width, 1:this.height);
end