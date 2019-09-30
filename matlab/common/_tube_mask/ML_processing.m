function [ procIm ] = ML_processing (epi)
% bcat=strcat (directory,bcat);
% cd44=strcat (directory,cd44);
% pck=strcat (directory,pck);

procIm = mat2gray(imread(epi{2}));

if ( size(procIm, 3) ~= 1 )
    procIm = rgb2gray(procIm);
end

%procIm = im2double(procIm);
procIm=imadjust(procIm,stretchlim(procIm, [0 1]));

%adapthisteq(procIm, 'ClipLimit', 0.2);

for i = 3:length(epi)

   
    im2 = mat2gray(imread(epi{i}));

    if ( size(im2, 3) ~= 1 )
        im2 = rgb2gray(im2);
    end

    %im2 = im2double(im2);
    im2=imadjust(im2,stretchlim(im2, [0 1]));
    
    procIm=procIm+abs(im2-procIm);
    procIm=imadjust(procIm,stretchlim(procIm, [0 1]));   

end