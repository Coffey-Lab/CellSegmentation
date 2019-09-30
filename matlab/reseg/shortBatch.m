% input
%mucLoc - muc2 tif file?
%total - total membrane mask
%im - cell_mask
% output
%L2 - labeled mask of reseged with Muc2


function L2=shortBatch(im, total, mucLoc)


% add muc2 mask to cell_mask to result in a combined mask
total=im2bw(total);
im2=im2bw(im);
clear im
mask2 = adaptiveimages(mucLoc,50,0);
finalim=imadd(im2,im2bw(mask2));
clear im2

% find all objects that overlap with muc2 mask and process those
L=bwlabel(finalim, 4);
clear finalim
stats=regionprops(L,mask2,'MeanIntensity');
Intensities=transpose(cell2mat({stats.MeanIntensity}));
indices=find (Intensities>0);
indices2=transpose(indices);
%mask5=selectobjects(indices2,L); %not used

%total2=total; %not used

%large pieces of membrane get rid of noise

 s= size(L);
    pixadj=1;
    if s(1)~=2048 || s(2)~=2048 %check if images is from Cytell ~=2048
        pixadj=2; %adjust for smaller pixel size if Cytell
    end




total = bwareaopen(total,pixadj*30); 

% create maskout, a platette for resegmentation storage
c=length(indices2);
maskout=im2bw(L);
fprintf(['Muc2 ReSeg ' num2str((c)) ' objects; ' ])

% too many objects, so skip
% if c>1000
%     fprintf('>1000 objects to reseg, skipping position')
%     L2=zeros(size(total));
%     return
% end

sMask=size(maskout);    
h = waitbar(0,'Muc2 ReSeg Processing');
for i = 1:c
    waitbar(i/c, h, [num2str(indices2(i)) ' '  num2str(i) '/' num2str(c) ' Muc2 Objects; Estimated Time Remaining: ' num2str((c-i)*5/60) ' mins'], 'WindowStyle', 'modal')
    
    %go through objects with muc2 mask in them
    %tempobject=selectobjects(indices2(i),L);
    tempobject=L==indices2(i);
    
    
    % get rid of all previous seg to reseg
    %se=strel('disk',1);
    tempobject=imclose (tempobject,strel('disk',1));
    
       
    BBox=BBoxCalc(tempobject);
    
    subObject=tempobject(BBox(2):BBox(4),BBox(1):BBox(3));
    subTotal=total(BBox(2):BBox(4),BBox(1):BBox(3));
    
    [a,b]=size(subObject);
    if a*b>160000
        continue
    end
    
    %reseg the temopobject (1 object at a time)
    %-1 option to turn off final line of reseg
    lines=reseg(subObject,subTotal,-1);
    
    %lines=reseg(tempobject,total,-1); 
    
    linesSub=false(sMask);
    linesSub(BBox(2):BBox(4),BBox(1):BBox(3))=lines;
    
    
    % add the object without seg
    maskout =im2bw(imadd (im2bw(maskout),im2bw(tempobject)));
    
    % subtract lines from reseg
    maskout=im2bw(imsubtract(im2bw(maskout),im2bw(linesSub)));
    
    
end
close(h)

% because of subtract there may be negative numbers
maskout(find (maskout<0))=0;

% bwlabel with 4 connectivity to make sure all close objects identified
L2=bwlabel(maskout,4);

%imwrite (uint16(L2),'maskout.tif'); %new cell seg