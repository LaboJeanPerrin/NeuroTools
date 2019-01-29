function histeq(this)
%IMAGES.IMAGE.HISTEQ histogram egalisation
%*  IMAGES.IMAGE.HISTEQ() equalizes the histogram of the image. this
%   operation flattens the image histogram, each level of grey being
%   equally represented.
%
%*  See also: Images.Image.

bin = 0:this.mval+1;

h = histc(this.pix(:), bin);
c = cumsum(h);

this.pix(:) = c(this.pix(:)+1)*this.mval/c(end);
