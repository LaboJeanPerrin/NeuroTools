function out = corr(this, Img)
%IMAGES.IMAGE.CORR image correlation
%*  OUT = IMAGES.IMAGE.CORR(IMG) computes the image correlation.
%
%*  See also: Images.Image.


% --- Check image objects
if isa(Img, 'Images.Image')
    Img = Img.pix;
end

% --- Perform FFT
FFT = fft2(this.pix).*conj(fft2(Img));
out = ifftshift(ifft2(FFT));