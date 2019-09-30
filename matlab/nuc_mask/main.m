%% 
% inputs
% mem - list of files that are membrane stains
% nuc - dapi file
% nucdir - list of files that are nuclear stains
% unsharp -flag for using unsharp mask (0 or 1)
%
% outputs
% output - nuc_mask
% SuperMem - supermem grey scale
% total - total membrane mask
function [output, SuperMem, total] = main (mem,nuc,nucdir)

unsharp=0;

% create a total membrane mask


% create supermembrane mask

    total=im2bw(batchmembrane (10,mem, unsharp));
    SuperMem=batchmembraneGray(0,mem);

% create a basic nuclear dapi mask by otsu on adaptive
nuc=imread(nuc);
pixadj=1; %use no adjustment for 2048x2048 images (Olympus)
s= size(nuc);
if s(1)~=2048 || s(2)~=2048 %check if images is from Cytell (>2048
    pixadj=1; %adjust for smaller pixel size if Cytell
end

% make a 16 bit - 8 bit, equalize histogram
nuc = uint8( (double(nuc) - double(min(nuc(:)))) /(double(max(nuc(:))) - double(min(nuc(:)))) * 255 );
nuc=adapthisteq(nuc);
nuc=im2bw(nuc,graythresh(nuc));

% close small holes in nuc mask
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


end