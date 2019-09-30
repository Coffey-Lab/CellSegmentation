function [ procIm ] = Preprocessing2 (directory, bcat,cd44,pck)
bcat=strcat (directory,bcat);
cd44=strcat (directory,cd44);
pck=strcat (directory,pck);

im = imread(bcat);

if ( size(im, 3) ~= 1 )
    im = rgb2gray(im);
end

im = im2double(im);
im=adapthisteq(im);

   
    im2 = imread(cd44);

    if ( size(im2, 3) ~= 1 )
        im2 = rgb2gray(im2);
    end

    im2 = im2double(im2);
    im2=adapthisteq(im2);
    
    im3 = imread(pck);

    if ( size(im3, 3) ~= 1 )
        im3 = rgb2gray(im3);
    end

    im3 = im2double(im3);
    im3=adapthisteq(im3);
    
    procIm=im+abs(im-im2)+abs(im-im3);
    procIm=adapthisteq(procIm);


end

