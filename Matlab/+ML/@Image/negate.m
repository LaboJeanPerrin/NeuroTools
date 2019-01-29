function out = negate(this)
%IMAGES.IMAGE.NEGATE image negative
%*  IMAGES.IMAGE.NEGATE() negates the image.
%
%*  IMG = IMAGES.IMAGE.NEGATE(...) returns a new instance of image object.
%
%*  See also: Images.Image.

this.update_infos();
pix = this.vmax-this.pix;

if nargout
    out = Images.Image(pix);
else
    this.pix = pix;
end