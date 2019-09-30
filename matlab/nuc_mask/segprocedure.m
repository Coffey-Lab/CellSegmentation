% takes a mask made from dapi and segment with totalmembrane mask
% output=segmented nuclear mask
% mask=mask from dapi
% total=total membrane mask
function output = segprocedure (mask,total)
% size 250 or less gets stored as "less", "more" = remaining

pixadj=1;
s= size(mask);
if s(1)~=2048 || s(2)~=2048 %check if images is from Cytell (>2048
    pixadj=3; %adjust for smaller pixel size if Cytell
end

% subtract the totalmembrane from "more" and then store less than 250 as k,
% and "more" as more1
bnw = im2bw(imsubtract (im2bw(mask),im2bw(total)));
mask1_1=bwlabel(bnw,4);
[more1,less1]=thresh(250*pixadj, mask1_1);
k=im2bw(less1);

%watershed segment more1 with parameter 2, and then store 300 < into output
segmented=segmore (more1,2);
mask2=bwlabel (segmented,4);
[more2,less2]=thresh(300*pixadj,mask2);
output=im2bw(imadd(im2bw(k),im2bw(less2)));

%watershed again the remaining with parameter 1, then store 500< into output
segmented = segmore (more2,1);
mask2=bwlabel (segmented,4);
[more2,less2]=thresh(500*pixadj,mask2);
output=im2bw(imadd(im2bw(output),im2bw(less2)));
end


