%output total = combined membrane bnw
%input smooth = size of smoothing kernal 0 = no smoothing
%directory = directory of membrane images


%% ETM
function [total]=batchmembraneGray(ksize,directory)
s=size(directory);
s=s(2);

total=imread(directory{1});
total = imadjust(total,stretchlim(total),[0.05 0.95]);
if ksize
    sigma = 0.3 * ((ksize - 1) * 0.5 - 1) + 0.8;
    G = fspecial('gaussian', [ksize ksize], sigma);
    total = imfilter(total,G,'same');
end
total=(mat2gray(total)); %normalize to 0-1

for i=2:s
    I=imread(directory{i});
    I = imadjust(I,stretchlim(I),[0.05 0.95]);
    if ksize
        I = imfilter(I,G,'same');
    end
    I=(mat2gray(I));
    
    total=mat2gray(imadd (total,I));
    %total=max(total,I);
    %total=mat2gray(total);
end

%total=binaryadd (total, im2bw(imread ('k.jpg')));
end



% %use adaptive thresholding
% total=adaptiveimagesGray(char(filename(1)),lev,1);
% total = imadjust(total,stretchlim(total),[]);
% 
% percCut=prctile(total(:),98); %gets 99 percentile of image
% total(total> percCut)=0; %sets anything >99%ile to 0
% total=imcomplement(mat2gray(total)); %normalize to 0-1
% for i=2:s
%     I=adaptiveimagesGray(char(filename(i)),lev,1);
%     percCut=prctile(I(:),99); %gets 99 percentile of image
%     I(I> percCut)=0; %sets anything >99%ile to 0
%     I=imcomplement(mat2gray(I));
%     total=mat2gray(imadd (total,I));
%     
%     
% end
% 
% %total=binaryadd (total, im2bw(imread ('k.jpg')));
% end
