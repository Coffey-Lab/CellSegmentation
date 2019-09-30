function [attributes]=shape_determination(img)

%% This script finds attributes of cell shapes that can be used to cluster single cells into meaningful shapes.
% Author: Paige (Spencer) Vega
% paige.n.spencer@vanderbilt.edu

% Reference the document titled "Shape code summary - PNV - Jan 2018" for a
% written description of the code.

% Note: CellSegFinal files should be in the same folder as this script.

% Note: The attributes matrix is exported as a text file and can be used 
% for data clustering.

%close all;
%disp('_________________________________________________________________')
%% Load in CellSegFinal image and define cells that will be analyzed one-by-one in a for loop.
% Also creates other essential matrices and checks for proper outlining.

%tic

% read in image using "imread.m" function
% Must have images in same folder as this file.
%clear all

% Read in the CellSegFinal image.
%img = imread('CellSegFinal_000.tif');

% Display the image to confirm it is correct.
%image(img)

% Create a new variable that will represent the element # in the
% loop for the variable i.
t = 1;

% Approximate the number of cells in the CellSegFinal image.  This is just
% used to make a matrix to hold attribute values, so about 5000 is usually
% enough.  

%i=5000;

% Create a matrix of zeros to hold the attribute values.
attributes = zeros(11, max(img(:)));

%% For loop

% Set the range of cells to be analyzed.  Typically it is best to overshoot
% and find the last cell ID that worked, and run it again with that number
% as the maximum.  Or, you can see how many cells there are from looking at
% the PosStats file.
for i=1:max(img(:));
    %disp(['Calculating for cell ID = ' num2str(i)])
    
    % Use the ismember function to locate a single cell in the entire
    % image, based on the for loop above.
    img1 = ismember(img, i);

    % Create a box around the image so that it is more visually appealing
    % to look at.  This is Eliot's BBoxCalc function.
     BBox=BBoxCalc(img1);
     img2=img1(BBox(2):BBox(4),BBox(1):BBox(3));
     img2=imrotate(img2,90);
     % display the image
     %image(img2);

% rename img2 as BW
BW = img2;

% Sum the number of pixels in the binary image by first summing the rows
% (sum1_BW), then sum the columns that result (sum2_BW).
sum1_BW = sum(BW);
sum2_BW = sum(sum1_BW);

% Show the image if no ";" after "imshow". Name the image title "Shape."
% hold on
% imshow(BW)
% title('Shape')

% Call upon the bwmorph function to perform an outline of the shape, where
% the border is white pixels and the center is now black.
st = regionprops(BW, 'Centroid', 'Area', 'MajorAxisLength', 'Perimeter', 'Orientation');
% This part rotates the image to orient it based on the major axis, but it
% is no longer necessary due to some updates in the code.  Let's keep it
% anyway.
imgr = imrotate(BW,90-st.Orientation);

% Get the shape outline.
st = regionprops(imgr, 'Centroid', 'Area', 'MajorAxisLength', 'Perimeter', 'Orientation');
outline_shape = bwmorph(imgr,'remove');

% Sum the number of white pixels in the outline by first summing the rows
% (sum1_outline), then sum the columns that result (sum2_outline).
sum1_outline = sum(outline_shape);
sum2_outline = sum(sum1_outline);

% Quality checkpoint: the sum of the white pixels in the outline of the 
% shape should be less than the sum of the white pixels in the BW shape.
%if sum2_outline < sum2_BW
   % disp('Outline successful.  Continue with script.')
%else
   % disp('ERROR: Outline unsuccessful.')
%end

% If the shape is too small, don't even bother with the rest.
% Note:  might be good to increase the lower bound to a larger value.
if sum2_outline > 35 && sum2_outline < 300 && st.Area < 3000; %|| sum2_outline/st.Area < 0.3
    
% Compute the size of the 'Shape Outline' image (x by y pixels).  Compute
% the total number of elements (# pixels) in the 'Shape Outline' image.
% Note:  'Shape Outline' image is the resultant BW image from outline_shape
% matrix.
outline_size = size(outline_shape);
outline_el = numel(outline_shape);

% Find the centroid(s) of the object(s) in the image.  Make a matrix of the
% x and y coordinates of these centroids.  Plot them with a red asterisk.

%%%%%% TAKE OUT COMMENTS BELOW IF YOU WANT TO SEE THE SHAPE IN A FIGURE
% % % % % % % % % % % % % % figure
% % % % % % % % % % % % % % imshow(outline_shape)
% % % % % % % % % % % % % % title(['Shape Outline' num2str(i)])
% % % % % % % % % % % % % % hold on
centroid = cat(1, st.Centroid);
% % % % % % % % % % % % % % plot(centroid(:,1), centroid(:,2), 'r*')
orientation = st.Orientation;
BW = imrotate(BW,orientation);
% % % % % % % % % % % % % % imshow(BW)
% % % % % % % % % % % % % 
% % % % % % % % % % % % % hold off



%% Calculate the distance from the centroid to the border for every white pixel.

% Ken's improved and simpler code:
dim = size(imgr);
col1 = round(dim(2)/2);
row1 = min(find(imgr(:,col1)));
% boundary = bwtraceboundary(imgr,[row1, col1],'E');
boundary = bwboundaries(imgr);

% Use a for loop to find the row and column values for each pixel in the
% outline and map it to the distance from the centroid.
% "boundary" is x and y coordinates for white pixels of outline
% "mags" is the magnitudes of the distances from the centroid to the outline
boundary=boundary{1};
for a = 1:length(boundary);
    row=boundary(a,1);
    col=boundary(a,2);
    dist_from_centroid = sqrt((col-centroid(1,1))^2+(row-centroid(1,2))^2);
    mags(1,a)=dist_from_centroid;
end

%%%%% TAKE COMMENT OUT IF YOU WANT TO PLOT IT %%%%%%%%%
 % creates two periods of the plot
 %mags=horzcat(mags,mags);


 
%% Find local maximums:

% Remember, the "mags" array contains the magnitude of the distance from
% the centroid.  
% First, calculate the number of distances calculated, which is also the
% number of white pixels in the outline.  Then create an array, "x", which
% will serve as the x-axis for the plot.
% Next, plot the points of the "mags" array, but multiply by -1 so that the
% values are negative.  This is so we need to find local maximums.
% Finally, use the "smooth" with 'loess' command to make a smooth plot that
% passes through the points with the best fit. 
% Note:  in my experience the smooth_out2 and raw_max2 are the best without
% diluting the plot shape too drastically, but I've kept the code for up to
% 5X in case it's necessary for some reason.

%%%%%%%%%%%%%%%%%%%%%TAKE COMMENTS OUT IF YOU WANT TO SEE THE PLOTS
%%%%%%%%%%%%%%%%%%%%%figure
number_pts = numel(mags);
x = 1:1:number_pts*2;
%plot_rough = plot(-1.*mags);
%hold on
smooth_out = smooth(horzcat(-1.*mags,-1.*mags), 0.1, 'loess');
%plot_smooth = plot(x,horzcat(-1.*mags,-1.*mags),'b.',x,smooth_out,'r-');
%%%%%hold on
smooth_out2 = smooth(smooth_out, 0.1, 'moving');
%%%%%%%%%%%%%%%%%%%%%%%%%%%plot_smooth2 = plot(x,smooth_out,'b.',x,smooth_out2,'r-');
% hold on
smooth_out3 = smooth(smooth_out2, 0.1, 'moving');
% plot_smooth3 = plot(x,smooth_out2,'b.',x,smooth_out3,'r-');
% hold on
smooth_out4 = smooth(smooth_out3, 0.1, 'moving');
% plot_smooth4 = plot(x,smooth_out3,'b.',x,smooth_out4,'r-');
%hold on
smooth_out5 = smooth(smooth_out4, 0.1, 'moving');
%plot_smooth5 = plot(x,smooth_out4,'b.',x,smooth_out5,'r-');
% % % % % % % % % % % % % xlabel('pixel')
% % % % % % % % % % % % % ylabel('distance')
% % % % % % % % % % % % % title('Plot of distances - two periods')

% Now find the local maxima of the smooth plots.
[raw_max,x] = findpeaks(smooth_out);
[raw_max2,x2] = findpeaks(smooth_out2);
[raw_max3,x3] = findpeaks(smooth_out3);
[raw_max4,x4] = findpeaks(smooth_out4);
[raw_max5,x5] = findpeaks(smooth_out5);

% you can use this part to plot all of them if you want.
% hold on
% plot(x,raw_max,'y^','MarkerSize',5)
% hold on
% plot(x2,raw_max2,'g*','MarkerSize',10)
% hold on
% plot(x3,raw_max3,'mo','MarkerSize',10)
% hold on
% plot(x4,raw_max4,'co','MarkerSize',10)
% hold on
% plot(x5,raw_max5,'go','MarkerSize',10)

% Concatenate the x-values and maximums together.
% Note: here I use the second smoothened plot.
max_coords = cat(2, x2, raw_max2);

% Normalize the maxima
norm_max = raw_max2/max(raw_max2);

%% Find local minima

% same procedure as for maxima above.

% Do this by plotting the mags instead of -1.*mags
%%%%%%%%%%%hold on
x = 1:1:(number_pts*2);
%plot_rough_mins = plot(mags);
%hold on
smooth_out_mins = smooth(horzcat(mags,mags), 0.1, 'loess');
%%%%%%%%%%%%%%%%%%%plot_smooth_mins = plot(x,horzcat(mags,mags),'b.',x,smooth_out_mins,'r-');
%%%%%%%%%%%%%%%%%%%hold on
smooth_out_mins2 = smooth(smooth_out_mins, 0.1, 'moving');
%%%%%%%%%%%%%%%%%%%plot_smooth_mins2 = plot(x,smooth_out_mins,'b.',x,smooth_out_mins2,'r-');
% hold on
smooth_out_mins3 = smooth(smooth_out_mins2, 0.1, 'moving');
% plot_smooth_mins3 = plot(x,smooth_out_mins2,'b.',x,smooth_out_mins3,'r-');
% hold on
smooth_out_mins4 = smooth(smooth_out_mins3, 0.1, 'moving');
% plot_smooth_mins4 = plot(x,smooth_out_mins3,'b.',x,smooth_out_mins4,'r-');
%hold on
smooth_out_mins5 = smooth(smooth_out_mins4, 0.1, 'moving');
%plot_smooth_mins5 = plot(x,smooth_out_mins4,'b.',x,smooth_out_mins5,'r-');

% Now find the local maxima on the smooth plots.
[raw_max_mins,x_mins] = findpeaks(smooth_out_mins);
[raw_max_mins2,x_mins2] = findpeaks(smooth_out_mins2);
[raw_max_mins3,x_mins3] = findpeaks(smooth_out_mins3);
[raw_max_mins4,x_mins4] = findpeaks(smooth_out_mins4);
[raw_max_mins5,x_mins5] = findpeaks(smooth_out_mins5);

% hold on
% plot(x_mins,raw_max_mins,'g^','MarkerSize',10)
% hold on
% plot(x_mins2,raw_max_mins2,'g*','MarkerSize',10)
% hold on
% plot(x_mins3,raw_max_mins3,'mo','MarkerSize',10)
% hold on
% plot(x_mins4,raw_max_mins4,'co','MarkerSize',10)
% hold on
% plot(x_mins5,raw_max_mins5,'go','MarkerSize',10)

% Concatenate the x-values and minimums together.
min_coords = cat(2, x_mins2, raw_max_mins2);

% Normalize the minima
norm_min = raw_max_mins2/max(raw_max_mins2);



%% Concatenate maxima and minima with x-coordinaes.

% Since we are about to concatenate the max and mins matrices toether, we
% need a way to keep track of which are maxima and which are minima.
% Create a new column 3 in the matrices where 0 will mean minima and 1 will
% mean maxima.

min_coords_ID = zeros(size(min_coords,1),1);
min_coords = cat(2, min_coords, min_coords_ID);

max_coords_ID = ones(size(max_coords,1),1);
max_coords = cat(2, max_coords, max_coords_ID);

% for the if-statement and plotting (negatives are kept)
max_n_mins_plot = cat(1, max_coords, min_coords);
% sort this to ascending x-values.
max_n_mins_plot = sortrows(max_n_mins_plot);


% Also make a matrix of max and mins with no negatives.
max_n_mins = abs(max_n_mins_plot);


% These maxima and minima are determined using two cycles of the plot so
% that all maxima and minima can be found regardless of starting point.
% Eliminate all repetitive values.
[~,idx]=unique(max_n_mins(:,2));
max_n_mins = max_n_mins(idx,:);

[~,idx]=unique(max_n_mins_plot(:,2));
max_n_mins_plot = max_n_mins_plot(idx,:);


% separate the max and mins again using ID of 0 (min) or 1 (max)
% maxima
maxima = max_n_mins_plot;
for j=1:size(maxima,1)
    if maxima(j,3) == 0
        maxima(j,:) = [0 0 0];
    end
end
% Remove rows with all zeros so that you're left with only maximas.
maxima( ~any(maxima,2), : ) = [];
% Make the maxima positive values.
maxima = abs(maxima);



% separate the max and mins again using ID of 0 (min) or 1 (max)
% minima
minima = max_n_mins_plot;
for j=1:size(minima,1)
    if minima(j,3) == 1
        minima(j,:) = [0 0 0];
    end
end
% Remove rows with all zeros so that you're left with only maximas.
minima( ~any(minima,2), : ) = [];



%% If maxima or minima are near the end of the range of x-values, remove.
% This is because the smooth function is not accurate toward the beginning, so
% it's best to choose maxima and minima in the second cycle for these
% points.

for u=1:size(maxima,1);
    if maxima(u,1) < 0.1*max(x) || maxima(u,1) > (max(x)/2)+0.15*max(x)
        maxima(u,:) = [0 0 0];
    end
end
% Remove rows with all zeros so that you're left with only maximas.
maxima( ~any(maxima,2), : ) = [];

for u=1:size(minima,1);
    if minima(u,1) < 0.1*max(x) || minima(u,1) > (max(x)/2)+0.15*max(x)
        minima(u,:) = [0 0 0];
    end
end
% Remove rows with all zeros so that you're left with only maximas.
minima( ~any(minima,2), : ) = [];



%% Remove redundancies in maxima again...
% since they are in order from greatest to smallest in col 1, you can compare 
% neighbor values to each other
% basically says that if the y-values of the maxima are almost equal AND
% the x-values are at the same point in the cycle, delete one of them
% because it is a duplicate.
% for u=1:size(maxima,1)-1;
%     if ismembertol(maxima(u,2), maxima(u+1,2), 0.05) == 1 & ismembertol(maxima(u,1), maxima(u+1,1)+(numel(x)/2), 0.05) == 1;;
%         maxima(u+1,:) = [0 0 0];
%     else
%     end
% end
% Remove rows with all zeros so that you're left with only maximas.
maxima( ~any(maxima,2), : ) = [];



%% Remove redundancies in minima again...
% since they are in order from greatest to smallest in col 1, you can compare 
% neighbor values to each other
% basically says that if the y-values of the maxima are almost equal AND
% the x-values are at the same point in the cycle, delete one of them
% because it is a duplicate.

% for u=1:size(minima,1)-1;
%      if ismembertol(minima(u,2), minima(u+1,2), 0.05) == 1 && ismembertol(minima(u,1), minima(u+1,1)+(numel(x)/2), 0.05) == 1;
%         minima(u+1,:) = [0 0 0];
%     else
%     end
% end
% Remove rows with all zeros so that you're left with only maximas.
minima( ~any(minima,2), : ) = [];



%% Plot the maxima and minima.

%%%%%%%%%%%%%%%%%% REMOVE COMMENTS IF YOU WANT TO PLOT
%%%%%%%%%%%%%%%%%%hold on
%%%%%%%%%%%%%%%%%%plot(maxima(:,1), maxima(:,2),'g^','MarkerSize',10)
%%%%%%%%%%%%%%%%%%hold on
%%%%%%%%%%%%%%%%%%plot(minima(:,1), minima(:,2),'c^','MarkerSize',10)

%output them so you can see how many there are.
%maxima;
%minima;


%% Cell features

% Area calculated by regionprops function of Matlab
Area_regionprops = st.Area;

P_regionprops = st.Perimeter;



%% Shape attributes/features.

% Attributes are as follows...
% THESE FIRST FOUR HAVE NOT WORKED WELL FOR ME - DELETE THEM BEFORE
% CLUSTERING.
% 1) relative standard deviation of maximums
% 2) relative standard deviation of minimums
% 3) ratio of maximum distance from centroid to shape area
% 4) relative standard deviation of all distances
% THESE LAST 6 ARE GOOD.
% 5) ratio of maximum distance from centroid to shape perimeter
% 6) raio of shape area to shape perimeter
% 7) standard deviation of maxima and minima ******* CHANGE TO RELATIVE???****
% 8) number of maxima
% 9) number of minima
% 10) ratio of major axis length to perimeter

x_i1 = std(maxima(:,2))/median(maxima(:,2));
x_i2 = std(minima(:,2))/median(minima(:,2));
x_i3 = (max(-1.*mags) - min(-1.*mags))/Area_regionprops;
x_i4 = std(mags)/median(mags);
x_i5 = (max(-1.*mags) - min(-1.*mags))/P_regionprops;
x_i6 = Area_regionprops/P_regionprops;
x_i7 = std(max_n_mins(:,2));
x_i8 = size(maxima,1);
x_i9 = size(minima, 1);
x_i10 = st.MajorAxisLength/st.Perimeter;


% Fill the attribues matrix.  Use the first attribute as the cell ID.  This
% assumes the script starts with i=1.  Change this if needed. 
attributes(1, t) = i;
attributes(2, t) = x_i1;
attributes(3, t) = x_i2;
attributes(4, t) = x_i3;
attributes(5, t) = x_i4;
attributes(6, t) = x_i5;
attributes(7, t) = x_i6;
attributes(8, t) = x_i7;
attributes(9, t) = x_i8;
attributes(10, t) = x_i9;
attributes(11, t) = x_i10;

sumy = sum2_outline/st.Area;
perim_Area = st.Perimeter/st.Area;
st.Perimeter;
st.Area;


% This part is in the case that the cell is too small or large (add code to
% identify irregular or unrealistic shapes later), it does not calculate
% attributes and is later eliminated from the matrix.
else 
    %disp('Cell is too small, large, or irregular to calculate attributes. Zeros fill attributes matrix.')
attributes(1, t) = i;
attributes(2, t) = 0;
attributes(3, t) = 0;
attributes(4, t) = 0;
attributes(5, t) = 0;
attributes(6, t) = 0;
attributes(7, t) = 0;
attributes(8, t) = 0;
attributes(9, t) = 0;
attributes(10, t) = 0;
attributes(11, t) = 0;
end

% Add 1 so that the element # is a placeholder for the next cell.
t = t+1;

end



% Output attributes at the end if you like.
%attributes;

% Get rid of any of the cells that were not calculated (yield all zeros in
% the column except for the cell ID).

for tt = 1:size(attributes,2)
  if attributes(2:11, tt) == [0; 0; 0; 0; 0; 0; 0; 0; 0; 0;];
      attributes(:, tt) = [0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0;];
  end
end

attributes( :, ~any(attributes,1) ) = [];
attributes=attributes';

%% Create a file with the feature data.
%dlmwrite('CellSegFinal010_data.txt', attributes,'delimiter','\t','precision',10)
























%% Eliot's BBoxCalc function
% Given binary image of object, returns coordinates of bounding box with
%%buffer zone
%input=binary image of object
%output=coordinates for cropped version with buffer

% function BBox=BBoxCalc(tempobject)
% 
% sMask=size(tempobject);
% 
% %get bounding box
% BBox=regionprops(tempobject,'BoundingBox');
%     BBox=BBox.BoundingBox;
% 
%     %format bounding box
% buffer=7;
% BBox(1)=round(BBox(1)-buffer); %X1
% BBox(2)=round(BBox(2)-buffer); %Y1
% BBox(3)=round(BBox(1)+BBox(3)+ 2*buffer); %X2
% BBox(4)=round(BBox(2)+BBox(4)+2*buffer); %Y2
% 
% %if BBox goes off image, set to image edge
% BBox(BBox<1)=1;
% 
% if(BBox(3)>sMask(2))
%     BBox(3)=sMask(2);
% end
% 
% if(BBox(4)>sMask(1))
%     BBox(4)=sMask(1);
% end
% 
% end