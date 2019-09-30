%segment using watershed
%output: bw3=segmented
%name: image (or file)
%s=level 1 or 2
%2
function bw3=segmore (name,s);
if ischar(name)==1
    I = imread(name);
else
   I=name;
end

bw=I;
D = -bwdist(~bw);
Ld = watershed(D);
bw2 = bw;
bw2(Ld==0)=0;
%2
mask = imextendedmin(D,s);
D2 = imimposemin(D,mask);
Ld2 = watershed(D2);
bw3 = bw;
bw3(Ld2==0)=0;
end