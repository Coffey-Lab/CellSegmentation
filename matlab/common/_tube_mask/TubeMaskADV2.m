function [ mask ] = TubeMaskADV2( directory , bcat,cd44,pck,ksize , k_area )

% Advanced functon for mask
% filename- list of images paths
% NumMaskIm - number of images to obtain mask
% ksize - kernel size for smoothing
% k_area - low area peremeter for filtration of filled segments

% get compound image to obtain mask
image = Preprocessing2( directory,bcat,cd44,pck);
%----------------------------------------------------------------

%apply gaussian smoothing 
sigma = 0.3 * ((ksize - 1) * 0.5 - 1) + 0.8;
G = fspecial('gaussian', [ksize ksize], sigma);
image = imfilter(image,G,'same');

%apply c-means binarization 
[bw,level]=fcmthresh(image,0);
bw=logical(bw);

%remain filled areas
filledbw = imfill(bw, 'holes'); % Fill holes.
filledsegments=filledbw.*imcomplement(bw);

filledsegments=logical(filledsegments);

% calculate areas of filled segments
s  = regionprops(filledsegments,'Area');
area = cat(1, s.Area);

% filtration of filled segments by area
filtfilledsegments = bwareafilt(filledsegments,[min(area)+k_area*(max(area-min(area))) max(area)]);
filtfilledsegments = imfill(filtfilledsegments, 'holes'); % Fill holes.

%remain only tube segments
mask= filledbw.*imcomplement(filtfilledsegments);
mask=logical(mask);

end

