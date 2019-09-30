%output total = combined membrane bnw
%input lev = size of adaptive threshold - 10 for membrane
%directory = list of membrane images 
%unsharp = 1 or 0 to use unsharp masking in adaptive image

function [total]=batchmembrane(lev,directory, unsharp)
filename=directory;
s=size(filename);
s=s(2);

%use adaptive thresholding
total=adaptiveimages(char(filename(1)),lev,unsharp);
for i=2:s
    
    I=adaptiveimages(char(filename(i)),lev,unsharp);
    total=im2bw(imadd (im2bw(total),im2bw(I)));
    
    
end

end
