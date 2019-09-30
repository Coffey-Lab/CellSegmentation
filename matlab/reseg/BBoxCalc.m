%%Given binary image of object, returns coordinates of bounding box with
%%buffer zone
%input=binary image of object
%output=coordinates for cropped version with buffer

function BBox=BBoxCalc(tempobject)

sMask=size(tempobject);

%get bounding box
BBox=regionprops(tempobject,'BoundingBox');
    BBox=BBox.BoundingBox;

    %format bounding box
buffer=7;
BBox(1)=round(BBox(1)-buffer); %X1
BBox(2)=round(BBox(2)-buffer); %Y1
BBox(3)=round(BBox(1)+BBox(3)+ 2*buffer); %X2
BBox(4)=round(BBox(2)+BBox(4)+2*buffer); %Y2

%if BBox goes off image, set to image edge
BBox(BBox<1)=1;

if(BBox(3)>sMask(2))
    BBox(3)=sMask(2);
end

if(BBox(4)>sMask(1))
    BBox(4)=sMask(1);
end