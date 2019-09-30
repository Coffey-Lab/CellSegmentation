% input
% cellmask - cell mask to be reseged
% total - total membrane mask
% output
% maskout - reseged mask based on amount of membrane inside cell (9% default) 




function maskout=ParReSegCells(cellmask, total)

% eliminate noise from membrane
mask=double(cellmask);
total = bwareaopen(total,30);
keep=[];


% eliminate 4 pixels from border to calculate membrane in cell only
mask2=im2bw(mask);
mask2=imcomplement (mask2);

% imdilate the negative area
se=strel ('disk',4);
mask2=imdilate(mask2,se);
mask2=double(mask2);

%mask3 still a labeled mask by doing this
mask3=mask-65535*mask2;
%get rid of all negatives
mask3(find (mask3<0))=0;


%keep = find cells with mean membrane intensity > threshold
area=regionprops(mask3,total,'MeanIntensity','Area');
Intensities=transpose(cell2mat({area.MeanIntensity}));
Areas=transpose(cell2mat({area.Area}));
Intensities (find(Areas<=600))=0; %filter by area

% cells to reseg
keep=find(Intensities>0.09);
keep=keep';


[r c]=size(keep);
fprintf(['Cell ReSeg ' num2str((c)) ' objects; '])

% if c>1500
%     fprintf('>1500 objects to reseg, skipping position')
%     maskout=zeros(size(mask));
%     return
% end

maskout=mask;
%h = waitbar(0,'Cell ReSeg Processing');

for i = 1:c
    %waitbar(i/c, h, [num2str(keep(i)) ' ' num2str(i) '/' num2str(c) ' Cell Objects; Estimated Time Remaining: ' num2str((c-i)*8.5/60) ' mins'])
    %fprintf([i '|'])  
    %reseg the temopobject (1 object at a time)
    tempobject=selectobjects(keep(i),mask);
    lines=reseg(tempobject,total,keep(i));
    %imwrite (lines, [outputPath 'ReSeg' int2str(keep(i)) '.jpg'])
    
    %strcat(int2str(keep(i)),'.jpg'));
    maskout=maskout-lines*65535;
end
%close(h)

% return labelled mask reseged
maskout(find (maskout<0))=0;
maskout=bwlabel(maskout, 4);
fprintf('\n')
