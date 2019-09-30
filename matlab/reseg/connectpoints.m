% connect inner line segments appropriately
% input
% skel= multiple line segments
% output
% out=connected line segments

function out=connectpoints (skel);

    L2=bwlabel(skel);
    s=max(max(L2));
    L3=zeros(size(L2));
    
    % ignore loop elements
    for i=1:s
       temp=selectobjects(i,L2);
       eptemp = bwmorph(temp, 'endpoints');
       if (max(max(eptemp))~=0)
           L3=imadd (im2bw(L3),im2bw(temp));
       end
           
    end
    
    L2=bwlabel(L3);
 
    endpoints = labelendpoints (L2);
    sklearea=regionprops (L2,'Area');
    sklearea=cell2mat({sklearea.Area});
    minimum =min(sklearea);
    [r c]=size (sklearea);
   
    %keep doing this : connect all the lines if there is more than one element
    %if the size of line segments is < 40
    %if endpoints distance are > 13
    while ((c>1) && ((minimum < 40) && (findDistanceEndpoint (L2) <13)))
        [D I]=sort(sklearea);
        bb=1;
        i=I(bb);
        %linsapce from closetendpoint
        [xnew ynew d] =findclosestendpoint (i,endpoints);
        while (d>13)
           bb=bb+1; 
           i=I(bb);
           [xnew ynew d] =findclosestendpoint (i,endpoints);
        end
        %connect closest endpoints
        newimg=zeros(size(L3));
        %index = sub2ind(size(newimg),round(ynew),round(xnew));
        index = sub2ind(size(newimg),round(xnew),round(ynew));
        newimg(index)=1;
        %newimg=transpose(newimg);
        newimg=im2bw(newimg);
        L3=im2bw(L3);
        L3=imadd(L3,newimg);
        
        % refresh L2 recursive
        L2=bwlabel(L3);
        endpoints = labelendpoints (L2);
        sklearea=regionprops (L2,'Area');
        sklearea=cell2mat({sklearea.Area});
        minimum =min(sklearea);
        [r c]=size (sklearea);
        
    end
    %final L3
    out=im2bw(L3);
end
