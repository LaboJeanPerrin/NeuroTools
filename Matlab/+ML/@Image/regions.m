function out = regions(this, varargin)
%[Image].regions Extract regions from a BW image
%   OUT = [Image].regions() Extracts the positive regions (logical true) in a
%   black and white image. OUT is a struct with default fields:
%       - Area
%       - Centroid
%
%   OUT = [Image].regions(..., property, value) Adds the fields
%   corresponding to 'properties' in the output. The possible properties
%   are the same than for the REGIONPROPS function.
%
%   See also: ML.Image, regionprops.

% --- Default fields
if isempty(varargin)
    varargin = {'Area', 'Centroid'};
end

out = regionprops(logical(this.pix), varargin{:});