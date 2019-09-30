%resegment single object
%segobject = resegmented
% singleobject = 1object from mask
% total = total mebrane mask
function bbb=resegO(singleobject,total,numx)
maskweird5=im2bw(singleobject);
%total=im2bw(imread ('total.jpg'));
%se=strel('disk', 1);
%total=imdilate (total,se);
mw5=imsubtract(maskweird5,total);
mw5=im2bw(mw5);
%open the gap

se=strel('disk', 2);
k=imopen (mw5,se);


% add back edge to object to complete
e=edge(maskweird5,'Canny');
added=imadd (im2bw(k),im2bw(e));

% eliminate edge holes 
se=strel('disk', 2);
maskerode=imerode(maskweird5,se);
e2=edge(maskweird5,'Canny');
e2=imdilate (e2,se);
added=imadd(im2bw(added),im2bw(e2));

% close all holes
holes=closesmallholes (added,15);
%imshow (holes)

% find all small line segments
inv=imcomplement (holes);
 L=bwlabel (inv,4);
 areas=regionprops (L,'Area');
  areaarray=cell2mat({areas.Area});
  [D I]=sort(areaarray);
  ind=find (D~=max(D));
  D=D(ind);I=I(ind);
  ind=(D~=1);
  D=D(ind);I=I(ind);
  %you have to get rid of all area=1
  line=selectobjects (I, L);
  
%extended=newdivide(line);
%sub=imsubtract (im2bw(mw4),im2bw(extended));

% make line segments thin
input_skeleton_image = bwmorph(line,'thin',inf);

input_skeleton_image=input_skeleton_image.*maskweird5;

if max(input_skeleton_image(:))>0
    input_skeleton_image = extendO(input_skeleton_image, maskweird5, 7);
end

% connect segments to edge
[remainder7 edge7]=intersectfirst (input_skeleton_image,maskweird5);

%L2=bwlabel(input_skeleton_image);

L2=bwlabel(remainder7);

number=max(max(L2));

input_skeleton_image2=zeros(size(input_skeleton_image));

%eliminate all minor brancehs to make line segments
for kk=1:number
    temp=selectobjects (kk,L2);
    
    skelD= trimtree(temp);
   %figure, imshow (skelD)
    
   %if it is bigger than a point
    if sum(sum(skelD))>1
    input_skeleton_image2=imadd(im2bw(input_skeleton_image2),im2bw(skelD));
    end
end

input = bwmorph(im2bw(input_skeleton_image2),'thin',inf);
%input_skeleton_image2 = bwmorph(input_skeleton_image, 'spur',2);
out=connectpoints(input);
%out=connectpoints(input_skeleton_image2);
a=intersect_k (out,edge7);

%segobject=imadd(im2bw(a),im2bw(input_skeleton_image));
a=bwmorph(a, 'thin',Inf);
segobject=bwmorph(a, 'spur',3);
segobject=finalconnect_2 (segobject,singleobject,7);
segobject=segobject.*maskweird5;
segobject=imadd (im2bw(segobject),im2bw(e));
segobject2=finalconnect(segobject);
if (numx>0)
    segobject3=finalconnect_2O (segobject2,singleobject,100);
else
    segobject3=segobject2;
end
segobject3=segobject3.*maskweird5;
segobject3=imadd(im2bw(segobject3),im2bw(e));

e2=edge(maskweird5,'Canny');
e2=imdilate (e2,strel('disk',2));
segobject4=imsubtract(im2bw(segobject3),im2bw(e2));
segobject5=bwmorph(im2bw(segobject4),'thin',inf);
se=strel('disk',1);
temp2=imdilate (maskweird5,se);
finale=bwperim(temp2);
bbb=intersect_k (segobject5,finale);
bbb=im2bw(imsubtract(im2bw(bbb),im2bw(finale)));
% %segobject3=imclose(segobject3,strel('disk',2));
% segobject3=bbb;


%segobject3=closesmallholes (segobject3,100);
%se = strel('disk', 3);
%segobject3= imclose (segobject3,se);

%imwrite (singleobject,strcat(num2str(numx),'_.jpg'));

%imwrite (segobject,strcat(num2str(numx),'.jpg'));
%imshow(outcome);
%imwrite (outcome,'outcome.jpg');
end
%endPoints = bwmorph(input_skeleton_image, 'endpoints');
%L2=bwlabel(input_skeleton_image);

%sklearea=regionprops (L2,'Area');

%endpoints = labelendpoints (L2);

