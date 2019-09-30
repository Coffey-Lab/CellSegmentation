% find the min distance between all endpoints and all line segments for
% connection
% input: mask= mask of all line segments
% output: distance = min distance

function distance = findDistanceEndpoint (mask) 

    mask=bwlabel(mask);
    distance=0;
    number=max(max(mask));
  
    endpoints = labelendpoints (mask);
    
    %every line segment in mask
    for i=1:number
            %find the closest endpoint to line segment 
            [xnew ynew d] =findclosestendpoint (i,endpoints);
            distance (i)=d;
    
    end
    sorted=sort(distance);
   
   distance=sorted(1);
end