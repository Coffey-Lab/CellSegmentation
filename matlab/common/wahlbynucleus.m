function varargout=wahlbynucleus(varargin)
% [nuclearMask,nuclearMembranes]=wahlbynucleus(nuclearImage,gaussSD,hForMaxima,hForMinima,minSizeOfNucleus,matlabOrDipimage,weakBorderThr1,weakBorderThr2,isInteractive)
% OR
% wahlbynucleus(nuclearImage,gaussSD,hForMaxima,hForMinima,minSizeOfNucleus) with no output parameters.
% nuclearImage - a Matlab matrix or a DipImage to be segmented
% gaussSD - SD of the Gaussian filter
% hForMaxima - height of the extended h-maxima transform
% hForMinima - height of the extended h-minima transform
% minSizeOfNucleus - size of the nucleus. After extended h-minima transform regional minima smaller than this will be removed.
% matlabOrDipimage - 1: Matlab version of seeded-watershed, 2: DipImage-version of seeded=watershed
% weakBorderThr1 - borders with strengths smaller than this will be removed after the 1st watershed transform
% weakBorderThr2 - borders with strengths smaller than this will be removed after the 2nd watershed transform (on the distance transformed image)
% isInteractive - if 1, borders can be manually removed at the end
%
% Parameters gaussSD, hForMaxima, hForMinima and minSizeOfNucleus can be
% optimized by calling the function with 5 input arguments (this is much
% faster than the full segmentation).
%
% Reasonably nice segmentation of the wahlby_testimage.ics can be achieved
% with the following parameters: [nmask,nmembrane]=wahlbynucleus(a,1,5,3,100,1,25,30,1);
%
% The program implements the algorithm described in the following paper:
% Combining intensity, edge and shape information for 2D and 3D segmentation of cell nuclei in tissue sections.
% W?hlby C, Sintorn IM, Erlandsson F, Borgefors G, Bengtsson E.
% J Microsc. 215: 67-76 (2004).
% https://www.ncbi.nlm.nih.gov/pubmed/15230877
% http://dx.doi.org/10.1111/j.0022-2720.2004.01338.x
%
% Written by Peter Nagy, email: peter.v.nagy@gmail.com, http://peternagy.webs.com
% July 10, 2017
switch nargin
    case 5
        nuclearImage=varargin{1};
        gaussSD=varargin{2};
        hForMaxima=varargin{3};
        hForMinima=varargin{4};
        minSizeOfNucleus=varargin{5};
        plotRows=2;
        plotCols=3;
    case 9
        nuclearImage=varargin{1};
        gaussSD=varargin{2};
        hForMaxima=varargin{3};
        hForMinima=varargin{4};
        minSizeOfNucleus=varargin{5};
        matlabOrDipimage=varargin{6};
        weakBorderThr1=varargin{7};
        weakBorderThr2=varargin{8};
        isInteractive=varargin{9};
        plotRows=3;
        plotCols=4;
    otherwise
        error('Wrong number of input arguments, Number of input arguments must be either 5 or 9.');
end
typeOfInput=getfield(whos('nuclearImage'),'class');
if ~strcmp(typeOfInput,'double')
    nuclearImage=double(nuclearImage);
end
% nuclearImage is double
% Gauss filtering
verInfo=version;
if str2double(verInfo(1:find(verInfo=='.',1)+1))>=8.5
    nuclearImageGF=imgaussfilt(nuclearImage,gaussSD);
else
    gf=fspecial('gaussian',5*gaussSD,gaussSD);
    nuclearImageGF=imfilter(nuclearImage,gf,'conv','same','replicate');
end
figure;
ah(1)=subplot(plotRows,plotCols,1);
basicColormap=[255,0,0;0,255,0;0,0,255;255,255,0;0,255,255;255,0,255;255,84,0;170,55,0;0,170,255;84,0,255;255,0,170;255,170,0;0,255,127;0,84,255;170,0,255;255,0,84]/255;
imshow(nuclearImageGF,[min(nuclearImageGF(:)) max(nuclearImageGF(:))]);
title('Gauss filtered image');
% gradient magnitude image
gradMag=abs(imfilter(nuclearImageGF,fspecial('sobel')))+abs(imfilter(nuclearImageGF,fspecial('sobel')'));
ah(2)=subplot(plotRows,plotCols,2);
imshow(gradMag,[prctile(gradMag(:),1) prctile(gradMag(:),99)]);
title('Gradient magnitude image');
% extended h-maxima transform, nuclearImage is converted to double
extHMax=imextendedmax(nuclearImageGF,hForMaxima);
ah(3)=subplot(plotRows,plotCols,3);
imshow(extHMax,[0 1]);
title('Extended h-maxima');
% extemded h-minima of the gradient magnitude
extHMin=imextendedmin(gradMag,hForMinima);
ah(4)=subplot(plotRows,plotCols,4);
imshow(extHMin,[0 1]);
title('Extended h-minima');
% remove small objects from extHMin
extHMin2=bwareaopen(extHMin,minSizeOfNucleus);
ah(5)=subplot(plotRows,plotCols,5);
imshow(extHMin2,[0 1]);
title('Extended h-minima, filtered');
if nargin==5
    return;
end
% if seed pixels overlap in the bgseed and nuclearseed images, assign them to the nuclearseed
extHMin2(extHMax==1)=0;
% seeded watershed, changing the current folder is required not to use the dipimage function 'watershed'
switch matlabOrDipimage
    case 1 % Matlab
        currDir=pwd;
        cd(fullfile(matlabroot,'toolbox','images','images'));
        gradMagMod=imimposemin(gradMag,extHMin2+extHMax);
        watershedLabeledImage=watershed(gradMagMod);
        cd(currDir);
        % watershedMembraneImage=watershedLabeledImage==0;
    case 2 % DipImage
        watershedMembraneImage=waterseed(dip_image(extHMin2+extHMax)>0,dip_image(gradMag));
        watershedLabeledImage=bwlabel(double(~watershedMembraneImage),4);
        % watershedMembraneImage=logical(watershedMembraneImage);
end
ah(6)=subplot(plotRows,plotCols,6);
rgb=displayImageInColor(watershedLabeledImage,basicColormap);
imshow(rgb);
title('Watershed');
[membraneParts,allMeanBorderStrengths]=removeWeakBorders(watershedLabeledImage,gradMag,weakBorderThr1);
watershedMembraneImageNoWeakBorder=sum(membraneParts,3)>0;
watershedLabeledImageNoWeakBorder=bwlabel(~watershedMembraneImageNoWeakBorder,4);
ah(8)=subplot(plotRows,plotCols,8);
rgb=displayImageInColor(watershedLabeledImageNoWeakBorder,basicColormap);
imshow(rgb);
title('Watershed, no weak');
xmin=prctile(allMeanBorderStrengths,1);
xmax=prctile(allMeanBorderStrengths,99);
nbin=log2(numel(allMeanBorderStrengths));
xbins=xmin:(xmax-xmin)/(nbin-1):xmax;
histOfBorderStrengths=histcounts(allMeanBorderStrengths,xbins);
ah(7)=subplot(plotRows,plotCols,7);
bar(xbins(1:end-1),histOfBorderStrengths,'parent',ah(7));
title('Border strengths in WS');
% distance transform
distTransform=bwdist(~watershedMembraneImageNoWeakBorder);
ah(9)=subplot(plotRows,plotCols,9);
imshow(distTransform,[min(distTransform(:)) max(distTransform(:))]);
title('Distance transform');
% watershed on inverse of the distance transform
cd(fullfile(matlabroot,'toolbox','images','images'));
watershedLabeledImage2=watershed(distTransform);
cd(currDir);
ah(10)=subplot(plotRows,plotCols,10);
rgb=displayImageInColor(watershedLabeledImage2,basicColormap);
imshow(rgb);
title('Watershed of DT');
% remove weak borders from the watershed of DT
[membraneParts2,allMeanBorderStrengths2]=removeWeakBorders(watershedLabeledImage2,gradMag,weakBorderThr2);
watershedMembraneImageNoWeakBorder2=sum(membraneParts2,3)>0;
watershedLabeledImageNoWeakBorder2=bwlabel(~watershedMembraneImageNoWeakBorder2,4);
ah(12)=subplot(plotRows,plotCols,12);
rgb=displayImageInColor(watershedLabeledImageNoWeakBorder2,basicColormap);
imshow(rgb);
title('Watershed of DT, no weak');
xmin=prctile(allMeanBorderStrengths2,1);
xmax=prctile(allMeanBorderStrengths2,99);
nbin=log2(numel(allMeanBorderStrengths2));
xbins=xmin:(xmax-xmin)/(nbin-1):xmax;
histOfBorderStrengths2=histcounts(allMeanBorderStrengths2,xbins);
ah(11)=subplot(plotRows,plotCols,11);
bar(xbins(1:end-1),histOfBorderStrengths2,'parent',ah(11));
title('Border strengths in WS of DT');
% remove ticks from all axes, if not done at the end, it doesn't work
set(ah([1:6,8:10,12]),'xtick',[]);
set(ah([1:6,8:10,12]),'ytick',[]);
% if interactive, merge as you wish, then return the results
if isInteractive==1
    membranes=sum(membraneParts2,3)>0;
    origLabeledImage=bwlabel(~membranes,4);
    [neighborhoodMatrix,membraneParts3]=determineNeighborhood(origLabeledImage,gradMag);
    membraneParts4=interactiveMerge(membraneParts3,basicColormap,neighborhoodMatrix,origLabeledImage);
    watershedMembraneImageNoWeakBorder3=sum(membraneParts4,3)>0;
    watershedLabeledImageNoWeakBorder3=bwlabel(~watershedMembraneImageNoWeakBorder3,4);
    varargout{1}=watershedLabeledImageNoWeakBorder3; % nuclearMask
    varargout{2}=varargout{1}==0; % nuclearMembranes
else
    varargout{1}=watershedLabeledImageNoWeakBorder2; % nuclearMask
    varargout{2}=varargout{1}==0; % nuclearMembranes
end
if strcmp(typeOfInput,'dip_image')
    varargout{1}=dip_image(varargout{1});
    varargout{2}=dip_image(varargout{2});
end
function membranePartsNew=interactiveMerge(membraneParts,basicColormap,neighborhoodMatrix,origLabeledImage)
scrsz=get(0,'ScreenSize');
figsz=[550 550];
fh=figure('windowstyle','normal','toolbar','none','menubar','none','units','pixels','position',[scrsz(3)/2-figsz(1)/2 scrsz(4)/2-figsz(2)/2 figsz],'color',[0.94 0.94 0.94],'numbertitle','off','name','Merge objects');
dyPerDx=size(membraneParts,1)/size(membraneParts,2);
sizeX=450;
if dyPerDx<1
    sizeY=450*dyPerDx;
else
    sizeY=450/dyPerDx;
end
gd.nameCore='Merge objects';
gd.axisHandle=axes('parent',fh,'units','pixels','position',[86 66 sizeX sizeY]);
gd.labeledImage=origLabeledImage;
rgb=displayImageInColor(gd.labeledImage,basicColormap);
gd.imageHandle=imshow(rgb,'parent',gd.axisHandle);
gd.clickStatus=0; % 0 - nothing clicked, 1 - CTRL key pressed, 2 - left-click
gd.firstLeftClickPos=nan;
gd.boxHandle=nan;
gd.membraneParts=membraneParts;
gd.numberOfClicks=0;
gd.clickedLabels=zeros(1000,1);
gd.neighborhoodMatrix=neighborhoodMatrix;
gd.historyCounter=1;
gd.previousSegmentations=cell(1000,3);
gd.previousSegmentations{1,1}=gd.labeledImage;
gd.previousSegmentations{1,2}=gd.membraneParts;
gd.previousSegmentations{1,3}=gd.neighborhoodMatrix;
set(fh,'windowbuttonmotionfcn',{@mouseMove_callback,basicColormap,'move'});
set(fh,'windowbuttonupfcn',{@mouseMove_callback,basicColormap,'up'});
set(fh,'windowbuttondownfcn',{@mouseClick_callback,basicColormap});
set(fh,'keyreleasefcn',{@buttonRelease_callback});
set(fh,'keypressfcn',{@buttonPress_callback});
uicontrol('parent',fh,'style','pushbutton','units','pixels','position',[10 10 70 40],'fontsize',10,'string','Finish','callback',@finish_callback);
gd.backButtonHandle=uicontrol('parent',fh,'style','pushbutton','units','pixels','position',[110 10 70 40],'fontsize',10,'string','Back','callback',{@back_callback,basicColormap},'enable','off');
uicontrol('parent',fh,'style','text','units','pixels','position',[210 10 330 40],'fontsize',10,'string','CTRL-click on neighboring areas to merge objects. Click and drag to select objects to merge.');
guidata(fh,gd);
set(fh,'CloseRequestFcn','');
set(gd.axisHandle,'xtick',[]);
set(gd.axisHandle,'ytick',[]);
uiwait(fh);
gd=guidata(fh);
delete(fh);
membranePartsNew=gd.membraneParts;
function mouseMove_callback(src,evt,basicColormap,typeOfEvent)
currentPoint=get(gca,'currentpoint');
currentPoint=currentPoint(1,1:2);
gd=guidata(src);
if round(currentPoint(2))>0 && round(currentPoint(2))<=size(gd.labeledImage,1) && round(currentPoint(1))>0 && round(currentPoint(1))<=size(gd.labeledImage,2)
    ind=gd.labeledImage(round(currentPoint(2)),round(currentPoint(1)));
    extraString=num2str(ind);
else
    extraString='off-scale';
end
set(src,'name',[gd.nameCore,' (',extraString,')']);
if gd.clickStatus==2
    errorState=0;
    switch sign(gd.firstLeftClickPos(1)-currentPoint(1))
        case 1
            xPos=currentPoint(1);
            width=gd.firstLeftClickPos(1)-currentPoint(1);
        case 0
            errorState=1;
        case -1
            xPos=gd.firstLeftClickPos(1);
            width=currentPoint(1)-gd.firstLeftClickPos(1);
    end
    switch sign(gd.firstLeftClickPos(2)-currentPoint(2))
        case 1
            yPos=currentPoint(2);
            height=gd.firstLeftClickPos(2)-currentPoint(2);
        case 0
            errorState=1;
        case -1
            yPos=gd.firstLeftClickPos(2);
            height=currentPoint(2)-gd.firstLeftClickPos(2);
    end
    if ishandle(gd.boxHandle)
        delete(gd.boxHandle);
        gd.boxHandle=nan;
    end
    if errorState==0
        gd.boxHandle=rectangle('position',[xPos yPos width height],'edgecolor','white','linestyle','--');
    end
    switch typeOfEvent
        case 'move'
            guidata(src,gd);
        case 'up'
            gd.clickStatus=0;
            guidata(src,gd); % earlier than the end of the function to prevent drawing a rectangle after responding to the questdlg
            [xq,yq]=meshgrid(1:size(gd.labeledImage,2),1:size(gd.labeledImage,1));
            inIndices=inpolygon(xq(:),yq(:),[xPos xPos+width xPos+width xPos],[yPos yPos yPos+height yPos+height]);
            gd.clickedLabels=setdiff(gd.labeledImage(inIndices),[0 1]);
            if numel(gd.clickedLabels)>1
                response=questdlg('Merge objects in the rectangle?','Merge?','Yes','No','Yes');
                if strcmp(response,'Yes')
                    gd.numberOfClicks=2;
                    while gd.numberOfClicks<=numel(gd.clickedLabels)
                        gd=mergeSelectedObjects(gd,basicColormap,gd.numberOfClicks==numel(gd.clickedLabels));
                        gd.numberOfClicks=gd.numberOfClicks+1;
                    end
                    gd.numberOfClicks=0;
                end
            end
            delete(gd.boxHandle);
            gd.boxHandle=nan;
            gd.clickedLabels=zeros(1000,1);
            guidata(src,gd);
    end
end
function back_callback(src,evt,basicColormap)
gd=guidata(src);
gd.historyCounter=gd.historyCounter-1;
if gd.historyCounter==1
    set(src,'enable','off');
end
gd.labeledImage=gd.previousSegmentations{gd.historyCounter,1};
gd.membraneParts=gd.previousSegmentations{gd.historyCounter,2};
gd.neighborhoodMatrix=gd.previousSegmentations{gd.historyCounter,3};
delete(gd.imageHandle);
membranes=sum(gd.membraneParts,3)>0;
labeledImage=bwlabel(~membranes,4);
rgb=displayImageInColor(labeledImage,basicColormap);
gd.imageHandle=imshow(rgb,'parent',gd.axisHandle);
set(gd.axisHandle,'xtick',[]);
set(gd.axisHandle,'ytick',[]);
guidata(src,gd);
function finish_callback(src,evt)
uiresume;
function mouseClick_callback(src,evt,basicColormap)
switch get(src,'selectiontype')
    case 'alt' % CTRL-click
        gd=guidata(src);
        currentPoint=get(gca,'currentpoint');
        currentPoint=currentPoint(1,1:2);
        xlim=get(gca,'xlim');
        ylim=get(gca,'ylim');
        if gd.clickStatus==1 && currentPoint(1)>=xlim(1) && currentPoint(1)<=xlim(2) && currentPoint(2)>=ylim(1) && currentPoint(2)<=ylim(2)
            ind=gd.labeledImage(round(currentPoint(2)),round(currentPoint(1)));
            if ind>0
                gd.numberOfClicks=gd.numberOfClicks+1;
                gd.clickedLabels(gd.numberOfClicks)=ind;
                if gd.numberOfClicks>1
                    gd=mergeSelectedObjects(gd,basicColormap,true);
                end
            end
            guidata(src,gd);
        end
    case 'normal' % left-click
        gd=guidata(src);
        gd.clickStatus=2;
        currentPoint=get(gca,'currentpoint');
        gd.firstLeftClickPos=currentPoint(1,1:2);
        guidata(src,gd);
end
function gdloc=mergeSelectedObjects(gdloc,basicColormap,writeHistory)
s1NbhM=size(gdloc.neighborhoodMatrix,1);
ind=gdloc.clickedLabels(gdloc.numberOfClicks);
for i=1:gdloc.numberOfClicks-1
    if ind>gdloc.clickedLabels(i)
        r=ind;
        c=gdloc.clickedLabels(i);
    else
        c=ind;
        r=gdloc.clickedLabels(i);
    end
    if gdloc.neighborhoodMatrix(r,c,1)==1
        gdloc.labeledImage(gdloc.labeledImage==r)=c;
        gdloc.neighborhoodMatrix(r,c,1)=0;
        % add row r to row c
        gdloc.neighborhoodMatrix(c,:,1)=double((gdloc.neighborhoodMatrix(c,:,1)+gdloc.neighborhoodMatrix(r,:,1))>0);
        % set all the values in row r to 0
        gdloc.neighborhoodMatrix(r,:,1)=0;
        % add column r to column c
        gdloc.neighborhoodMatrix(:,c,1)=double((gdloc.neighborhoodMatrix(:,c,1)+gdloc.neighborhoodMatrix(:,r,1))>0);
        % set all the values in column r to 0
        gdloc.neighborhoodMatrix(:,r,1)=0;
        % add all values from the upper triangular part of the matrix to the lower triangular part
        gdloc.neighborhoodMatrix(:,:,1)=double((gdloc.neighborhoodMatrix(:,:,1)+triu(gdloc.neighborhoodMatrix(:,:,1))')>0);
        gdloc.neighborhoodMatrix(triu(ones(size(gdloc.neighborhoodMatrix,1),size(gdloc.neighborhoodMatrix,2)))==1)=0; % layer 1
        gdloc.membraneParts(gdloc.membraneParts==(c-1)*s1NbhM+r)=0;
        for oldC=1:r-1
            if oldC~=c
                newR=c;
                newC=oldC;
                if newC>newR
                    temp=newC;
                    newC=newR;
                    newR=temp;
                end
                gdloc.membraneParts(gdloc.membraneParts==(oldC-1)*s1NbhM+r)=(newC-1)*s1NbhM+newR;
            end            
        end
        for oldR=r+1:s1NbhM
            newC=c;
            newR=oldR;
            if newC>newR
                temp=newC;
                newC=newR;
                newR=temp;
            end
            gdloc.membraneParts(gdloc.membraneParts==(r-1)*s1NbhM+oldR)=(newC-1)*s1NbhM+newR;
        end
        delete(gdloc.imageHandle);
        membranes=sum(gdloc.membraneParts,3)>0;
        labeledImage=bwlabel(~membranes,4);
        rgb=displayImageInColor(labeledImage,basicColormap);
        gdloc.imageHandle=imshow(rgb,'parent',gdloc.axisHandle);
        set(gdloc.axisHandle,'xtick',[]);
        set(gdloc.axisHandle,'ytick',[]);
        if writeHistory
            gdloc.historyCounter=gdloc.historyCounter+1;
            set(gdloc.backButtonHandle,'enable','on');
            gdloc.previousSegmentations{gdloc.historyCounter,1}=gdloc.labeledImage;
            gdloc.previousSegmentations{gdloc.historyCounter,2}=gdloc.membraneParts;
            gdloc.previousSegmentations{gdloc.historyCounter,3}=gdloc.neighborhoodMatrix;
        end
    end
end
function buttonPress_callback(src,evt)
if strcmp(evt.Key,'control')
    gd=guidata(src);
    gd.clickStatus=1;
    guidata(src,gd);
end
function buttonRelease_callback(src,evt)
if strcmp(evt.Key,'control')
    gd=guidata(src);
    gd.clickStatus=0;
    gd.clickedLabels=zeros(1000,1);
    gd.numberOfClicks=0;
    guidata(src,gd);
end
function rgb=displayImageInColor(imageData,basicColormap)
numOfLevels=max(imageData(:))-min(imageData(:))+1;
colorMap=zeros(numOfLevels,3);
colorMap2=repmat(basicColormap,[ceil(double(numOfLevels)/size(basicColormap,1)),1]);
colorMap(2:end,:)=colorMap2(1:size(colorMap,1)-1,:);
rgb=label2rgb(imageData,colorMap(1:numOfLevels,:));
function [membraneParts,meanBorderStrengthsExport,neighborhoodMatrix]=removeWeakBorders(wsLabeled,grad,thr)
[neighborhoodMatrix,membraneParts]=determineNeighborhood(wsLabeled,grad);
meanBorderStrengths=neighborhoodMatrix(:,:,3)./neighborhoodMatrix(:,:,2);
meanBorderStrengthsExport=meanBorderStrengths(~isnan(meanBorderStrengths));
s1NbhM=size(neighborhoodMatrix,1);
if thr<=0, return; end
foundAnother=true;
while foundAnother
    toBeRemoved=neighborhoodMatrix(:,:,1)==1 & meanBorderStrengths<thr;
    if sum(toBeRemoved(:))==0
        foundAnother=false;
    else
        ind=find(meanBorderStrengths(toBeRemoved)==min(meanBorderStrengths(toBeRemoved)),1);
        [rs,cs]=find(toBeRemoved);
        r=rs(ind);
        c=cs(ind);
        neighborhoodMatrix(r,c,1)=0;
        % remove those membrane parts which correspond to the weak border found
        membraneParts(membraneParts==(c-1)*s1NbhM+r)=0;
        % change the border indices in mambraneParts
        for oldC=1:r-1
            if oldC~=c
                newR=c;
                newC=oldC;
                if newC>newR
                    temp=newC;
                    newC=newR;
                    newR=temp;
                end
                membraneParts(membraneParts==(oldC-1)*s1NbhM+r)=(newC-1)*s1NbhM+newR;
            end            
        end
        for oldR=r+1:s1NbhM
            newC=c;
            newR=oldR;
            if newC>newR
                temp=newC;
                newC=newR;
                newR=temp;
            end
            membraneParts(membraneParts==(r-1)*s1NbhM+oldR)=(newC-1)*s1NbhM+newR;
        end
        % update the neighborhood matrix: add the length and sum of the deleted border to the remaining borders
        % set the values of the (r,c) border to zero
        neighborhoodMatrix(r,c,1:3)=0;
        % add row r to row c
        neighborhoodMatrix(c,:,1)=double((neighborhoodMatrix(c,:,1)+neighborhoodMatrix(r,:,1))>0);
        neighborhoodMatrix(c,:,2)=neighborhoodMatrix(c,:,2)+neighborhoodMatrix(r,:,2);
        neighborhoodMatrix(c,:,3)=neighborhoodMatrix(c,:,3)+neighborhoodMatrix(r,:,3);
        % set all the values in row r to 0
        neighborhoodMatrix(r,:,1:3)=0;
        % add column r to column c
        neighborhoodMatrix(:,c,1)=double((neighborhoodMatrix(:,c,1)+neighborhoodMatrix(:,r,1))>0);
        neighborhoodMatrix(:,c,2)=neighborhoodMatrix(:,c,2)+neighborhoodMatrix(:,r,2);
        neighborhoodMatrix(:,c,3)=neighborhoodMatrix(:,c,3)+neighborhoodMatrix(:,r,3);
        % set all the values in column r to 0
        neighborhoodMatrix(:,r,1:3)=0;
        % add all values from the upper triangular part of the matrix to the lower triangular part
        neighborhoodMatrix(:,:,1)=double((neighborhoodMatrix(:,:,1)+triu(neighborhoodMatrix(:,:,1))')>0);
        neighborhoodMatrix(:,:,2)=neighborhoodMatrix(:,:,2)+triu(neighborhoodMatrix(:,:,2))';
        neighborhoodMatrix(:,:,3)=neighborhoodMatrix(:,:,3)+triu(neighborhoodMatrix(:,:,3))';
        ind2d=find(triu(ones(size(neighborhoodMatrix,1),size(neighborhoodMatrix,2))));
        neighborhoodMatrix(ind2d)=0; % layer 1
        neighborhoodMatrix(ind2d+size(neighborhoodMatrix,1)*size(neighborhoodMatrix,2))=0; % layer 2
        neighborhoodMatrix(ind2d+2*size(neighborhoodMatrix,1)*size(neighborhoodMatrix,2))=0; % layer 3
    end
    meanBorderStrengths=neighborhoodMatrix(:,:,3)./neighborhoodMatrix(:,:,2);
end
function [neighborhoodMatrix,membraneParts]=determineNeighborhood(wsLabeled,grad)
membraneParts=zeros(size(wsLabeled,1),size(wsLabeled,2),6); % Size of 3rd dimension is 6 because max 4 different regions can be present around a membrane pixel, and nCr(4,2)=6.
membraneParts2Dsize=size(wsLabeled,1)*size(wsLabeled,2);
membranePartsRowNum=size(wsLabeled,1);
membraneCounter=zeros(size(wsLabeled));
neighborhoodMatrix=zeros(max(wsLabeled(:)),max(wsLabeled(:)),3);
% 3rd dimension
% position 1 - 0 = no such border
%              1 = there is such a border
%              2 = border deleted
% position 2 - length of border
% position 3 - sum of border pixel values
% At the beginning all membrane pixels are set to 1.
% [neighborhoodCellArray,r,c]=generateNeighborhoodMatrix(wsLabeled); % v1
% To each position in membraneParts assign a membrane ID. If a membrane
% pixel separates only two regions, assign a single membrane ID (first
% layer of the 3D membraneParts array). If three different regions are
% found around the membrane pixel, assign the membrane pixel to 3 different
% membranes (1-2, 1-3, 2-3), i.e. three different membrane IDs in 3
% layers of the 3D mambraneParts array, etc.
squareStrEl=strel('square',3); % v2
for rowInNeighborhoodMatrix=2:max(wsLabeled(:))
    for colInNeighborhoodMatrix=1:rowInNeighborhoodMatrix-1
        %ij2Ind=cellfun(@(x) ismember(rowInNeighborhoodMatrix,x) & ismember(colInNeighborhoodMatrix,x),neighborhoodCellArray); % v1
        membranePixelWithRCNeighbors=imdilate(wsLabeled==rowInNeighborhoodMatrix,squareStrEl) & imdilate(wsLabeled==colInNeighborhoodMatrix,squareStrEl) & wsLabeled==0; % v2
        sumMask=sum(membranePixelWithRCNeighbors(:)); % v2
        if sumMask>0 % v2
            neighborhoodMatrix(rowInNeighborhoodMatrix,colInNeighborhoodMatrix,1)=1; % v2
            neighborhoodMatrix(rowInNeighborhoodMatrix,colInNeighborhoodMatrix,2)=sumMask; % v2
            neighborhoodMatrix(rowInNeighborhoodMatrix,colInNeighborhoodMatrix,3)=sum(membranePixelWithRCNeighbors(:).*grad(:)); % v2
            [r,c]=find(membranePixelWithRCNeighbors); % v2
            indicesToModify=(c-1)*membranePartsRowNum+r; % v2
            membraneParts(indicesToModify+membraneParts2Dsize*membraneCounter((c-1)*membranePartsRowNum+r))=double(rowInNeighborhoodMatrix)+(double(colInNeighborhoodMatrix)-1)*size(neighborhoodMatrix,1); % this is the membraneID % v2
            % Fucking Matlab cannot calculate membraneID if
            % colInNeighborhoodMatrix and rowInNeighborhoodMatrix aren't
            % converted to double. If they aren't converted to double, the
            % max value of the membraneID is 255.
            membraneCounter(indicesToModify)=membraneCounter(indicesToModify)+1; % v2
        end % v2
%        if sum(ij2Ind)>0 % v1
%            neighborhoodMatrix(rowInNeighborhoodMatrix,colInNeighborhoodMatrix,1)=1; % v1
%            neighborhoodMatrix(rowInNeighborhoodMatrix,colInNeighborhoodMatrix,2)=sum(ij2Ind); % v1
%            neighborhoodMatrix(rowInNeighborhoodMatrix,colInNeighborhoodMatrix,3)=sum(grad((c(ij2Ind)-1)*membranePartsRowNum+r(ij2Ind))); % v1
%            membraneParts((c(ij2Ind)-1)*membranePartsRowNum+r(ij2Ind)+membraneParts2Dsize*membraneCounter((c(ij2Ind)-1)*membranePartsRowNum+r(ij2Ind)))=...
%                rowInNeighborhoodMatrix+(colInNeighborhoodMatrix-1)*size(neighborhoodMatrix,1); % this is the membraneID % v1
%            membraneCounter((c(ij2Ind)-1)*membranePartsRowNum+r(ij2Ind))=membraneCounter((c(ij2Ind)-1)*membranePartsRowNum+r(ij2Ind))+1; % v1
%        end
    end
end
function [neighborhoodCellArray,r,c]=generateNeighborhoodMatrix(wsLabeled)
% Not used in the current version because instead of dealing with nuclear membrane
% pixels, labeled areas (nuclei) are used for the new and faster method.
% The new method is labeled by "v2" in function determineNeighborhood,
% whereas the old one is labeled by "v1".
% neighborhoodCellArray contains the unique neightbors of all membrane
% pixels (wsLabeled==0). The position of the corresponding membrane pixel
% is in r and c.
[r,c]=find(wsLabeled==0);
row1=bsxfun(@plus,r,[-1 -1 -1 0 0 1 1 1]);
col1=bsxfun(@plus,c,[-1 0 1 -1 1 -1 0 1]);
valid_pos=row1>0 & row1<=size(wsLabeled,1) & col1>0 & col1<=size(wsLabeled,2);
ind1=(valid_pos.*col1-1).*size(wsLabeled,1)+valid_pos.*row1;
neighborMatrix=nan(size(ind1));
neighborMatrix(ind1>0)=wsLabeled(ind1(ind1>0));
neighborMatrix(neighborMatrix==0)=nan;
neighborMatrix=sort(neighborMatrix,2);
neighborhoodCellArray=arrayfun(@(x) unique(neighborMatrix(x,~isnan(neighborMatrix(x,:)))),1:size(neighborMatrix,1),'uniformoutput',0);