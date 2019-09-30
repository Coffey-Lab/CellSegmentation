%adaptive thresholding
%output:
%mask= black and white image of thresholded
%input:
%filename=image file
%level= thresholding neighborhold (10 for membranes, 50 for crypt cells)
% option = 1 or 0 for using unsharp mask to create noise

function mask = adaptiveimages(filename,level,option)

    mask=imread(filename);
  if (option == 1)
    H = fspecial('unsharp');
    mask=imfilter(mask,H);
  end
    mask=imcomplement(mask);
    mask=adaptivethreshold2(mask,level,0);
    mask=imcomplement(mask);

end
