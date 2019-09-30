%resegment single object
% outputs
% bbb = resegmented object
% 
% inputs
% singleobject = 1 object from mask
% total = total mebrane mask
% numx = option to ignore through line reseg (last step) , use -1
% siz = size to close holes, default is 15
function bbb=reseg(singleobject,total,numx,siz)

maskweird5=im2bw(singleobject);
maskweird5=imfill(maskweird5,'holes');
mw5=imsubtract(maskweird5,total);
mw5=im2bw(mw5);

%open the gap by 2 pixels
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
if nargin<4
holes=closesmallholes (added,15);
else
holes=closesmallholes (added,siz);    
end


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
  
% make line segments thin
input_skeleton_image = bwmorph(line,'thin',inf);

input_skeleton_image=input_skeleton_image.*maskweird5;

% connect segments to edge
[remainder7 edge7]=intersectfirst (input_skeleton_image,maskweird5);


L2=bwlabel(remainder7);

number=max(max(L2));

input_skeleton_image2=zeros(size(input_skeleton_image));

%eliminate all minor brancehs to make line segments
for kk=1:number
    temp=selectobjects (kk,L2);
    
    skelD= trimtree(temp);
    
   %if after trim tree is bigger than a point
    if sum(sum(skelD))>1
    input_skeleton_image2=imadd(im2bw(input_skeleton_image2),im2bw(skelD));
    end
end

input = bwmorph(im2bw(input_skeleton_image2),'thin',inf);

% inner-connect
out=connectpoints(input);

% intersect inner-connect with edge (closest point)
a=intersect_k (out,edge7);

% extend spurs 7
a=bwmorph(a, 'thin',Inf);

  totalcanvas=zeros(size(maskweird5));
    [br bc]=size(totalcanvas);
    totalcanvas(1:2,:)=1;
    totalcanvas((br-1:br),:)=1;
    totalcanvas(:,1:2)=1;
    totalcanvas(:,(bc-1:bc))=1;

    a=im2bw(imadd(im2bw(a),im2bw(totalcanvas)));
    a=bwmorph(a, 'thin',Inf);
    segobject=bwmorph(a, 'spur',3);
    segobject=im2bw(imsubtract(im2bw(segobject),im2bw(totalcanvas)));
segobject=finalconnect_2 (segobject,singleobject,7);
segobject=segobject.*maskweird5;
segobject=imadd (im2bw(segobject),im2bw(e));

% connect all remaining 2 endpoints (maybe not needed)
segobject2=finalconnect(segobject);

% extend spurs by 100
if (numx>0)
    segobject3=finalconnect_2 (segobject2,singleobject,100);
else
    segobject3=segobject2;
end
segobject3=segobject3.*maskweird5;
segobject3=imadd(im2bw(segobject3),im2bw(e));

% final clean up get rid of 2 pixels from edge
e2=edge(maskweird5,'Canny');
e2=imdilate (e2,strel('disk',2));
segobject4=imsubtract(im2bw(segobject3),im2bw(e2));
segobject5=bwmorph(im2bw(segobject4),'thin',inf);

%make the edge to connect slightly larger
se=strel('disk',1);
temp2=imdilate (maskweird5,se);
finale=bwperim(temp2);

% connect inner with edge
bbb=intersect_k (segobject5,finale);
bbb=im2bw(imsubtract(im2bw(bbb),im2bw(finale)));
end

