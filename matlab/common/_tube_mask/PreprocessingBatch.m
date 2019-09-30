function [ procIm ] = PreprocessingBatch (epi)
% bcat=strcat (directory,bcat);
% cd44=strcat (directory,cd44);
% pck=strcat (directory,pck);

procIm = imread(epi{1});

if ( size(procIm, 3) ~= 1 )
    procIm = rgb2gray(procIm);
end

procIm = im2double(procIm);
procIm=adapthisteq(procIm, 'ClipLimit', 0.2);

for i = 2:length(epi)

   
    im2 = imread(epi{i});

    if ( size(im2, 3) ~= 1 )
        im2 = rgb2gray(im2);
    end

    im2 = im2double(im2);
    im2=adapthisteq(im2,'ClipLimit', 0.2);
    
    procIm=procIm+abs(procIm-im2);
    procIm=adapthisteq(procIm);    

end