function out = copy(this)
%[Image].copy Copy image object
%   C = [Image].COPY() Duplicates the image object.
%
%   See also: ML.Image.

out = eval([class(this) '([])']);

f = fields(this);
for i = 1:numel(f)
    out.(f{i}) = this.(f{i});
end
