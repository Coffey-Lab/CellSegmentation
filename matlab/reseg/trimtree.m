% return unbranched segment
% input: mask = line segment one at a time
% output: skelD = longest branch, get rid of all branches on skeleton

function skelD = trimtree (mask);

skel= bwmorph(mask,'skel',Inf);
B = bwmorph(skel, 'branchpoints');
B = bwlabel(B);

%no branch points
if (max(max(B))==0)
     skelD=mask;    
    
else
   skelD= longestConstrainedPath(mask);
end
skelD=im2bw(skelD);
end