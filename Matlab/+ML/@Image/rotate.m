function rotate(this, a, varargin)
%IMAGES.IMAGE.ROTATE image rotation
%*  IMAGES.IMAGE.ROTATE(ANGLE) rotates the current image of ANGLE. ANGLE is 
%   expected to be a single value in radian. The trigonometric convention 
%   is used, such that positive angles produce a counterclockwise rotation.
%
%*  IMAGES.IMAGE.ROTATE(..., 'center', XY) specifies the rotation center.
%   XY is expected to be a 1-by-2 vector of pixel positions [x y]. The 
%   default XY value is located at the center of the current image.
%
%*  IMAGES.IMAGE.ROTATE(..., 'degrees', true) uses degrees instead of 
%   radians.
%
%*  IMAGES.IMAGE.ROTATE(..., 'fill', FILL) specifies the filling value. The
%   default filling value is zero.
%
%*  IMAGES.IMAGE.ROTATE(..., 'full', true) changes the image size to keep 
%   all the pixel inside.
%
%*  See also: Images.Image, Images.Image.translate, Images.Image.scale, Images.Image.shear.

% === Input variables =====================================================

in = inputParser;
in.addRequired('a', @isnumeric);
in.addParamValue('center', [], @isnumeric);
in.addParamValue('degrees', false, @islogical);
in.addParamValue('fill', 0, @isnumeric);
in.addParamValue('full', false, @islogical);

in.parse(a, varargin{:});
in = in.Results;

% =========================================================================

% --- Default values
if isempty(in.center)
    in.center = round([this.width/2 this.height/2]);
end

% --- Degrees to radian ?
if in.degrees
    in.a = in.a/180*pi;
end

% --- Transformation matrix

t1 = [1 0 0 ; 0 1 0; -in.center(1) -in.center(2) 1];
rot = [cos(-in.a) sin(-in.a) 0; sin(in.a) cos(-in.a) 0; 0 0 1;];
t2 = [1 0 0; 0 1 0; in.center(1) in.center(2) 1];

xform = t1*rot*t2;

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