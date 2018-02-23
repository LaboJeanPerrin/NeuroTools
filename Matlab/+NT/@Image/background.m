function [B, S] = background(this)
%[Image].background Get background mean value and standard deviation
%   B = [Image].BACKGROUND() Returns the mean value of the background in
%   the image.
%
%   [B, S] = [Image].BACKGROUND() also returns the standard deviation.
%
%   See also: Image, Image.show.

% --- Cumulated PDF
[f, bin] = ecdf(this.pix(:));

plot(bin, f)
% 
% keyboard

% --- Differentiate cPDF (in semilog mode)
b = (bin(1:end-1)+bin(2:end))/2;
x = log(b);
d = diff(f);

I = isfinite(x);
b = b(I);
x = x(I);
d = d(I);

% --- Focus on the dark values
[~, m] = max(d);
s = d(1:m);
x = x(1:m);
I = x>0;

f = fit(x(I), s(I), 'Gauss1');

% --- Output
B = exp(f.b1);
S = exp(f.c1/sqrt(2));