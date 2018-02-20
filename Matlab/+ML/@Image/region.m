function out = region(this, reg)
%IMAGES.IMAGE.REGION Select region in an image
%*  REGION(REG) select the region REG in an image. REG should be a 1-by-4
%   array [x1 x2 y1 y2].
%
%*  IMG = REGION(...) returns a new instance of image object.
%
%*  See also: Images.Image.

pix = this.pix(reg(3):reg(4), reg(1):reg(2), :);

if nargout
    out = Images.Image(pix);
else
    this.pix = pix;
    this.update_infos();
end