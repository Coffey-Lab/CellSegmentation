
pos='001';

vHE=imread(['/Users/etmckinley/Dropbox (VUMC)/scan_alpha/TCPS4A/VirtualStains/S001_VHE_spot_' pos '.tif']);
novlp=imread(['/Users/etmckinley/Dropbox (VUMC)/scan_alpha/TCPS4A/SegQuant/Novlp/Novlp_' pos '.png']);
cell_border=novlp(:,:,1)==255 & novlp(:,:,2)==255 & novlp(:,:,3)==255;
%cell_border=imcomplement(cell_border);
mask = cat(3, cell_border,cell_border,cell_border);

vHE(mask)=0;
imwrite(vHE,['/Users/etmckinley/Dropbox (VUMC)/scan_alpha/TCPS4A/VirtualStains/S001_VHE_spot_' pos '_seg.jpg']) 


%imshow(vHE)
%vHE=vHE.*repmat(cell_border,[1,1,3]);