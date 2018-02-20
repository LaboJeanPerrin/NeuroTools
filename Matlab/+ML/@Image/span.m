function H = span(this, varargin)
%IMAGES.IMAGE.SPAN image span
%*  IMAGES.IMAGE.SPAN() re-span the pixel values range in [0 this.mval].
%
%*  See also: Images.Image, Images.Image.hist.
    
% Get range
minv = min(this.pix(:));
maxv = max(this.pix(:));

this.pix = (this.pix-minv)/(maxv-minv)*this.mval;