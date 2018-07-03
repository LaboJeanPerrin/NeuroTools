function [dx, dy] = fcorr(this, Img, varargin)
%[Image].fcorr FFT-based image correlation
%   [Image].CORR(IMG) computes the positions of the best image correlation 
%   with image object IMG.
%
%*  See also: ML.Image, ML.Image.corr.

% === Input variables =====================================================

in = inputParser;
in.addParameter('method', 'parabolic', @ischar);
in.parse();

% =========================================================================

% --- Check image objects
if isa(Img, 'ML.Image')
    Img = Img.pix;
end

% --- Perform FFT
FFT = fft2(this.pix).*conj(fft2(Img));
res = ifftshift(ifft2(FFT));

% --- Get maximum
[~, I] = max(res(:));
[x0, y0] = ind2sub(size(res), I);

switch in.Results.method
    
    case 'rough'
        % --- Rough maximum estimation
        
        dx = size(res,1)/2 + 1 - x;
        dy = size(res,2)/2 + 1 - y;

    case 'parabolic'
        % --- Parabolic estimation
        
        x = x0 + [-1 0 1];
        y = res(x, y0);
        dx = size(res,1)/2 + 1 + (x(3)^2*(y(1)-y(2)) + x(2)^2*(y(3)-y(1)) + x(1)^2*(y(2)-y(3)))/...
                                 (x(3)*(y(2)-y(1)) + x(2)*(y(1)-y(3)) + x(1)*(y(3)-y(2)))/2;
                             
        x = y0 + [-1 0 1];
        y = res(x0, x);
        dy = size(res,2)/2 + 1 + (x(3)^2*(y(1)-y(2)) + x(2)^2*(y(3)-y(1)) + x(1)^2*(y(2)-y(3)))/...
                                 (x(3)*(y(2)-y(1)) + x(2)*(y(1)-y(3)) + x(1)*(y(3)-y(2)))/2;
        
end