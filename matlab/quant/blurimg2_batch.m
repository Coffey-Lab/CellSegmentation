function [closed]= blurimg2_batch(nuc)
%finds the blurred regions from the dapi image to exclude from further
%analysis
%inputs:
%nuc=DAPI image

nuc=uint8( (double(nuc) - double(min(nuc(:)))) /(double(max(nuc(:))) - double(min(nuc(:)))) * 255 );
nuc=adapthisteq(nuc);

e = edge(nuc,'Sobel',0.04);
se = strel('disk',20);
closed=imclose(e,se);
%closed=uint8(closed);
%img2=imgorg.*closed;

