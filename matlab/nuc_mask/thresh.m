%This function shows 2 figures. 1 figure of an image with objects with
%sizes under the inputted threshod, and 1 figure of an image with objects
%with sizes above the inputted threshold
%input:
%Threshold used specifically for 'dapi_orig.tif' is 250, and 500 for final
%mask that is labeled
%image
%output:
%more=>threshold
%less=<threshold

function [more,less]= thresh (threshold, mask)
 

m=size(mask,1);
n=size(mask,2);
%Initialize variables
  
less=zeros(m,n);
more=zeros(m,n); %ETM-more=less is quicker
%initialize 2 variables

areas=regionprops(mask,'Area');  


for i=1:m
    for j=1:n
        if mask(i,j)~=0
            %only works when the point is a position in an object in the image
            if areas(mask(i,j)).Area<=threshold
                less(i,j)=1;
                %if the area with the particular label is less than the
                %threshold, saves the pixel of the position in less array
            else
                more(i,j)=1;
                %if the area with the particular label is bigger than the
                %threshold, saves the pixel of the psoition in more array 
            end
        end
    end
end



less=im2bw(less);
more=im2bw(more);
