%extend line segments at both endpoints
%object = input_skeleton_image
%backdrop = maskweird5
%hlen = length you want to extend each line

function input_skeleton_image = extend2(object, backdrop, hlen)
    
trimBy = 7;

%create image with just the edge of the cell
e=edge (backdrop,'sobel');

object2 = imadd(im2bw(object), im2bw(e));
%figure, imshow(object)

%find endpoints
object2 = bwmorph(object,'thin',inf);
ep = bwmorph (object2, 'endpoints');

%create frame
totalcanvas=zeros(size(backdrop));
    [br bc]=size(totalcanvas);
    totalcanvas(1:2,:)=1;
    totalcanvas((br-1:br),:)=1;
    totalcanvas(:,1:2)=1;
    totalcanvas(:,(bc-1:bc))=1;
    
%if the endpoint is on the edge of the frame, subtract it
ep=im2bw(imsubtract (im2bw(ep),im2bw(totalcanvas))); 

if max(ep(:))==0
    input_skeleton_image=object;
    return
end

%subtract the edge so you have just the line segments
interior=imsubtract(im2bw(object),im2bw(e));
interior=im2bw(interior);

%finds objects that contains endpoints with object > 1 pixel and their
%   locations
L=bwlabel(interior);
number=max(max(L));
temparray=[];
endpointarray=[];
b = 1;

for i=1:number
    %temp=im2bw(selectobjects(i,L));
    temp=ismember(L,i);
    k = im2bw(ep) & temp;
    if ((max(max(k)) >0) && (sum(sum(temp)) > 1))
        temparray{b}=temp;
        endpointarray{b}=k;
        b=b+1;
    end
end

[rol col]=size(temparray);
storeimage=zeros(size(object));

if col==0
    input_skeleton_image=object;
    return
end
    

%for each object that contains and endpoint and > 1 pixel, do the following
for j=1:col
        
    test=temparray{j};
    etest=endpointarray{j};
    test = bwmorph (test, 'thin', Inf);
    [r, c]=size(test);

    len = 1000; 

    %find endpoints - if the endpoint is on the edge of the frame, subtract it
    etest = bwmorph(test, 'endpoints');
    etest=im2bw(imsubtract (im2bw(etest),im2bw(totalcanvas))); 
    [y x] = find(etest == 1);                    %original endpoints

    %trim the line segment 
    trimmed = bwmorph(test, 'spur', trimBy);
    trimSeg = imsubtract(test, trimmed);

    %locate any branchpoints
    new2=im2bw(trimSeg);
    new21 = bwmorph(new2,'skel',inf);
    bp=bwmorph(new21,'branchpoints');
    bp=imdilate(bp, strel('disk',1));

    %get rid of branchpoints by turning black 
    new2(find(bp==1))=0;

    %label the trimmed segments and retrim if the segment contains more
    %   than one original endpoint     
    trimL=bwlabel(new2);
    num=max(max(trimL));   
    retrim=zeros(size(object));
    
    for d = 1:num
        %tempT=im2bw(selectobjects(d,trimL));
        tempT=ismember(trimL,d);
        kT = im2bw(etest) & tempT;
        [yk xk]=find(kT==1);
        [a b]=size (yk);
        if (a>1)
            tempT = bwmorph (tempT, 'thin', Inf);
            trimmed2 = bwmorph(tempT, 'spur', (trimBy + 1));
            trimSeg2 = imsubtract(tempT, trimmed2);
        else 
            trimSeg2 = tempT;
        end
        retrim = imadd(im2bw(retrim) , im2bw(trimSeg2));
    end
 
    %label the trimmed segments and find their locations
    retrimL=bwlabel(retrim);
    num=max(max(retrimL));
    temparrayT=[];
    endpointarrayT=[];
    c = 1;
        
    for m=1:num
         %tempT=im2bw(selectobjects(m,retrimL));
         tempT=ismember(retrimL,m);
         kT = im2bw(etest) & tempT;
         if ((max(max(kT)) >0) && (sum(sum(tempT)) > 1))
             temparrayT{c}=tempT;
             endpointarrayT{c}=kT;
             c=c+1;
         end
    end
        
    [rolT colT]=size(temparrayT);

    %for each trimmed line segment do the following 
    for n = 1:colT
        testT=temparrayT{n};                                           
        etestT=endpointarrayT{n};
        testT = bwmorph (testT, 'thin', Inf);
        [rT, cT]=size(testT);

        %find location of endpoints
        endPointsT = bwmorph(testT, 'endpoints');    
        [yy xx] = find(endPointsT==1);

        %connects the two endpoints to create a straight line 
        distmat=[xx yy];
        distancematrix=squareform(pdist(distmat));
        [one two]=find (distancematrix==max(max(distancematrix)));
        i1=one(1);i2=two(1);
        new3=zeros(size(object));
        ylin=linspace (yy(i1),yy(i2),len);
        xlin=linspace (xx(i1),xx(i2),len);
        index = unique(sub2ind(size(object),round(ylin),round(xlin)));
        new3(index)=1;
       
        %find angle between major axis of line and x axis
        L = bwlabel(new3);
        s=regionprops(L,'Orientation');
        O=mean([s.Orientation]);

        %get orientations off the line
        cosOrient = cosd(O);
        sinOrient = sind(O);

        %get the slope of the line
        [y x]=find(new3==1); 
        [a b]=size (y);
        slope=(y(a)-y(1))/(x(a)-x(1));

        %find end points of the major axis
        largey= find (y==max(y));
        smally= find (y==min(y));
        largex= find (x==max(x));
        smallx= find (x==min(x));
        largey=largey(1);smally=smally(1);
        largex=largex(1);smallx=smallx(1);

        %if the slope is infinite (vertical), execute the code below to add
        %   lines of the set length and measured orientation to extend the 
        %   major axis
        if slope==Inf

            xt=[x(1) x(1)];                 %slope in infinite so x stays the same
            yt=[y(largey)+hlen y(smally)-hlen];     %can just add to y to go up or down 

            largey= find (yt==max(yt));
            smally= find (yt==min(yt));

            if yt(largey)>r
                yt(largey)=r;                  %so it doesn't go off the plane
            end

            if yt(smally)<1
                yt(smally)=1;                  %so it doesn't go off the plane
            end


        %if the slope is positive, execute the codes below to add lines of the
        %    set length and measured orientation to extend the major axis
        elseif slope >= 0

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

        %if the slope is negative, execute the codes below to add lines of the
        %    set length and measured orientation to extend the major axis
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

        %looks at the new points in xt/yt and makes sure they're w/in frame
        ynew=linspace (yt(1),yt(2),len);
        xnew=linspace (xt(1),xt(2),len);
        xnew=round(xnew);
        ynew=round(ynew);
        [ccc rrr]=size(object);
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

        %connects the two extended points
        newimg=zeros(size(object));
        index = unique(sub2ind(size(object),round(ynew),round(xnew)));
        newimg(index)=1;

        %finds newimg's endpoints and subtracts any on frame totalcanvas
        newimg=bwmorph (newimg, 'thin', Inf);
        ep2=bwmorph (newimg, 'endpoints');
        epx=ep2;
        ep2=im2bw(imsubtract (im2bw(ep2),im2bw(totalcanvas))); 

        %finds location of the original endpoint etest and ep2
        epObject = testT & etest;
        [x y]=find(epObject==1);
            
        ind=find(ep2==1);
        if (isempty(ind))                
            ep2=epx;
        end
        [x1 y1]=find(ep2==1);

        %find distance between the points epObject and ep2
        th_ends = [x y; x1 y1];
        distancematrix=squareform(pdist(th_ends));
        endpoint = find (distancematrix(1,:)==min(nonzeros(distancematrix(1,:))));

        %connects one ep2 to its closest etest
        newimg=zeros(size(object));
        ynew=linspace (y1(endpoint-1),y,len);
        xnew=linspace (x1(endpoint-1),x,len);
        index = unique(sub2ind(size(object),round(xnew),round(ynew)));
        newimg(index)=1;

        %finds the intersection points from interior and finds size 
        before=bwmorph(interior,'thin',inf);
        intersection_pts_b = find_skel_intersection(before);
        [sizeb sizebc]=size(intersection_pts_b);

        %add interior and newimg
        interior_temp=im2bw(imadd(im2bw(interior),im2bw(newimg)));

        %finds intersection points and size
        intersecttest=bwmorph(im2bw(interior_temp),'thin',inf);
        intersection_pts = find_skel_intersection(intersecttest);
        [sizef sizefc]=size(intersection_pts);

        %if sizef > sizeb, returns the rows that are different 
        %create matrix of intersection points and etest and ep2 endpoint
        %locations - finds the distance between the points
        %if the mindistance > 2, extends line only to the int point
        if (sizef>sizeb)
            if (sizeb==0)
                intersect_point =intersection_pts;
            else
                intersect_point= setxor(intersection_pts, intersection_pts_b,'rows');
            end
            dmat=[intersect_point(2) intersect_point(1); x y; x1(endpoint-1) y1(endpoint-1)];
            distance_s=pdist ([dmat],'Euclidean');
            if (min(distance_s)>2)
                newimg=zeros(size(interior));
                epObject = testT & etest;
                [x y]=find(epObject==1);
                th_ends = [x y; intersect_point(:,2) intersect_point(:,1)];
                distancematrix=squareform(pdist(th_ends));
                endpoint = find (distancematrix(1,:)==min(nonzeros(distancematrix(1,:))));
                endpoint=endpoint(1);
                ynew=linspace (intersect_point(endpoint-1,1),y,len);
                xnew=linspace (intersect_point(endpoint-1,2),x,len);
                index = sub2ind(size(interior),round(xnew),round(ynew));
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
    outline=imadd(im2bw(storeimage),im2bw(object));
    outline=im2bw(outline);

end


final = im2bw(outline .* backdrop); 
e=imdilate(e, strel('disk',1));
final = imsubtract(final, e);
input_skeleton_image=bwmorph(im2bw(final),'thin',inf);
%figure, imshow(input_skeleton_image)


end
