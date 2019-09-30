% select a list of objects store in mask
% outputs
% mask5 = mask of list of indexes kept
% inputs 
% keep = a list of indexes
% mask = the mask

function mask5=selectobjects(keep,mask)

vecmask=mask(:);
[m1 m2]=size (vecmask);
[c2 c1]=size(keep);
[m2_1 m2_2]=size(mask);
storemask=zeros(m1,1);


for j=1:c1
    mask2=mask==keep(j);
    mask3=mask2(:);
    indices= find (mask3==1); 
    storemask(indices)=keep(j);
end
mask5=vec2mat(storemask,m2_1);
mask5=transpose (mask5);

end