% find and connect endpoints closest to ones in index segment
% inputs
% index = find endpoint closest to endpoints in the index segment
% endpoints = list of end points
% outputs
% mindi = distance of closest endpoint
% xnew ynew= lin space connecting the endpoints
function [xnew ynew mindi] =findclosestendpoint (index,endpoints)

    reference = cell2mat(endpoints(index));
    [r c]=size(reference);

    [r1 c1]= size (endpoints);
    out=0;
    %go through all points in reference segment 
    for i=1:r
        %go through all end points from all segments
        for j=1:c1
                distance=[];
                test=cell2mat (endpoints(j));
                
                %number of endpoints in one segment
                [r2 c2]= size (test);
                for k=1:r2
                  
                    %find distance endpoint to endpoint in ref
                        temp=[reference(i,:) ; test(k,:)];
                       
                        distance(k)=pdist(temp,'Euclidean');
                   
                end
                %i=index for reference, j=index for other endpoints
                %find the minmum from all endpoints in j
                    distance2(i,j) = min(distance);
                    minindex = find (distance==min(distance));
                    index2 (i,j) = minindex(1);
                            end
       
    end
   % distance get rid of distance 0 
   distance2(distance2==0)=999;
 
   %find index of min distance
    [mn1 mn2]= find (distance2==min(min(distance2)));
    m1 = mn1(1);
    m2 = mn2(1);
    
    % index of the min of element2
    linepoint2=index2(m1,m2);
    
    %endpoints of element 2
     line2=cell2mat(endpoints(m2));
 
    %point = closest endpoint in element1 (reference)
     point=reference(m1,:);
     
     %point2 = closest endpoint in element2 (found endpoint)
     point2=line2(linepoint2,:);
     
     %connect the two points with linspace????
    xnew=linspace (point(1),point2(1),1000);
    ynew=linspace (point(2),point2(2),1000);
   
    mindi=min(min(distance2));
   
end