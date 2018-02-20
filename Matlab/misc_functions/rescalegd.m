function [ imscale ] = rescalegd( im )
%get an image and scales it between 0 and 1

im=double(im);
[DX,DY]=size(im);
npixel=DX*DY;
S=reshape(im,1,npixel);
mincentile=fix(npixel/100)+1;
maxcentile=npixel-fix(npixel/100)-1;
S=sort(S);
imscale=(im-S(mincentile))/(S(maxcentile)-S(mincentile));


end

