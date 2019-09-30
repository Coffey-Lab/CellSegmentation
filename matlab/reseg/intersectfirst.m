% connect segments to edge within a range
% outputs
% remainder= remainder segments not connected
% edge7 = new edge including the segments
% inputs
% line = line segments
% mask = full mask of object

function [remainder, edge7] = intersectfirst (line,mask)

if max(line(:))==0
    remainder=zeros(size(line));
    edge7=remainder;
    return
end

line2=zeros(size(line));

remainder=bwmorph(line,'thin',inf);
%se=strel('disk', 2);
%line=imdilate (line,se);
L3=bwlabel (line);

e=edge(mask,'Sobel');

% edge boundary condition
BBox=regionprops(mask,'BoundingBox');
BBox=BBox.BoundingBox;

sCanvas=size(line);

buffer=0;
BBox(1)=round(BBox(1)-buffer);
BBox(2)=round(BBox(2)-buffer);
BBox(3)=round(BBox(1)+BBox(3)+ 2*buffer);
BBox(4)=round(BBox(2)+BBox(4)+2*buffer);

%if BBox goes off image, set to image edge
BBox(BBox<1)=1;

if(BBox(3)>sCanvas(2))
    BBox(3)=sCanvas(2);
end

if(BBox(4)>sCanvas(1))
    BBox(4)=sCanvas(1);
end

totalcanvas=zeros(sCanvas);
   
    
    totalcanvas(BBox(2):BBox(4), BBox(1))=1;
    totalcanvas(BBox(2):BBox(4), BBox(3))=1;
    totalcanvas(BBox(2),BBox(1):BBox(3))=1;
    totalcanvas(BBox(4),BBox(1):BBox(3))=1;

% make a 100 pixel band aroudn to exclude objects
% pic=zeros(size(mask));
% [br bc]=size(pic);
% pic(1:100,:)=1;
% pic((br-100):br,:)=1;
% pic(:,1:100)=1;
% pic(:,(bc-100):bc)=1;

% do one line segment at a time
for ii=1:max(max(L3))
    
    line=ismember ( L3,ii);
    input = bwmorph(line,'thin',inf);
    %   input = bwmorph(input,'spur',1);
    
    endpoints=labelendpoints(input);
    
    
    %first set of enpdoints since only one object
    points=cell2mat(endpoints(1));
    [row col]=size(points);
    
    % x y here are coordinates of edge object
    
    [x y]=find (e==1);
    
    % if close to edge add edge to e
    inmask=mask;%&pic;
    if ((max(max(inmask)))>0)
        [x2 y2]=find(totalcanvas==1);
    else
        x2=[];
        y2=[];
    end
    
    x=vertcat(x,x2);
    y=vertcat(y,y2);
    distance=[];
    smallesti=[];
    smallestd=[];
    
    %compare all endpoints to all xy on edge
    for i = 1:row
        xyvect=[x y];
        vy2=vertcat (points(i,:), xyvect);
        t_xyvect=squareform(pdist(vy2));
        distance=t_xyvect(1,2:size(x)+1);
        
        %index and distance of smallest distance between endpoint
        %and edge store in smallest
        index2 = find (distance==min(distance));
        smallesti(i)=index2(1);
        smallestd(i)=distance(index2(1));
    end
    
    %find smallestd d<8
    ep=find(smallestd<8);
    
    [rr cc]=size (ep);
    %connect all ep to edge
    if (cc>0)
        
        for k=1:cc
            newimg=zeros(size(line2));
            x1=points (ep(k),1);
            y1=points (ep(k),2);
            
            x2=x(smallesti(ep(k)));
            y2=y(smallesti(ep(k)));
            
            x1=x1(1);
            y1=y1(1);
            
            x2=x2(1);
            y2=y2(1);
            
            
            xnew=linspace (x1,x2,1000);
            ynew=linspace (y1,y2,1000);
            %index = sub2ind(size(newimg),round(ynew),round(xnew));
            index= sub2ind(size(newimg),round(xnew),round(ynew));
            
            
            newimg(index)=1;
            %newimg=transpose(newimg); %this transpose messes up non square matrices
            newimg=im2bw(newimg);
            line2=im2bw(line2);
            line2=imadd(line2,newimg);
            line2=imadd(im2bw(line2),im2bw(input));
            
            %line2 are the connected line segments to the edge
            %remainder are the remaining unconnected line segments
            remainder=imsubtract(im2bw(remainder),im2bw(line));
        end
    end
end
edge7=im2bw(imadd(im2bw(e),im2bw(line2)));
remainder =im2bw(remainder);

end