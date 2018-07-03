function bw = flex(this)
%IMAGES.IMAGE.FLEX Find Local Extrema
%*  I = IMAGES.IMAGE.FLEX() finds the local extrema.
%
%*  See also: Images.Image.


bw = this.pix > imdilate(this.pix, [1 1 1; 1 0 1; 1 1 1]);

% --- Output