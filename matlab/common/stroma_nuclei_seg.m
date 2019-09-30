% * Yousef Al-Kofahi, et al. Improved Automatic Detection and Segmentation of Cell Nuclei in Histopathology Images.
%   IEEE TRANSACTIONS ON BIOMEDICAL ENGINEERING, VOL. 57, NO. 4, APRIL 2010
% * Jos B.T.M, et al, The Watershed Transform: Defnitions, Algorithms and Parallelization Strategies
%   Fundamenta Informaticae 41 (2001) 187{228


sourceImage=imread('/Users/etmckinley/Dropbox (VUMC)/scan_alpha/TCPS4A/SegQuant/Stacks/str_000_stack_Probabilities.png');
sourceImage=sourceImage(:,:,1);
%gf=fspecial('gaussian',3*3,3);
%sourceImage2=imfilter(sourceImage,gf,'conv','same','replicate');
%imshowpair(sourceImage, sourceImage2)
% [nuclearMask,nuclearMembranes]=wahlbynucleus(sourceImage,1,5,3,50,1,25,30,1);
% 
% 
% %sourceImage=bfilt2(sourceImage,50,3);
% sourceImage2=bilateralGrayscale(sourceImage, 5,50,.001);
% 
% imagesc(sourceImage2)

threshold=0.9;

 otsu=graythresh(sourceImage);
 BW = im2bw(sourceImage,otsu);
 figure; imshow(BW);
%image = sourceImage;
%figure;imshow(image);
%title('input image');

total = numel(image);


% apply top hat and bottom hat filter
se = strel('disk',30);
tophat = imtophat(image,se);
bottomhat = imbothat(image,se);
filterImage = image + (tophat - bottomhat);
se = strel('disk',15);
tophat = imtophat(filterImage,se);
bottomhat = imbothat(filterImage,se);
filterImage = filterImage + (tophat - bottomhat);

%filterImage(filterImage>255)=255;
% calculate histogram of filtered image
% estimate more than 78.5% area is background (pi/4 = .785)
[counts,x] = imhist(filterImage);
ssum = cumsum(counts);
bg = .215*total;
fg = .99*total;
low = find(ssum>bg, 1, 'first');
high = find(ssum>fg, 1, 'first');
highin=high/255;
if highin >1
    highin=1;
end
adjustedImage = imadjust(filterImage, [low/255 highin],[0 1],1.8);


% image binarization, threshold is choosen based on experience
%if(nargin < 2)
 %   matrix = reshape(adjustedImage,total,1);
  %  matrix = sort(matrix);
  %  threshold = graythresh(matrix(total*.5:end));
%end
binarization = im2bw(adjustedImage,threshold);


% open image and then detect edge using laplacian of gaussian
se2 = strel('disk',5);
afterOpening = imopen(binarization,se2);
%final=imerode(afterOpening, strel('disk',2));
final=imopen(afterOpening, strel('disk',4));

%final=bwlabel(final, 4);
figure;imagesc(final);


  D = -bwdist(~final);
  D(~final) = -Inf;
  D = imhmin(D,1,4); %20 is the height threshold for suppressing shallow minima
  
  %figure; imagesc(D)
  L = watershed(D);
  
  %figure;imagesc(L)
  
  B=L;
  B(B==1)=0;
  B(B>0)=1;
  figure;imagesc(B)
  
  %imshowpair(image, B)
% nsize = 5; sigma = 3;
% h = fspecial('log',nsize,sigma);
% afterLoG = uint8(imfilter(double(afterOpening)*255,h,'same').*(sigma^2));


% se2 = strel('disk',5);
% afterOpening = imopen(binarization,se2);
% %water=watershed(imcomplement(afterOpening));
% AE2=imclose(afterOpening, strel('disk',3));
% figure;imshow(AE2)
% figure;imagesc(afterLoG)
% 
% 
% number_of_nuclei = bwconncomp(afterOpening);
% 
% 
% % % you can either use watershed method to do segmentation
%   D = -bwdist(~afterOpening);
%   D(~afterOpening) = -Inf;
%   L = watershed(D);
% % 
%   imagesc(L)
% 
% outputImage = sourceImage + afterLoG*5;
% %imshow(outputImage);
% imshowpair(sourceImage, afterLoG*10)
% title(['Num Nuc: ' num2str(number_of_nuclei.NumObjects)]);
% drawnow
% 
% D2=imerode(D, strel('disk',3));
% imagesc((D2))
% 
% figure;imshowpair(im2bw(D), im2bw(D2))