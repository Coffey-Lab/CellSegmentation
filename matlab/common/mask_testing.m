Probs=imread('/Users/etmckinley/Dropbox (VUMC)/scan_alpha/TCPS4A/SegQuant/ML/mem_009_stack_Probabilities.png');
mem=Probs(:,:,1);
nuc=Probs(:,:,2);

nuc=nuc>255*.6;

imwrite(nuc, '/Users/etmckinley/Dropbox (VUMC)/scan_alpha/TCPS4A/SegQuant/NucMask/mem_009_nuc.png');

mem=mem>255*.6;
total=mem;
imwrite(mem, '/Users/etmckinley/Dropbox (VUMC)/scan_alpha/TCPS4A/SegQuant/NucMask/mem_009_mem.png');

pixadj=1;
nuc=closesmallholes (nuc,1000*pixadj);

% label
mask = bwlabel(nuc,4); 

%segment nuclear mask
output =segprocedure (mask, total);

 
% mask using all nuclei markers 
if ~isempty(nucdir) %skip if there are no markers

    mask=maskallnuc (nucdir,50*pixadj,total);
end
 
%add dapi mask with allnucmask
added=im2bw(imadd(im2bw(mask),im2bw(output)));


%redo seg one more time because things would have been connected
mask=bwlabel(added,4);
output = segprocedure (mask,total);
output=closesmallholes (output,1000*pixadj);

%run an open function to remove spurs and other small openings
se=strel('disk', 2*pixadj);  
output=imopen(output,se);
output=bwlabel(output,4);




nuc = uint8( (double(nuc) - double(min(nuc(:)))) /(double(max(nuc(:))) - double(min(nuc(:)))) * 255 );
nuc=adapthisteq(nuc);
nuc=im2bw(nuc,graythresh(nuc));
imshow(nuc)

