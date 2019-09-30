function shape2(image)

img = imread('triangle.png');
BW=im2bw(img);
imshow(BW);
hold on
st = regionprops(BW,'Centroid','Orientation','MajorAxisLength' );
hlen=st.MajorAxisLength/2;
xCentre=st.Centroid(1);
yCentre=st.Centroid(2);
cosOrient=cosd(st.Orientation);
sinOrient=sind(st.Orientation);
xcoords=xCentre+hlen*[cosOrient -cosOrient];
ycoords=yCentre+hlen*[sinOrient -sinOrient];
xlin=linspace (xcoords(1),xcoords(2),1000);
ylin=linspace (ycoords(1),ycoords(2),1000);
index = unique(sub2ind(size(img),round(ylin),round(xlin)));
newimg=zeros(size(BW));
newimg(index)=1;
imshow(newimg);
fimg=newimg.*BW;

BW2 = edge(BW, 'canny');
p=imadd (BW2,im2bw(newimg));
input_skeleton_image = bwmorph(p,'thin',inf);
intersecting_pts = find_skel_intersection(input_skeleton_image, 'testing');
xc=round(xCentre);
yc=round(yCentre);
X=[intersecting_pts];
X2=[intersecting_pts(1,:);xc,yc];
X3=[intersecting_pts(2,:);xc,yc];
d1 = pdist(X,'euclidean');
d5 = pdist(X2,'euclidean');
d6 = pdist(X3,'euclidean');

%%%

cosOrient2=cosd(st.Orientation+45);
sinOrient2=sind(st.Orientation+45);
xcoords2=xCentre+(hlen)*[cosOrient2 -cosOrient2];
ycoords2=yCentre+(hlen)*[sinOrient2 -sinOrient2];
xlin2=linspace (xcoords2(1),xcoords2(2),1000);
ylin2=linspace (ycoords2(1),ycoords2(2),1000);
index2= unique(sub2ind(size(BW),round(ylin2),round(xlin2)));
newimg2=zeros(size(BW));
newimg2(index2)=1;
fimg2=newimg2.*BW;

BW2 = edge(BW, 'canny');
p2=imadd (BW2,im2bw(newimg2));
input_skeleton_image2 = bwmorph(p2,'thin',inf);
intersecting_pts2 = find_skel_intersection(input_skeleton_image2, 'testing');
X4=[intersecting_pts2];
X5=[intersecting_pts2(1,:);xc,yc];
X6=[intersecting_pts2(2,:);xc,yc];
d2 = pdist(X4,'euclidean');
d7 = pdist(X5,'euclidean');
d8= pdist(X6,'euclidean');

%%%

cosOrient3=cosd(st.Orientation+90);
sinOrient3=sind(st.Orientation+90);
xcoords3=xCentre+hlen*[cosOrient3 -cosOrient3];
ycoords3=yCentre+hlen*[sinOrient3 -sinOrient3];
xlin3=linspace (xcoords3(1),xcoords3(2),1000);
ylin3=linspace (ycoords3(1),ycoords3(2),1000);
index3 = unique(sub2ind(size(BW),round(ylin3),round(xlin3)));
newimg3=zeros(size(BW));
newimg3(index3)=1;
fimg3=newimg3.*BW;

BW2 = edge(BW, 'canny');
p3=imadd (BW2,im2bw(newimg3));
input_skeleton_image3 = bwmorph(p3,'thin',inf);
intersecting_pts3 = find_skel_intersection(input_skeleton_image3, 'testing');
X7=[intersecting_pts3];
X8=[intersecting_pts3(1,:);xc,yc];
X9=[intersecting_pts3(2,:);xc,yc];
d3= pdist(X7,'euclidean');
d9= pdist(X8,'euclidean');
d10= pdist(X9,'euclidean');

%%%

cosOrient4=cosd(st.Orientation-45);
sinOrient4=sind(st.Orientation-45);
xcoords4=xCentre+hlen*[cosOrient4 -cosOrient4];
ycoords4=yCentre+hlen*[sinOrient4 -sinOrient4];
xlin4=linspace (xcoords4(1),xcoords4(2),1000);
ylin4=linspace (ycoords4(1),ycoords4(2),1000);
index4 = unique(sub2ind(size(BW),round(ylin4),round(xlin4)));
newimg4=zeros(size(BW));
newimg4(index4)=1;
fimg4=newimg4.*BW;

BW2 = edge(BW, 'canny');
p4=imadd (BW2,im2bw(newimg4));
input_skeleton_image4 = bwmorph(p4,'thin',inf);
intersecting_pts4 = find_skel_intersection(input_skeleton_image4, 'testing');
X10=[intersecting_pts4];
X11=[intersecting_pts4(1,:);xc,yc];
X12=[intersecting_pts4(2,:);xc,yc];
d4= pdist(X10,'euclidean');
d11= pdist(X11,'euclidean');
d12= pdist(X12,'euclidean');

ar=[d1,d2,d3,d4];
m=min(ar);
d13=d1/m;
d14=d2/m;
d15=d3/m;
d16=d4/m;

d17=d5:d6;
d18=d8:d7;
d19=d10:d9;
d20=d12:d11;
    
%T = table;
%T.Properties.VariableNames = {'v1','v2','v3','v4','v5','v6','v7','v8','v9','v10','v11','v12'};
%newV = {fimg,fimg2,fimg3,fimg4,fu,fu2,fu3,fu4,fl}
%Tnew = [Tnew;newV];

%headers = {'d1' 'd2' 'd3' 'd4' 'd5' 'd6' 'd7' 'd8' 'd9' 'd10' 'd11' 'd12'};
%data = cell(1,12);
%T = cell2table(data);
%T.Properties.VariableNames = headers

