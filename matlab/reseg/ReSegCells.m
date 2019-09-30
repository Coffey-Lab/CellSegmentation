% input
% cellmask - cell mask to be reseged
% total - total membrane mask
% output
% maskout - reseged mask based on amount of membrane inside cell (10% default) 




function maskout=ReSegCells(cellmask, total)

% eliminate noise from membrane
cellmask=double(cellmask);
total = bwareaopen(total,30);
keep=[];


% eliminate 4 pixels from border to calculate membrane in cell only
mask2=im2bw(cellmask);
mask2=imcomplement (mask2);

% imdilate the negative area
se=strel ('disk',4);
mask2=imdilate(mask2,se);
mask2=double(mask2);

%mask3 still a labeled mask by doing this
mask3=cellmask-65535*mask2;
%get rid of all negatives
mask3(mask3<0)=0;

clear mask2

%keep = find cells with mean membrane intensity > threshold
area=regionprops(mask3,total,'MeanIntensity','Area');
Intensities=transpose(cell2mat({area.MeanIntensity}));
Areas=transpose(cell2mat({area.Area}));
Intensities (find(Areas<=600))=0; %filter by area

% cells to reseg
keep=find(Intensities>0.1);
keep=keep';


[r c]=size(keep);
fprintf(['Cell ReSeg ' num2str((c)) ' objects; '])

% if c>1500
%     fprintf('>1500 objects to reseg, skipping position')
%     maskout=zeros(size(mask));
%     return
% end

maskout=cellmask;
h = waitbar(0,'Cell ReSeg Processing');
sMask=size(maskout);
for i = 1:c
    waitbar(i/c, h, [num2str(keep(i)) ' ' num2str(i) '/' num2str(c) ' Cell Objects; Estimated Time Remaining: ' num2str((c-i)*2/60) ' mins'],'WindowStyle', 'modal')

    % reseg the temopobject (1 object at a time)
    tempobject=ismember(cellmask, keep(i));
    
    % mask cell mask to improve speed
    BBox=BBoxCalc(tempobject);
    subObject=tempobject(BBox(2):BBox(4),BBox(1):BBox(3));
    subTotal=total(BBox(2):BBox(4),BBox(1):BBox(3));
    
    %skip if object is too big
    [a,b]=size(subObject);
    if a*b>160000
        continue
    end	
    
    
    lines=reseg(subObject,subTotal,-1);
    
       
    linesSub=false(sMask);
    linesSub(BBox(2):BBox(4),BBox(1):BBox(3))=lines;
    
    %strcat(int2str(keep(i)),'.jpg'));
    maskout=maskout-linesSub*65535;
end
close(h)

% return labelled mask reseged
maskout(maskout<0)=0;
maskout=bwlabel(maskout, 4);
