function [ filtMask ] = MaskFiltration( mask , low )

s  = regionprops(mask,'Area');
area = cat(1, s.Area);

filtMask = bwareafilt(mask,[min(area)+low*(max(area-min(area))) max(area)]);

end

