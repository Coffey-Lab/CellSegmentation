% inputs
% mem= cell_mask
% nuc=nuc_mask
% outputs
% k2= mask of objects with great than 1 nuc




function k2=multiNuc(mem, nuc)
memBW = im2bw(mem);
nuc=im2bw(nuc);
memL = bwlabel(memBW, 4); %labels each object in the cell_mask                


nucL=nuc.*memL;

area=regionprops(nuc,nucL,'Area','MaxIntensity');

area2=area(cell2mat({area.Area})'>=18);
area2=area2(cell2mat({area2.MaxIntensity})'>0);

if isempty(cell2mat({area2.MaxIntensity}))
    k2=zeros(size(mem));
    return
end

uniqueX = unique(cell2mat({area2.MaxIntensity}));
countOfX = hist(cell2mat({area2.MaxIntensity}),uniqueX);


indexToRepeatedValue = (countOfX~=1);

%check if there is only one value
if length(indexToRepeatedValue)==2
    repeatedValues=uniqueX(indexToRepeatedValue(2));
else
    repeatedValues = uniqueX(indexToRepeatedValue);
end


% 
% a = [];
% counter = 0;
% 
% num=max(max(memL));
% objects=[];
% for i=1:num
%     
%     temp=(memL==i);
%     
%     % nuclei in one object
%     tempnuc=temp.*nuc;
%     L2=bwlabel(tempnuc,4);
%     area=regionprops(L2,'Area');
%     Areas=transpose(cell2mat({area.Area}));
%     
%     % the nuclei has to be > 18 in area
%     num5=find(Areas>=18);
%     
%     
%     [rr cc]=size(num5);
%     
%     % store number of obects in array
%     objects(i)=rr;
% end
% 
% k=find (objects>1);
% %k2 = selectobjects(k, memL);
% k2=ismember(memL,k).*memL;
k2=ismember(memL,repeatedValues).*memL;
end