function [Stats, NoOvlp]=MxIF_quantify(i, WatCellSeg, AFRemoved, AFList, PosList, mask, MemMask, tumorMask, OutPos)
% Funtion to quantify AFRemoved images
%inputs:
%WatCellSeg= cell segmenation
%AFRemoved

%set up cells
        
        Stats=struct2table(regionprops(WatCellSeg, { 'Centroid' ,'Area'})); %get morphometrics for cell
        C=array2table(Stats.Centroid);
        if isempty(C)
            fprintf('Skipping Quantification. No Cell Seg File\n')
            return
        end
        Stats=[C(:,1) C(:,2) Stats(:,1)];
        clear C
        Stats.Properties.VariableNames={'Cell_Centroid_X' 'Cell_Centroid_Y' 'Cell_Area'};
        ID=struct2table(regionprops(WatCellSeg, WatCellSeg, { 'PixelValues'}));       
        ID=table(cellfun(@nanmedian, ID{:,1}));
        ID.Properties.VariableNames={'ID'}; %rename table variable
        Position=array2table(ones(height(ID),1)*str2num(strrep(OutPos{i},'pyr16_spot_','' )));
        Position.Properties.VariableNames={'Pos'}; %rename table variable
        Stats=[ID Position Stats]; %add ID to Stats table
        Stats=sortrows(Stats,1);
        
        %shapes=shape_determination(WatCellSeg);
        
        s=size(WatCellSeg);
        NoOvlp=zeros(s(1), s(2), 3);
        
        for j = 1:length(AFList) %quantify each marker
            fprintf([AFList{j} ' '])
            AFim=imread([AFRemoved AFList{j} '_AFRemoved_' PosList{i} '.tif']); %read biomarker image
            AForig=AFim;
            %Quantify whole cell stats
            %ID=struct2table(regionpropsETM(WatCellSeg, WatCellSeg, { 'MedianIntensity'}));
            AFQuantCell= struct2table(regionprops(WatCellSeg, AFim, { 'PixelValues' }));
            AFQuantCell=table(cellfun(@nanmedian, AFQuantCell{:,1}));
            AFQuantCell.Properties.VariableNames={['Median_Cell_' AFList{j}]};
            AFQuantCell=[ID AFQuantCell];
            AFQuantCell=sortrows(AFQuantCell,1);
            AFQuantCell=AFQuantCell(:,2);
            %Stats=[Stats AFQuant(:,2)];
            
            %quantify nuclear stats
            AFim=double(AForig); %get only nuclear signal
            AFim(mask==0)=nan;
            %CellID=WatCellSeg.*uint16(nucmask); %get regions only in nuc
            %imwrite(AFim, [OutDir 'AFNuc_' AFList{j} '_' PosList{i} '.tif'] ) %write 16 bit tiff
            %AFim(AFim==0)=nan;
            %ID= struct2table(regionpropsETM(WatCellSeg, WatCellSeg, { 'MedianIntensity'}));
            if j==1 %for first marker
                
                Area=struct2table(regionprops(WatCellSeg, mask, { 'PixelValues'}));
                Area=table(cellfun(@nansum, Area{:,1}));
                Area.Properties.VariableNames={'Nuc_Area'};
                Area=[ID Area];
                Area=sortrows(Area,1);
                Stats=[Stats Area(:,2)];
            end
            
            AFQuantNuc= struct2table(regionprops(WatCellSeg, AFim, { 'PixelValues' }));
            AFQuantNuc=table(cellfun(@nanmedian, AFQuantNuc{:,1}));
            AFQuantNuc.Properties.VariableNames={['Median_Nuc_' AFList{j}]};
            AFQuantNuc=[ID AFQuantNuc];
            AFQuantNuc=sortrows(AFQuantNuc,1);
            AFQuantNuc=AFQuantNuc(:,2);
            %Stats=[Stats AFQuant(:,2)];
            
            
            %quantify cell edge (mem) stats
            AFim=double(AForig); %get only non-nuclear signal
            MemMask=WatCellSeg==0;
            
            disksize=5;
            %if pixadj>1
            %    disksize=ceil(5*pixadj/1.5);
            %end
            
            MemMask=imdilate(MemMask,strel('square',disksize));
            MemMask(WatCellSeg==0)=0;
            MemMask(mask==1)=0;
            AFim(MemMask==0)=nan;
            %imwrite(AFim, [OutDir 'AFNuc_' AFList{j} '_' PosList{i} '.tif'] ) %write 16 bit tiff
            %AFim(AFim==0)=nan;
            %ID= struct2table(regionpropsETM(WatCellSeg, WatCellSeg, { 'MedianIntensity'}));
            if j==1 %for first marker
                
                Area=struct2table(regionprops(WatCellSeg, MemMask, { 'PixelValues'}));
                Area=table(cellfun(@nansum, Area{:,1}));
                Area.Properties.VariableNames={'Mem_Area'};
                Area=[ID Area];
                Area=sortrows(Area,1);
                Stats=[Stats Area(:,2)];
            end
            
            AFQuantMem= struct2table(regionprops(WatCellSeg, AFim, { 'PixelValues' }));
            AFQuantMem=table(cellfun(@nanmedian, AFQuantMem{:,1}));
            AFQuantMem.Properties.VariableNames={['Median_Mem_' AFList{j}]};
            AFQuantMem=[ID AFQuantMem];
            AFQuantMem=sortrows(AFQuantMem,1);
            AFQuantMem=AFQuantMem(:,2);
            %Stats=[Stats AFQuant(:,2)];
            
            
            
            %quantify non nuclear and non mem (cyt) stats
            AFim=double(AForig); %get only non-nuclear signal
            CytMask=WatCellSeg>0 & mask==0 & MemMask==0;
            AFim(CytMask==0)=nan;
            %imwrite(AFim, [OutDir 'AFNuc_' AFList{j} '_' PosList{i} '.tif'] ) %write 16 bit tiff
            %AFim(AFim==0)=nan;
            %ID= struct2table(regionpropsETM(WatCellSeg, WatCellSeg, { 'MedianIntensity'}));
            if j==1 %for first marker
                
                Area=struct2table(regionprops(WatCellSeg, CytMask, { 'PixelValues'}));
                Area=table(cellfun(@nansum, Area{:,1}));
                Area.Properties.VariableNames={'Cyt_Area'};
                Area=[ID Area];
                Area=sortrows(Area,1);
                Stats=[Stats Area(:,2)];
            end
            
            AFQuantCyt= struct2table(regionprops(WatCellSeg, AFim, { 'PixelValues' }));
            AFQuantCyt=table(cellfun(@nanmedian, AFQuantCyt{:,1}));
            AFQuantCyt.Properties.VariableNames={['Median_Cyt_' AFList{j}]};
            AFQuantCyt=[ID AFQuantCyt];
            AFQuantCyt=sortrows(AFQuantCyt,1);
            AFQuantCyt=AFQuantCyt(:,2);
            
            Stats=[Stats AFQuantCell AFQuantNuc AFQuantMem AFQuantCyt];
            
            
            
            
        end
        
        if ~isempty(tumorMask)
            tumQuantCell= struct2table(regionprops(WatCellSeg, tumorMask, { 'PixelValues' }));
            tumQuantCell=table(cellfun(@nanmedian, tumQuantCell{:,1}));
            tumQuantCell.Properties.VariableNames={['Tumor']};
            tumQuantCell=[ID tumQuantCell];
            tumQuantCell=sortrows(tumQuantCell,1);
            tumQuantCell=tumQuantCell(:,2);
            Stats=[Stats tumQuantCell];
        end
        %get pixels on edges of watcellseg
        CellBorders=imdilate(WatCellSeg>0, ones(3,3)) & ~WatCellSeg>0;
        
        %create NoOvlpImages
        NoOvlp(:,:,1)=MemMask+CellBorders;%.*epiMask;
        NoOvlp(:,:,2)=CytMask+CellBorders;%.*epiMask;
        NoOvlp(:,:,3)=mask+CellBorders;%.*epiMask;
        
        
        
        
    end