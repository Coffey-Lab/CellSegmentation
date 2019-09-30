% find endpoints and then store the end points as coordinates in array
% input
% L2 = object mask
% output
% endpoints = endpoints in an cell array of line segment objects
function endpoints = labelendpoints (L2)
    endpoints=[];
    c=max(max(L2));
    for i=1:c
        eptemp = bwmorph(L2==i, 'endpoints');
        [rows cols] = find(eptemp);
        endpoints{i}=[rows cols];
    end
end
        

