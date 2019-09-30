%resegment single object
%segobject = resegmented
% singleobject = 1object from mask
% total = total mebrane mask
function bbb=reseg(singleobject,total,numx)
maskweird5=im2bw(singleobject);

 s= size(total);
    pixadj=1;
    if s(1)~=2048 || s(2)~=2048 %check if images is from Cytell ~=2048
        pixadj=3; %adjust for smaller pixel size if Cytell
    end

mw5=im2bw(imsubtract(maskweird5,total));

%open the gap
se=strel('disk', 2);
mw5=imopen (mw5,se);


% add back edge to object to complete
e=bwperim(maskweird5);
added=imadd (im2bw(mw5),im2bw(e));
clear mw5

% eliminate edge holes 
e2=bwperim(maskweird5);
e2=imdilate (e2,se);
added=imadd(im2bw(added),im2bw(e2));
clear e2

% find all small line segments
inv=imcomplement (closesmallholes (added,15*pixadj));
 L=bwlabel (inv,4);
 clear inv
 
 areas=regionprops (L,'Area');
  areaarray=cell2mat({areas.Area});
  clear areas
  
  [D I]=sort(areaarray);
  ind=find (D~=max(D));
  D=D(ind);I=I(ind);
  ind=(D~=1);
  %D=D(ind);
  I=I(ind);
  %you have to get rid of all area=1
  line=ismember(L,I);
  

% make line segments thin
input_skeleton_image = bwmorph(line,'thin',inf);

input_skeleton_image=input_skeleton_image.*maskweird5;

if max(input_skeleton_image(:))>0
    input_skeleton_image = extend2(input_skeleton_image, maskweird5, 7);
end

% connect segments to edge
[remainder7, edge7]=intersectfirst (input_skeleton_image,maskweird5);
clear input_skeleton_image

L2=bwlabel(remainder7);

number=max(max(L2));

input_skeleton_image2=zeros(size(L2));

%eliminate all minor branches to make line segments
for kk=1:number
    temp=ismember (L2,kk);
    
    skelD= trimtree(temp);
     
   %if it is bigger than a point
    if sum(sum(skelD))>1
    input_skeleton_image2=imadd(im2bw(input_skeleton_image2),im2bw(skelD));
    end
end
clear L2
input = bwmorph(im2bw(input_skeleton_image2),'thin',inf);
%input_skeleton_image2 = bwmorph(input_skeleton_image, 'spur',2);
out=connectpoints(input);
clear input
%out=connectpoints(input_skeleton_image2);
a=intersect_k (out,edge7);
clear edge7
clear out
%segobject=imadd(im2bw(a),im2bw(input_skeleton_image));
a=bwmorph(a, 'thin',Inf);
segobject=bwmorph(a, 'spur',3);
segobject=finalconnect_2 (segobject,singleobject,7);
segobject=segobject.*maskweird5;
segobject=imadd (im2bw(segobject),im2bw(e));
segobject2=finalconnect(segobject);
clear segobject
if (numx>0)
    segobject3=finalconnect_2 (segobject2,singleobject,100);
else
    segobject3=segobject2;
end
clear segobject2
segobject3=segobject3.*maskweird5;
segobject3=imadd(im2bw(segobject3),im2bw(e));

%e2=edge(maskweird5,'Canny');
e2=bwperim(maskweird5);

e2=imdilate (e2,strel('disk',2));
segobject3=imsubtract(im2bw(segobject3),im2bw(e2));
segobject3=bwmorph(im2bw(segobject3),'thin',inf);
temp2=imdilate (maskweird5,strel('disk',1));
finale=bwperim(temp2);
bbb=intersect_k (segobject3,finale);
bbb=im2bw(imsubtract(im2bw(bbb),im2bw(finale)));

end


