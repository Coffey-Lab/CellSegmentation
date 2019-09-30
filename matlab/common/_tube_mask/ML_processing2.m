function [ procIm ] = ML_processing2 (epi, lim)
% bcat=strcat (directory,bcat);
% cd44=strcat (directory,cd44);
% pck=strcat (directory,pck);

procIm = mat2gray(imread(epi{1}));

if ( size(procIm, 3) ~= 1 )
    procIm = rgb2gray(procIm);
end

%procIm = im2double(procIm);


if length(epi)<2
    procIm=imadjust(procIm,stretchlim(procIm, [0 0.9999]));
    return
end
procIm=imadjust(procIm,stretchlim(procIm, [0 lim]));
%adapthisteq(procIm, 'ClipLimit', 0.2);

for i = 2:length(epi)

   
    im2 = mat2gray(imread(epi{i}));

    if ( size(im2, 3) ~= 1 )
        im2 = rgb2gray(im2);
    end
    if any(strfind(epi{i},'Muc2'))
        im2=adapthisteq(im2, 'ClipLimit', 0.03);
        im2=imadjust(im2,stretchlim(im2, [0 lim]));
    else
    %im2 = im2double(im2);
    im2=imadjust(im2,stretchlim(im2, [0 lim]));
    end
    
    procIm=procIm+abs(im2-procIm);
    
    
    procIm=mat2gray(procIm);
    
    %figure;imshow(procIm);
    
end
procIm=imadjust(procIm,stretchlim(procIm, [0 .999]));
%figure;imshow(procIm);