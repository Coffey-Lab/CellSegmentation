function CellSegQuant(SlideDir, quantify, shape, stroma, tumor, start)
%Eliot McKinley - 2018-11-26
%eliot.mckinley@vumc.org
%
% No returned output - function saves image of objects and quantification
% of AFremoved markers
%
%SlideDir=directory for slide containing AFRemoved images folder and
%Registered images folder - assumes Round 001 is baseline and all fies are
%.tif - if no folder is supplied- then ui asks for directory
%
%quantify= whether or not to quantify 1=yes, 0=no
%
%stroma= whether or not to segment stroma 1= yes, 0-no
%
%start= which image to start processing

%% Custom functions needed
%SegDirFormatting-creates directories to save the output of this function
%blurimg2_batch - finds blurry spots on DAPI images and excludes from analysis
%ML_probability - creates epithelial mask from probability map
%MaskFiltration - filtering for epithelial mask generation
%ReSegCells- generates resegmented cell mask
%NucCountBatch - resegments cells with multiple nuclei- generating new cellmask and nuclear mask
%MxIF_quantify - quantifies marker staining intensity
%stromal_nuclei_segmentation - segments stromal nuclei
%BBoxCalc - get bounding box of cell
%reseg - re-segment cells with internal membranes
%extend - extend line segments on both ends
%intersectfirst - connect line segments
%trimtree - take branches off line segments
%finalconnect_2 - extend from spurs in line
%finalconnect - connect any oustanding endpoint pairs

%% Parse Directory supplied for cell segmentation

%if no directory is supplied ask for user input
if isempty(SlideDir)
    SlideDir=uigetdir;
end

% get formatting for AFRemoved, DAPI, and output directories
[AFRemoved, DAPI, OutDir]=SegDirFormatting(SlideDir);

%get AFRemoved images
AFList=dir([AFRemoved '*.tif']);
AFList={AFList.name};

AF_delimiter='_AFRemoved_'; % the string in between the Marker and position ID
AFList=regexp(AFList, AF_delimiter, 'split'); %split characters before and after delimiter
AFList=cat(3,AFList{:}); %reorganize cell
PosList=squeeze(AFList(1,2,:)); %get positions with .tif
AFList=unique(squeeze(AFList(1,1,:))); %get only the Marker names
PosList=unique(regexprep(PosList,'.tif',''));  %get only the positions
OutPos=PosList; %format for output position

%get DAPI images from first round of imaging
DapiList=dir([DAPI '*_dapi.tif']);
DapiList={DapiList.name};
DapiList=strcat(DAPI ,DapiList); %add in path

% Format DAPI images for Cytell based imaging
if isempty(DapiList)
    DapiList=dir([DAPI '*_dapi_*.tif' ]);
    DapiList={DapiList.name};
    DapiList=strcat(DAPI ,DapiList); %add in path
    %OutPos=strrep(PosList,'pyr16_spot_',''); %format for output position in cytell images
end

%make sure that the number of DAPI images equals number of poisitons
if length(DapiList) ~= length(PosList)
    error('Dapi Image Mismatch');
end

%print status updates to command line
fprintf(['Segmentation of: ' SlideDir ' ; ' num2str(length(PosList)) ' Positions;\n' ])


%% Segmentation and Quantification for each position
for i=start:length(PosList)
    
    fprintf([OutPos{i} ': '])
    tic
    %make Stacks of AFRemoved images and Dapi if they don't exist
    if ~exist([OutDir{15} OutPos{i} '_stack.tif'], 'file')
        
        fprintf(['Stack: ' OutPos{i} '\n'])
        imwrite(imread(DapiList{i}), [OutDir{15} OutPos{i} '_stack.tif'], 'Compression', 'lzw'); %write out DAPI
        for j=1:(length(AFList)) %loop through the AFRemoved images and append to tiff stack
            %imwrite(imread([SlideDir '/AFRemoved/' AFList{j} '_AFRemoved_pyr16_spot_'  OutPos{i} '.tif']), [OutDir{15} OutPos{i} '_stack_all.tif'], 'writemode', 'append', 'Compression', 'lzw');
            imwrite(imread([SlideDir '/AFRemoved/' AFList{j} '_AFRemoved_' OutPos{i} '.tif']), [OutDir{15} OutPos{i} '_stack.tif'], 'writemode', 'append', 'Compression', 'lzw');
            
        end
    end
    
    % Check for Epithelial Probability file from Ilastik
    if ~exist([OutDir{14} 'epi_' OutPos{i} '_stack_Probabilities.png'], 'file')
        fprintf('No Epithelial Probability File\n')
        continue
    end
    
    if ~exist([OutDir{14} 'mem_' OutPos{i} '_stack_Probabilities.png'], 'file')
        fprintf('No Membrane/Nucleus Probability File\n')
        continue
    end
    
    %% nuclear segmentation and generate SuperMembrane and binary Membrane mask
    
    %check to see if files exist; no: generate files ; yes: read saved images
    if ~exist([OutDir{5} 'NucMask_' OutPos{i} '.png'], 'file') || ~exist([OutDir{7} 'SuperMem_' OutPos{i} '.tif'], 'file') || ~exist([OutDir{10} 'MemMask_' OutPos{i} '.png'], 'file')
        %Read in probability image for membrane and nucleus
        Probs=imread([OutDir{14} 'mem_' OutPos{i} '_stack_Probabilities.png']);
        
        
        mask=uint8(255*(Probs(:,:,2)>255*.6)); %set nuclear probability >0.6 as nuclear mask
        imwrite(mask, [OutDir{5} 'NucMask_' OutPos{i} '.png'] )
        imwrite(Probs(:,:,1), [OutDir{7} 'SuperMem_' OutPos{i} '.tif'] ) %write 16 bit tiff
        imwrite(uint8(255*(Probs(:,:,1)>255*.6)), [OutDir{10} 'MemMask_' OutPos{i} '.png'] ) %write 16 bit tiff
        MemMask=im2bw(imread([OutDir{10} 'MemMask_' OutPos{i} '.png']));
        
    else
        %read files if previously generated
        mask=imread( [OutDir{5} 'NucMask_' OutPos{i} '.png']);
        SuperMem=imread( [OutDir{7} 'SuperMem_' OutPos{i} '.tif']);
        MemMask=im2bw(imread([OutDir{10} 'MemMask_' OutPos{i} '.png']));
    end
    
    %make sure nuclear mask in binary
    mask=logical(mask);
    
    %fill in small holes and smooth
    mask=imfill(mask, 'holes');
    mask=imopen(mask, strel('disk',3));
    
    
    %remove blurred nuclear regions
    mask=mask.*blurimg2_batch(imread(DapiList{i}));
    
    %makes sure data is from Olympus, if not adjust constant for kernal
    %sizes in subsequent steps
    s= size(mask);
    pixadj=1;
    if s(1)~=2048 || s(2)~=2048 %check if images is from Cytell ~=2048
        pixadj=3; %adjust for smaller pixel size if Cytell
    end
    
    
    %% generate epithelial mask from machine learning
    
    if~ exist([OutDir{3} 'EpiMask_' OutPos{i} '.png'], 'file')
        fprintf('EpiMask Processing; ')
        
        epiMask=imread([OutDir{14} 'epi_' OutPos{i} '_stack_Probabilities.png']);
        
        epiMask=ML_probability(epiMask,pixadj*0.01, .45); %create epithelial mask from probability map
        imwrite(uint8(255*(epiMask>0)), [OutDir{3} 'EpiMask_' OutPos{i} '.png'] )
        epiMask=logical(imresize(epiMask, size(mask)));
        
    else
        %read file if previously generated
        epiMask=logical(imread([OutDir{3} 'EpiMask_' OutPos{i} '.png']));
        epiMask=logical(imresize(epiMask, size(mask)));
    end
    
    %thin the membrane borders prior to initial watershed
    MemMask=bwmorph(MemMask, 'thin',Inf);
    
    %% generate cell (re)segmentation and nuclear segmentation  images
    %check to see if files exist; no: generate files ; yes: read saved images
    if ~exist([OutDir{12} 'CellSegFinal_' OutPos{i} '.tif'], 'file') || ~exist([OutDir{11} 'NucMaskFinal_' OutPos{i} '.png'], 'file')
        
        fprintf('CellSeg; ')
        
        %check to see if files exist; no: generate files ; yes: read saved images
        if ~exist([OutDir{1} 'L2_' OutPos{i} '.tif'], 'file')
            %if mucLoc is empty, run watershed
            L2=imcomplement (epiMask);
            L2=im2bw(imadd(im2bw(L2),im2bw(MemMask)));
            L2=uint8(L2);
            
            %watershed segmentation with nuclei as basins
            L2 = watershed(imimposemin(L2,mask),4);
            
            L2=double(L2);
            
            % return only those in the epithelial mask
            L2=L2.*epiMask;
            imwrite(uint16(L2), [OutDir{1} 'L2_' OutPos{i} '.tif'] ) %write 16 bit tiff
            
            
        else
            L2=imread( [OutDir{1} 'L2_' OutPos{i} '.tif']);
        end
        
        %check to see if files exist; no: generate files ; yes: read saved images
        if ~exist([OutDir{1} 'CellSeg_' OutPos{i} '.tif'], 'file')
            MemMask=im2bw(imread([OutDir{10} 'MemMask_' OutPos{i} '.png']));
            CellSeg= ReSegCells(L2, MemMask);
            imwrite(uint16(CellSeg), [OutDir{1} 'CellSeg_' OutPos{i} '.tif'] )
        else
            CellSeg=imread( [OutDir{1} 'CellSeg_' OutPos{i} '.tif']);
        end
        %   toc
        
        %check to see if files exist; no: generate files ; yes: read saved images
        if ~exist([OutDir{12} 'CellSegFinal_' OutPos{i} '.tif'], 'file')
            CellSeg=imread( [OutDir{1} 'CellSeg_' OutPos{i} '.tif']);
            SuperMem=imread( [OutDir{7} 'SuperMem_' OutPos{i} '.tif']);
            Probs=imread([OutDir{14} 'mem_' OutPos{i} '_stack_Probabilities.png']);
            %check for cells with multiple nuclei and re-segment if they exist
            [WatCellSeg, mask]=NucCountBatch(CellSeg, mask, epiMask, MemMask, {}, Probs(:,:,2), SuperMem);
            WatCellSeg=im2bw(WatCellSeg);
            
            %fill small crosses
            %WatCellSeg=closesmallholes(WatCellSeg, 4);
            filter=zeros(5,5);
            filter(2,3)=1;
            filter(3,3)=1;
            filter(3,2)=1;
            filter(3,4)=1;
            filter(4,3)=1;
            
            
            hitmiss=bwhitmiss(WatCellSeg, imcomplement(filter));
            spots=bwareaopen(hitmiss,2);
            diff=hitmiss-spots;
            
            diff=conv2(diff, filter, 'same');
            %imshowpair(hitmiss, spots)
            
            WatCellSeg=diff+WatCellSeg;
            
            
            
            %WatCellSeg2= conv2(imcomplement(WatCellSeg),filter, 'same');
            %set non-epithelial pixels to zero
            WatCellSeg(epiMask==0)=0;
            WatCellSeg=logical(WatCellSeg);
            %opening to clean up segmentation
            WatCellSeg=bwareaopen(WatCellSeg,15);
            %label cells
            
            WatCellSeg=bwlabel(WatCellSeg,4);
            %write out data
            imwrite(uint16(WatCellSeg), [OutDir{12} 'CellSegFinal_' OutPos{i} '.tif'] )
            imwrite(uint8(255*(mask>0)), [OutDir{11} 'NucMaskFinal_' OutPos{i} '.png'] )
        else
            %read in data
            WatCellSeg=imread( [OutDir{12} 'CellSegFinal_' OutPos{i} '.tif']);
            mask=logical(imread([OutDir{11} 'NucMaskFinal_' OutPos{i} '.png']));
        end
    else
        WatCellSeg=imread( [OutDir{12} 'CellSegFinal_' OutPos{i} '.tif']);
        mask=logical(imread([OutDir{11} 'NucMaskFinal_' OutPos{i} '.png']));
    end
    
    
    
    
    
    
    
    
    
    %% Quantification performed if specified
    if quantify ==1
        
        
        %check to see if files exist; no: generate files ; yes: read saved files
        if exist([OutDir{13} 'PosStats_' OutPos{i} '.csv'], 'file') && exist([OutDir{4} 'Novlp_' OutPos{i} '.png'], 'file')
            %fprintf('Reading file; ')
            %             Stats=readtable([OutDir{13} 'PosStats_' OutPos{i} '.csv']);
        else
            %skip if the field is empty
            if max(WatCellSeg(:))==0
                fprintf('\n')
                continue
            end
            
            % run quantification
            fprintf('Quant; ')
            
            if tumor==0
                [Stats, NoOvlp]=MxIF_quantify(i, WatCellSeg, AFRemoved, AFList, PosList, mask, MemMask, [], OutPos);
            end
            if tumor==1
                if ~exist([OutDir{14} 'tum_' OutPos{i} '_stack_Probabilities.png'], 'file')
                    fprintf('No Tumor Probability File\n')
                    continue
                end
                if  ~exist([OutDir{16} 'TumorMask_' OutPos{i} '.png'], 'file')
                    [tumorMask,~ , ~]=imread([OutDir{14} 'tum_' OutPos{i} '_stack_Probabilities.png']);
                    
                    %tumorMask=uint8(255*(tumorMask(:,:,1)>255*.5)); %set tumor probability >0.5 as tumor mask
                    tumorMask=ML_probability(tumorMask,pixadj*0.01,.5); %create epithelial mask from probability map
                    if ~exist([OutDir{16} 'TumorMask_' OutPos{i} '.png'], 'file')
                        imwrite(uint8(255*(tumorMask>0)), [OutDir{16} 'TumorMask_' OutPos{i} '.png'] )
                    end
                    
                    [Stats, NoOvlp]=MxIF_quantify(i, WatCellSeg, AFRemoved, AFList, PosList, mask, MemMask, tumorMask, OutPos);
                end
            end
            %format data table and write
            names=cell2table(Stats.Properties.VariableNames);
            writetable(names, [OutDir{13} 'PosStats_' OutPos{i} '.csv'], 'WriteVariableNames', false);
            dlmwrite([OutDir{13} 'PosStats_' OutPos{i} '.csv'], table2array(Stats), '-append');
            imwrite(double(NoOvlp), [OutDir{4} 'Novlp_' OutPos{i} '.png'] )
        end
        
    end
    
    %% Stromal Quantification
    if stroma==1
        
        %check to see if stromal nuclei probability map exists
        if ~exist([OutDir{14} 'str_' OutPos{i} '_stack_Probabilities.png'], 'file')
            fprintf('\nStromal Quant; ')
            fprintf('No Epithelial Probability File\n')
            continue
        end
        %if stats and segmentation already exist, then skip
        if exist([OutDir{13} 'StrPosStats_' OutPos{i} '.csv'], 'file') && exist([OutDir{4} 'StrNovlp_' OutPos{i} '.png'], 'file')
            
        else
            fprintf('\nStromal Quant; ')
            %run function to segment stromal nuclei
            stromal_nuclei=stromal_nuclei_segmentation(imread([OutDir{14} 'str_' OutPos{i} '_stack_Probabilities.png']));
            stromal_nuclei(epiMask==1)=0;
            stromal_grow=imdilate(stromal_nuclei, strel('disk',3)); %dilate nuclei a bit
            
            stromal_label= watershed(imimposemin(uint8(stromal_grow),stromal_nuclei),4); %watershed on dilated cells with nuceli as seed points
            stromal_label(stromal_grow==0)=0; %set all non-cellular pixels to zero
            %write out results
            imwrite(uint16(stromal_label), [OutDir{12} 'StrCellSegFinal_' OutPos{i} '.tif'] )
            imwrite(uint8(255*(stromal_nuclei>0)), [OutDir{11} 'StrNucMaskFinal_' OutPos{i} '.png'] )
            
            %quantify markers in cells and write out data
            [strStats, strNoOvlp]=MxIF_quantify_stroma(i, stromal_label, AFRemoved, AFList, PosList, stromal_nuclei, pixadj, epiMask, OutPos);
            names=cell2table(strStats.Properties.VariableNames);
            writetable(names, [OutDir{13} 'StrPosStats_' OutPos{i} '.csv'], 'WriteVariableNames', false);
            dlmwrite([OutDir{13} 'StrPosStats_' OutPos{i} '.csv'], table2array(strStats), '-append');
            imwrite(double(strNoOvlp), [OutDir{4} 'StrNovlp_' OutPos{i} '.png'] )
        end
        
    end
    
    
    %% Shape Pre-processing
    if shape==1
        %load the final cell segmentation image, extract the cells, and
        %save to .mat file
        if exist([OutDir{12} 'CellSegFinal_' OutPos{i} '.tif'], 'file') && ~exist([OutDir{17} 'CellShape_' OutPos{i} '.mat' ], 'file')
            fprintf('\nCell Shape Pre-Processing; ')
            CellImages=imread([OutDir{12} 'CellSegFinal_' OutPos{i} '.tif']);
            CellImages=cell_shape_images(CellImages);
            save([OutDir{17} 'CellShape_' OutPos{i} '.mat' ], 'CellImages')
        end
        
        %concatenate all the position cell shapes and 
        if i == length(PosList)
            if ~exist([OutDir{17} 'autoencoder.mat'], 'file') && ~exist([OutDir{17} 'encoded_cells.csv'], 'file')
            fprintf('\nTraining Autoencoder; ')
            FileList= dir([OutDir{17} 'CellShape*.mat']);
            
            FileList = fullfile({FileList.folder}.', {FileList.name}.'); 
            
            %run autoencoder with specified percent of training data
            [autoencoder, trainList]=CellShapeAutoencoder(FileList, 0.2);
            
            save([OutDir{17} 'autoencoder.mat'], 'autoencoder')
            writetable(trainList, [OutDir{17} 'encoded_cells.csv']);

            end
            
        end
    end
    fprintf('\n')
end

