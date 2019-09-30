% input
%mucLoc - muc2 tif file?
%total - total membrane mask
%im - cell_mask
% output
%L2 - labeled mask of reseged with Muc2


function L2=shortBatchO(im, total, mucLoc)


% add muc2 mask to cell_mask to result in a combined mask
total=im2bw(total);
im2=im2bw(im);
mask2 = adaptiveimages(mucLoc,50,0);
finalim=imadd(im2,im2bw(mask2));

% find all objects that overlap with muc2 mask and process those
L=bwlabel(finalim, 4);
stats=regionprops(L,mask2,'MeanIntensity');
Intensities=transpose(cell2mat({stats.MeanIntensity}));
indices=find (Intensities>0);
indices2=transpose(indices);
mask5=selectobjects(indices2,L);

total2=total;

%large pieces of membrane get rid of noise
total = bwareaopen(total,30); 

% create maskout, a platette for resegmentation storage
[r c]=size(indices2);
maskout=im2bw(L);
fprintf(['Muc2 ReSeg ' num2str((c)) ' objects; ' ])

% too many objects, so skip
% if c>1000
%     fprintf('>1000 objects to reseg, skipping position')
%     L2=zeros(size(total));
%     return
% end
    tic
h = waitbar(0,'Muc2 ReSeg Processing');
for i = 1:30 %c
    waitbar(i/c, h, [num2str(indices2(i)) ' '  num2str(i) '/' num2str(c) ' Muc2 Objects; Estimated Time Remaining: ' num2str((c-i)*13.5/60) ' mins'])
    
    %go through objects with muc2 mask in them
    tempobject=selectobjects(indices2(i),L);
    
    % get rid of all previous seg to reseg
    se=strel('disk',1);
    tempobject=imclose (tempobject,se);
     
    %reseg the temopobject (1 object at a time)
    %-1 option to turn off final line of reseg
    lines=resegO(tempobject,total,-1); 
    
    % add the object without seg
    maskout =im2bw(imadd (im2bw(maskout),im2bw(tempobject)));
    
    % subtract lines from reseg
    maskout=im2bw(imsubtract(im2bw(maskout),im2bw(lines)));
    
    
end
close(h)

% because of subtract there may be negative numbers
maskout(find (maskout<0))=0;

% bwlabel with 4 connectivity to make sure all close objects identified
L2=bwlabel(maskout,4);
toc
%imwrite (uint16(L2),'maskout.tif'); %new cell seg