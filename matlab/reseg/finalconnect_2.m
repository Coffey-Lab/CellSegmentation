% extend from spurs without intersecting 
% input
% object = object of lines/membranes
% backdrop = solid cell object
% hlen = length of extension
% output
% final = extended 


function final = finalconnect_2 (object,backdrop, hlen);



object = bwmorph (object, 'thin', Inf);
ep = bwmorph (object, 'endpoints');

% get rid of all endpoints close to edge
    totalcanvas=zeros(size(backdrop));
    [br bc]=size(totalcanvas);
    totalcanvas(1:3,:)=1;
    totalcanvas((br-2:br),:)=1;
    totalcanvas(:,1:3)=1;
    totalcanvas(:,(bc-3:bc))=1;

ep=im2bw(imsubtract (im2bw(ep),im2bw(totalcanvas)));    

% get rid of area around branch points to make non-branhcing segments
new2=im2bw(object);
new21 = bwmorph(new2,'skel',inf);
bp=bwmorph(new21,'branchpoints');
bp=imdilate(bp, strel('disk',1));

new2(find(bp==1))=0;

%e=edge (backdrop,'canny');
e=bwperim(backdrop);
ed=imdilate(e, strel('disk',4));
new2=imsubtract(im2bw(new2),im2bw(ed));
new2=im2bw(new2);
interior=new2;

% label the new non-branching line segments
L=bwlabel(new2);
number=max(max(L));
temparray=[];
endpointarray=[];
b=1;

% select only segments with overlap of endpoints and more than single point
for i=1:number
    %temp=im2bw(selectobjects(i,L));
    temp=ismember(L,i);
    temp= bwmorph (temp, 'thin', Inf);
    remove = bwmorph (temp, 'spur', 5);
    temp=imsubtract (temp,remove);
        
    
    k = im2bw(ep) & temp;
    if ((max(max(k)) >0) && (sum(sum(temp)) >1))
         
        
        temparray{b}=temp;
        endpointarray{b}=k;
        b=b+1;
    end
end
[rol col]=size(temparray);
storeimage=zeros(size(new2));

%each line segment
for j=1:col
    test=temparray{j};
    etest=endpointarray{j};
    test = bwmorph (test, 'thin', Inf);
   
    % make a line segment from endpoints of the line
    len=1000;
    [r c]=size(test);
    new3 = bwmorph(test,'thin',inf);
    endPoints = bwmorph(new3, 'endpoints');
    [yy xx] = find(endPoints==1);
    distmat=[xx yy];
    distancematrix=squareform(pdist(distmat));
    [one two]=find (distancematrix==max(max(distancematrix)));
    i1=one(1);i2=two(1);
    new3=zeros(r,c);
    ylin=linspace (yy(i1),yy(i2),len);
    xlin=linspace (xx(i1),xx(i2),len);
    index = sub2ind(size(new3),round(ylin),round(xlin));
    new3(index)=1;
    
    % find the slope parameters from line segment
    L = bwlabel(new3);
    thinner=bwmorph (new3,'thin',Inf);
    endPoints2 = bwmorph(thinner, 'endpoints');
    s=regionprops(L,'Orientation');
    O=mean([s.Orientation]);
    [y x]=find(new3==1);
    
    cosOrient = cosd(O);
    sinOrient = sind(O);
    %get slope off the line
    [a b]=size (y);
    
    slope=(y(a)-y(1))/(x(a)-x(1));
        
    largey= find (y==max(y));
    smally= find (y==min(y));
    largex= find (x==max(x));
    smallx= find (x==min(x));
    
    largey=largey(1);smally=smally(1);
    largex=largex(1);smallx=smallx(1);
    
    % 3 conditions to extend line based on slope
    if slope==Inf
        
        xt=[x(1) x(1)];
        yt=[y(largey)+hlen y(smally)-hlen];
        
        
        largey= find (yt==max(yt));
        smally= find (yt==min(yt));
        
        
        if yt(largey)>r
            yt(largey)=r;
        end
        
        if yt(smally)<1
            yt(smally)=1;
        end
        
        
        
    elseif slope >= 0
        %if the slope is positive execute the codes below
        
        xcoords = x(largex)+ hlen * [0 cosOrient];
        ycoords = y(largey)- hlen * [0 sinOrient];
        
        xcoords2= x(smallx)- hlen * [0 cosOrient];
        ycoords2 = y(smally)+ hlen * [0 sinOrient];
        
        
        yt=[ycoords(2) ycoords2(2)];
        xt=[xcoords(2) xcoords2(2)];
        
        largey= find (yt==max(yt));
        smally= find (yt==min(yt));
        largex= find (xt==max(xt));
        smallx= find (xt==min(xt));
                
        
    elseif slope <0
        
        
        xcoords = x(largex) + hlen * [0 cosOrient];
        ycoords = y(smally) - hlen * [0 sinOrient];
        
        xcoords2 = x(smallx) - hlen * [0 cosOrient];
        ycoords2 = y(largey) + hlen * [0 sinOrient];
        
        yt=[ycoords(2) ycoords2(2)];
        xt=[xcoords(2) xcoords2(2)];
        
        largey= find (yt==max(yt));
        smally= find (yt==min(yt));
        largex= find (xt==max(xt));
        smallx= find (xt==min(xt));
             
        
    end
    
    ynew=linspace (yt(1),yt(2),len);
    xnew=linspace (xt(1),xt(2),len);
    
    % eliminate all xnew ynew outside of frame
    xnew=round(xnew);
    ynew=round(ynew);
    [ccc rrr]=size(new2);
    
    greatx=find(xnew>0);
    
    xnew=xnew(greatx);
    ynew=ynew(greatx);
    
    greatx=find(xnew<rrr);
    
    xnew=xnew(greatx);
    ynew=ynew(greatx);
    
    greatx=find (ynew>0);
    
    xnew=xnew(greatx);
    ynew=ynew(greatx);
    
    greatx=find (ynew<ccc);
    xnew=xnew(greatx);
    ynew=ynew(greatx);
    
    newimg=zeros(size(new2));
    index = sub2ind(size(new2),round(ynew),round(xnew));
    newimg(index)=1;
    % this is extended line from both sides    
    
    %connect point closest to the endpoint
    newimg=bwmorph (newimg, 'thin', Inf);
    ep2=bwmorph (newimg, 'endpoints');
    epx=ep2;
    ep2=im2bw(imsubtract (im2bw(ep2),im2bw(totalcanvas))); 
    [x y]=find(etest==1);
    
    % endpoint of line maybe on edge
    ind=find(ep2==1);
    if (isempty(ind))
        ep2=epx;
    end
    
    [x1 y1]=find(ep2==1);
    
    
    % connect endpoints closest to real endpoint of line
    th_ends = [x y; x1 y1];
    distancematrix=squareform(pdist(th_ends));
    endpoint = find (distancematrix(1,:)==min(nonzeros(distancematrix(1,:))));
    endpoint=endpoint(1);
    newimg=zeros(size(new2));
    ynew=linspace (y1(endpoint-1),y,len);
    xnew=linspace (x1(endpoint-1),x,len);
    index = sub2ind(size(new2),round(xnew),round(ynew));
    newimg(index)=1;
    
    
    % if intersect stop at intersection point
    before=bwmorph(interior,'thin',inf);
    intersection_pts_b = find_skel_intersection(before);
    [sizeb sizebc]=size(intersection_pts_b);
    
    %before and after extension
    interior_temp=im2bw(imadd(im2bw(interior),im2bw(newimg)));
    intersecttest=bwmorph(im2bw(interior_temp),'thin',inf);
    intersection_pts = find_skel_intersection(intersecttest);
    [sizef sizefc]=size(intersection_pts);
    
    
    % additional intesection points? that means connect endpoint to int 
    if (sizef>sizeb)
        if (sizeb==0)
            intersect_point =intersection_pts;
        else
            intersect_point= setxor(intersection_pts, intersection_pts_b,'rows');
        end
        dmat=[intersect_point(2) intersect_point(1); x y; x1(endpoint-1) y1(endpoint-1)];
        distance_s=pdist ([dmat],'Euclidean');
        if (min(distance_s)>2)
            newimg=zeros(size(new2));
            [x y]=find(etest==1);
            th_ends = [x y; intersect_point(:,2) intersect_point(:,1)];
            distancematrix=squareform(pdist(th_ends));
            endpoint = find (distancematrix(1,:)==min(nonzeros(distancematrix(1,:))));
            endpoint=endpoint(1);
            ynew=linspace (intersect_point(endpoint-1,1),y,len);
            xnew=linspace (intersect_point(endpoint-1,2),x,len);
            index = sub2ind(size(new2),round(xnew),round(ynew));
            newimg(index)=1;
            interior=im2bw(imadd(im2bw(interior),im2bw(newimg)));
        else
            interior=interior_temp;
        end
    else
        interior=interior_temp;
    end
    
    
    
    storeimage=imadd (im2bw(storeimage),im2bw(newimg));
    storeimage=im2bw(storeimage);
end

final=imadd(im2bw(storeimage),im2bw(object));
final=im2bw(final);
end