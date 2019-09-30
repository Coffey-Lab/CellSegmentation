%inputs
%memx= cell segmentation from prior functions
%nuc= nuclear mask (binary)
%tube= epithelial mask
%total= membrane bask (binary)
%mucLoc = Muc 2 tif file
% dapi = dapi tif file
% super= supermembrane grayscale from main

%outputs
%out3 = nuclear mask
%mem5 = cell mask

function [mem5, out2]=NucCountBatch(memx, nuc, tube, total, mucLoc, dapi, super)
totalorig=total;
% get rid of small size and no nuclei -- >cell_mask
memx=bwlabel(memx,4);
mem=ridSmall(memx,nuc);
mem=im2bw(mem);

%nuclei in epithelial
nucBW= (tube&nuc);

% just add the nuclei_mask to cell_mask to get rid of bisected nuclear
% (with membrane)
mem = nucBW + mem;


% denoise membrane mask
%total = bwareaopen(total,30);

% find a muc2 mask
if isempty(mucLoc)
    mask2=zeros(size(total));
else
    mask2 = adaptiveimages(mucLoc,50,0);
end

%muc2 mask > nuclear mask
nuc=im2bw(imsubtract(im2bw(nuc),im2bw(mask2)));

% get rid of tiny nuclei (remnants from subtraction
nuc=bwareaopen(nuc,13);

% find cell_mask objects with multiple nuclei
k2=multiNuc(mem,nuc);

% find all indices in k2
indices=unique (k2);
indices=indices(indices>0);
[r c]=size (indices);
k3=im2bw(k2);

fprintf(['MultiNuc Reseg Step 1 ' num2str((r)) ' objects; '])

h = waitbar(0,'MultiNuc Reseg Processing Step 1');

sMask=size(k3);

for i = 1:r
    %i  
    waitbar(i/r, h, [num2str(indices(i)) ' ' num2str(i) '/' num2str(r) ' MulitNuc Reseg Objects Step 1; Estimated Time Remaining: ' num2str((r-i)*2/60) ' mins'], 'WindowStyle', 'modal')
    tempobject=ismember(k2,indices(i));
    %selectobjects(indices(i),k2);
    
    %k3 is the storage plalette mask
    % mem is the full cell_mask for keeping track
    
    % subtract the tempobject
    k3=im2bw(imsubtract(im2bw(k3),im2bw(tempobject)));
    mem=im2bw(imsubtract(im2bw(mem),im2bw(tempobject)));
    
    % remove all previosu seg
    se=strel('disk',1);
     tempobject=imclose (tempobject,se);
    
     % create bounding box and extract
     BBox=BBoxCalc(tempobject);
    
    subObject=tempobject(BBox(2):BBox(4),BBox(1):BBox(3));
    subTotal=total(BBox(2):BBox(4),BBox(1):BBox(3));
    
 	[a,b]=size(subObject);
    if a*b>160000
        continue
    end
    
    lines=reseg(subObject,subTotal,-1);
    
    linesSub=false(sMask);
    linesSub(BBox(2):BBox(4),BBox(1):BBox(3))=lines;
     
     
     % reseg with -1, to refill the lines that was erased by nuc add
     %lines=reseg(tempobject,total,-1);
     
     % object is the object subtract the lines
     output=imsubtract(im2bw(tempobject),im2bw(linesSub));
    
    % add back this object to the palette and main masks 
    k3=im2bw(imadd(im2bw(k3),im2bw(output)));
    mem=im2bw(imadd(im2bw(mem),im2bw(output)));
end

close(h)

% get rid of small objects and then find remainder that has multi muc
k4=ridSmall(k3,nuc);
r1=multiNuc(k4,nuc);

%%
%redo dapi, first by looking only at dapi inside the objects remaining
dapi2=dapi.*uint8(im2bw(r1));

% simple otsu size has to be > 50, not noise from otsu
level=graythresh(dapi2);
dapi3=im2bw(dapi2,level+0.01);
dapi4 = bwareaopen(dapi3,50);

% new out by subtracting previous nuc, and then adding back the new mask
% only inside objects
out2=im2bw(imsubtract (im2bw(nuc),im2bw(r1)));
out2=im2bw(imadd (im2bw(out2),im2bw(dapi4)));

% get remainder from this 
r2=multiNuc(r1,out2);

%%
%out2 and mem current nuc_mask and cell_mask, r2 is the remainder object

%use supermembrane mask to do simple watershed
super2=super.*uint8(im2bw(r2));
mem2=im2bw(imsubtract(im2bw(mem),im2bw(r2)));
bw3=segmore(super2,1);
bw3=bw3>0; % turns objects white
mem3=im2bw(imadd(im2bw(mem2),im2bw(bw3))); %subtract and delete trick
% multinuc remain
r3=multiNuc(bw3,out2);

%%
total = bwareaopen(totalorig,2);

indices=unique (r3);
indices=indices(indices>0);
[r c]=size (indices);
k4=im2bw(r3);

fprintf(['MultiNuc Reseg Step 2 ' num2str((r)) ' objects; '])

h = waitbar(0,'MultiNuc Reseg Processing Step 2');

for i = 1:r
    %i  
    waitbar(i/r, h, [num2str(indices(i)) ' ' num2str(i) '/' num2str(r) ' MulitNuc Reseg Objects Step 2; Estimated Time Remaining: ' num2str((r-i)*2/60) ' mins'], 'WindowStyle', 'modal')
    
    tempobject=ismember(r3, indices(i));
    %tempobject=selectobjects(indices(i),r3);
    k4=im2bw(imsubtract(im2bw(k4),im2bw(tempobject)));
    mem3=im2bw(imsubtract(im2bw(mem3),im2bw(tempobject)));
     se=strel('disk',1);
     tempobject=imclose (tempobject,se);
     
      BBox=BBoxCalc(tempobject);
    
    subObject=tempobject(BBox(2):BBox(4),BBox(1):BBox(3));
    subTotal=total(BBox(2):BBox(4),BBox(1):BBox(3));
    
 	[a,b]=size(subObject);
    if a*b>160000
        continue
    end    

    lines=reseg(subObject,subTotal,-1);
    
    linesSub=false(sMask);
    linesSub(BBox(2):BBox(4),BBox(1):BBox(3))=lines;
     
     
    %lines=reseg(tempobject,total,-1,5);
    output=imsubtract(im2bw(tempobject),im2bw(linesSub));
    k4=im2bw(imadd(im2bw(k4),im2bw(output)));
    mem3=im2bw(imadd(im2bw(mem3),im2bw(output)));
end
close(h)

k5=ridSmall(k4,out2);

r4=multiNuc(k5,out2);

%%
% filter small bits of nuc out in 2 nuclei. 
temp=out2&r4;
out2=im2bw(imsubtract (im2bw(out2),im2bw(temp)));
L=bwlabel(temp,4);
area=regionprops(L,'Area');
Areas=transpose(cell2mat({area.Area}));
temp2=ismember (L,find(Areas>75));
out2=im2bw(imadd (im2bw(out2),im2bw(temp2)));
mem4=ridSmall(mem3,out2);

% %%
% %for 2 nuclei, pick the one that is mors circle (the other is a remannt
% %from other cells, if more than 2 nuclei just get rid of all
% memL = bwlabel(r4, 4);
% numL=max(max(memL));
% out3=out2;
% 
% for i=1:numL
%     temp=(memL==i);
%     
%     %all nuc in temp
%     tempnuc=temp.*im2bw(out2);
%     
%     %place holder - original will change
%     select_nuc=tempnuc;
%     
%     %subtract trick
%     out3=im2bw(imsubtract(im2bw(out3),im2bw(temp)));
%     
%     % get rid of small
%     tempnuc=bwareaopen(tempnuc,20);
%     bw = bwlabel (tempnuc,4);
%  bw = imfill(bw,'holes');
%  [B,L] = bwboundaries(bw,'noholes');
%  
%  if (max(max(L))==2)
% 
%     metric_a=calculate_metric(B,L);
%     index = find (metric_a==max(metric_a));
%     
%     %select nuc more liek a circle
%     select_nuc=(L==index);
%  
%     out3=im2bw(imadd(im2bw(out3),im2bw(select_nuc)));
%   end
% end



%%
%final filering step that can be ignored
% mainly look for large objects, and then, first get rifd of objects that are very weirdly shapped (circle metric<0.15)
% then keep only those that are "long" (eccen) cells.
L=bwlabel(mem4,4);
stats = regionprops(L,'Area');

% large objects
Areas=transpose(cell2mat({stats.Area}));
large_ones=find (Areas>2500);
large= ismember(L,large_ones).*L;

% circle metric
 bw = bwlabel (large,4);
 [B] = bwboundaries(bw, 4,'noholes');
metric_b=calculate_metric(B,bw);
erase=find(metric_b<0.15);
remain=find(metric_b>=0.15);
erase1=ismember(bw,erase).*bw;
remain1=ismember(bw,remain).*bw;

% keep long cells
L=bwlabel(remain1,4);
stats = regionprops(L,'Eccentricity');
eccen=transpose(cell2mat({stats.Eccentricity}));
erasex=find (eccen<0.5);
erase2=ismember(L,erasex).*L;

%add the two erases
erase1=im2bw(imadd(im2bw(erase1),im2bw(erase2)));

%sutract all to erase
mem5=im2bw(imsubtract(im2bw(mem4),im2bw(erase1)));

s=size(mem5);

%if s(1)~=2048 || s(2)~=2048 %check if images is from Cytell ~=2048
%        mem5=closesmallholes(mem5, 50); %adjust for smaller pixel size if Cytell
%else
%        mem5=closesmallholes(mem5, 20);
%end

 %fill in small holes in cells
mem5=bwlabel(mem5,4);
