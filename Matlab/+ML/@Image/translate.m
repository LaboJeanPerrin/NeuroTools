function translate(this, tx, ty, varargin)
%IMAGES.IMAGE.TRANSLATE image translation
%*  IMAGES.IMAGE.TRANSLATE(TX, TY) translates the current image of TX and 
%   TY.
%
%*  IMAGES.IMAGE.TRANSLATE(..., 'fill', FILL) specifies the filling value. 
%   The default filling value is zero.
%
%*  IMAGES.IMAGE.TRANSLATE(..., 'full', true) changes the image size to 
%   keep all the pixel inside.
%
%*  See also: Images.Image, Images.Image.rotate, Images.Image.scale, Images.Image.shear.

% === Input variables =====================================================

in = inputParser;
in.addRequired('tx', @isnumeric);
in.addRequired('ty', @isnumeric);
in.addParamValue('fill', 0, @isnumeric);
in.addParamValue('full', false, @islogical);

in.parse(tx, ty, varargin{:});
in = in.Results;

% =========================================================================

% --- Transformation matrix
xform = [1     0     0 ; ...
         0     1     0 ; ...
         in.tx in.ty 1];

% --- Transform
if in.full
    
    this.pix = imtransform(this.pix, maketform('affine', xform), ...
        'Xdata', [1 this.width+in.tx], ...
        'Ydata', [1 this.height+in.ty], ...
        'FillValues', in.fill);
    this.width = size(this.pix, 2);
    this.height= size(this.pix, 1);
    
else
    
    this.pix = imtransform(this.pix, maketform('affine', xform), ...
        'Xdata', [1 this.width], ...
        'Ydata', [1 this.height], ...
        'FillValues', in.fill);
    
end