function [CellImages]=cell_shape_images(img)

%find number of objects
cellNum=max(img(:)); 

%pre-allocate space
cellImages=zeros(128, 128, cellNum);

for i=1:cellNum

    %disp(num2str(i))
    
    % Use the ismember function to locate a single cell in the entire
    % image, based on the for loop above.
    
    img1 = ismember(img, i);
    
    % Create a box around the image to limit size
    BBox=BBoxCalc(img1);
    img1=img1(BBox(2):BBox(4),BBox(1):BBox(3));
    
     
    % find orientation and rotate major axis horizontally
    measurements = regionprops(img1, 'Orientation');
    img1 = imrotate(img1, -measurements(1).Orientation);
    
    % resize to 128 x 128 pixels
    img1=imresize(img1, [128 128]);
      
    cellImages(:,:,i)=img1;
end

CellImages = squeeze(num2cell(cellImages,[2,1]));