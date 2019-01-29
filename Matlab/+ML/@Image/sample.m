function out = sample(this, N)
%IMAGES.IMAGE.SAMPLE Re-sample an image
%*  SAMPLE(N) keep one pixel out of N^2.
%
%*  IMG = SAMPLE(...) returns a new instance of image object.
%
%*  See also: Images.Image.

pix = this.pix(1:N:this.height, 1:N:this.width);

if nargout
    out = Images.Image(pix);
else
    this.pix = pix;
    this.update_infos();
end