%inputs
% mask2=Muc2 image tif
% epiMask = tub mask black and white
% MemMask = total membrane mask
% mask = nuclear mask
  
%outputs 
% k2 = segmented black and white with muc2 added

function k2 = Muc2Add (mask2, epiMask, MemMask, mask)

        % create muc2 mask dilate by 3 pixel
        mask2=adaptiveimages(mask2,50,0); 
        se=strel('disk',3);
        mask2=imdilate(mask2,se);
        sMask=size(mask2);
        
        if sum(mask2(:))> sMask(1)*sMask(2)/2
            k2=zeros(sMask(1),sMask(2));
            return
        end
        
        % add the muc2 mask to tube (no holes)
        tube2=imadd(im2bw(epiMask),im2bw(mask2));
        tx=closesmallholes(tube2,200);
        
        % make it such that it is white on the outside , add membrane 
        tube2=imcomplement (tx);
        tube3=im2bw(imadd(im2bw(tube2),im2bw(MemMask)));
        total3=uint8(tube3);
        
        %watseg with nuclei as basins
        WatCellSeg2 = watershed(imimposemin(total3,mask),4);
        
        
        
        k2=double(WatCellSeg2);
        k2=im2bw(k2);
        
        % return only those in tube mask
        k2=k2.*tx;
end