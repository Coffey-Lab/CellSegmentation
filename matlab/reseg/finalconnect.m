% the final connect any oustanding endpoint pairs 
% single end points will remain
% input 
% lines =membranes
% output
% out = connected membranes

function out= finalconnect (lines);
lines=bwmorph(lines, 'thin', Inf);
eptemp = bwmorph(lines, 'endpoints');
final=lines;
out=final;

if (sum(sum(eptemp))~=0)
   % if there is at least two endpoints 
    
    %-1 is a marker for done
    [x y]=find (eptemp==1);
    [rr cc]=size(find (x>=0));
    while (rr>1)
       
    
  
    distance=pdist ([x y],'Euclidean');
      distance(distance==0)=999;
      % connect closes ones first 
    dsearch=min(distance);
    distance=squareform(distance);
  distance(distance==0)=999;
  % find the index with min distance p1 and p2 with squareform
    [x11,x22]=find (distance==dsearch);
    x11=x11(1);
    x22=x22(1);
    
    newimg=zeros(size(eptemp));   
    x1=x(x11); 
    y1=y(x11);
                
    x2=x(x22);
    y2=y(x22);
               
    x1=x1(1);
    y1=y1(1);     
                   
    x2=x2(1);
    y2=y2(1);     
                
           
           
    xnew=linspace (x1,x2,1000);
    ynew=linspace (y1,y2,1000);
    index = sub2ind(size(newimg),round(xnew),round(ynew)); 
    newimg(index)=1;
    %newimg=transpose(newimg);  %commented out ETM
    
    % stop at intersect, just like finalconnect_2
    before=bwmorph(final,'thin',inf);
    intersection_pts_b = find_skel_intersection(before);
    [sizeb sizebc]=size(intersection_pts_b);
    
    final=imadd(im2bw(newimg),im2bw(final));
    
    intersecttest=bwmorph(im2bw(final),'thin',inf);
    intersection_pts = find_skel_intersection(intersecttest);
    
    [sizef sizefc]=size(intersection_pts);
    
    
    
    if (sizef>sizeb)
         if (sizeb==0)
            intersect_point =intersection_pts; 
         else
        intersect_point= setxor (intersection_pts, intersection_pts_b,'rows');
         end
       dmat=[intersect_point(2) intersect_point(1); x1 y1; x2 y2];
       distance_s=pdist ([dmat],'Euclidean');
       if (min(distance_s)>2)
            final=before;
       end
    end
    
    % elminate the endpoints done
    x(x11)=[];x(x22)=[];
    y(x11)=[];y(x22)=[];
   
    [rr cc]=size(find (x>=0));
    
    end
    

   out = bwmorph(final,'thin',inf);
  out=im2bw(out);

    
end