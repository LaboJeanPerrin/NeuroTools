function E = ellipse(this, varargin)
%IMAGES.IMAGE.ELLIPSE Get equivalent ellipse of a grayscale image.
%*  E = IMAGES.IMAGE.ELLIPSE() returns the equivalent ellipse of image.
%
%*  E = IMAGES.IMAGE.ELLIPSE(I) computes the equivalent ellipse on the
%   pixels listed in the index array I.
%
%*  See also: Images.Image.

% === Input variables =====================================================

in = inputParser;
in.addOptional('I', NaN , @isnumeric);

in.parse(varargin{:});
in = in.Results;

% =========================================================================

% --- Defaut indexes
if isnan(in.I)
   in.I = 1:this.width*this.height; 
end


E = struct();

% Compute the moments
E.m00 = moment(this.pix, in.I, 0, 0);
E.m10 = moment(this.pix, in.I, 1, 0);
E.m01 = moment(this.pix, in.I, 0, 1);
E.m11 = moment(this.pix, in.I, 1, 1);
E.m02 = moment(this.pix, in.I, 0, 2);
E.m20 = moment(this.pix, in.I, 2, 0);

% Compute the ellipse properties
E.x = E.m10/E.m00;
E.y = E.m01/E.m00;

a = E.m20/E.m00 - E.x^2;
b = 2*(E.m11/E.m00 - E.x*E.y);
c = E.m02/E.m00 - E.y^2;

E.theta = 1/2*atan(b/(a-c)) + (a<c)*pi/2;
E.w = sqrt(6*(a+c-sqrt(b^2+(a-c)^2)))/2;
E.l = sqrt(6*(a+c+sqrt(b^2+(a-c)^2)))/2;

% -------------------------------------------------------------------------
function m = moment(Img, I, p, q)

[j, i] = ind2sub(size(Img),I);

m = sum((i.^p).*(j.^q).*double(Img(I)));

