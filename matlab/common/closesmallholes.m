%fill holes of size
% inputs
% tm = a mask (bw) 
% size = size of small holes
%
% outputs
% output = mask with no small holes
function output = closesmallholes (tm,size)
    im2=imfill (tm,'holes');
    holes = im2 & ~tm;
    bigholes = bwareaopen(holes, size); %2000 for big
    smallholes = holes & ~bigholes;
    output = tm | smallholes;
end