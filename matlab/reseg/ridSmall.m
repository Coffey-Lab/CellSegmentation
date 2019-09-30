% inputs
%k3= cell mask
%nuc= nuclear mask

%outputs
% k4 = area > 50 and has nuclei cell_mask.

function k4 = ridSmall(k3,nuc)
L=bwlabel(k3,4);
area=regionprops(L,nuc,'MeanIntensity','Area');
Intensities=transpose(cell2mat({area.MeanIntensity}));
Areas=transpose(cell2mat({area.Area}));
Intensities (find(Areas<=50))=0;

keep=find(Intensities>0);
keep=keep';
%k4=selectobjects(keep,L);
k4=ismember(L,keep).*L;

end

