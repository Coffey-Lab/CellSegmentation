% intersect the inner lines to edge e
% inputs 
% line = line segments (image) 
% e = edge
% output
% out = line segments connected to edge

function out = intersect_k (line,e)
   
    line2=line;
   
    L3=bwlabel (line);
   
         
    for ii=1:max(max(L3))
       
        line=selectobjects (ii, L3);
        input = bwmorph(line,'thin',inf);
        endpoints=labelendpoints(input);
        
        endpoints=endpoints{1};
        
        [r c]= size (endpoints);
    
        [x y]=find (e==1);
        
        
       
 
        for i=1:r
         newimg=zeros(size(line));
            distance=0;
            for j=1:size(x)
                distance(j)=pdist ([endpoints(i,:); x(j) y(j)],'Euclidean');
            end
            
            index2 = find (distance==min(distance));
        
            x1=endpoints (i,1); 
            y1=endpoints (i,2);
            x2=x(index2);
            y2=y(index2);
            x2=x2(1);
            y2=y2(1);
            xnew=linspace (x1,x2,1000);
            ynew=linspace (y1,y2,1000);
            %index = sub2ind(size(newimg),round(ynew),round(xnew)); 
            index= sub2ind(size(newimg),round(xnew),round(ynew));
            
            newimg(index)=1;
            %newimg=transpose(newimg);
            newimg=im2bw(newimg);
             
            line2=im2bw(line2);
         
            line2=imadd(line2,newimg);
        
        end
    end
    out=im2bw(imadd(im2bw(e),im2bw(line2)));
   
    
end