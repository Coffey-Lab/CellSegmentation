%%
% inputs 
% B=boundary on all objects
% L=cell_mask on all objects
% outputs
% metric_a- array of circular object metrics (1= circle)

function [ metric_a ] = calculate_metric(B,L)
stats = regionprops(L,'Area');
 metric_a=[];

for k = 1:length(B)
 
   % obtain (X,Y) boundary coordinates corresponding to label 'k'
   boundary = B{k};
 
   % compute a simple estimate of the object's perimeter
   delta_sq = diff(boundary).^2;    
   perimeter = sum(sqrt(sum(delta_sq,2)));
   
   % obtain the area calculation corresponding to label 'k'
   area = stats(k).Area;
   
   % compute the roundness metric
   metric = 4*pi*area/perimeter^2;
    % store in array   
   metric_a(k)=metric;
   
 end

end

