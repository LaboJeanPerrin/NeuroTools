function range = autorange(this)
%[Image].autorange Get value range for nice image visualization
%   RANGE = [Image].AUTORANGE() Returns the range for visualization.
%
%   See also: Image.rm_infos, Image.show.

% === Parameters ==========================================================

th = 0.0005;

% =========================================================================

[f, bin] = ecdf(this.pix(:));  
range = bin([find(f>=th,1,'first') find(f<=1-th,1,'last')])';