function update_infos(this)
%IMAGES.IMAGE.UPDATE_INFOS Update image information
%*  IMAGES.IMAGE.UPDATE_INFOS() Updates image information.
%
%*  See also: Images.Image.

% Set width and height
this.width = size(this.pix, 2);
this.height = size(this.pix, 1);

% Min-max pixel value
this.vmax = max(this.pix(:)); 
this.vmin = min(this.pix(:)); 

% Colormap
if ~isnan(this.vmax)
    this.cmap = gray(this.vmax);
end