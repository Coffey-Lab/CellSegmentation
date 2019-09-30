%function resegmuc2Nuc_quant_cell_olympus_ML(SlideDir, NucList, MemList, EpiList , StromaList, quantify, unsharp, start)



warning off

SlideDir='/Users/etmckinley/Dropbox (VUMC)/scan_alpha/TCPS4A';

%if no directory is supplied ask for user input
if isempty(SlideDir)
    SlideDir=uigetdir;
end

% get formatting for AFRemoved, DAPI, and output directories
[AFRemoved, DAPI, OutDir]=SegDirFormatting(SlideDir);

%get AFremoved images
AFList=dir([AFRemoved '*.tif']);
AFList={AFList.name};
AFList=regexp(AFList, '_AFRemoved_pyr16_spot_', 'split'); %split characters before and after delimiter
AFList=cat(3,AFList{:}); %reorganize cell
PosList=squeeze(AFList(1,2,:)); %get positions with .tif
AFList=unique(squeeze(AFList(1,1,:))); %get only the Marker names
PosList=unique(regexprep(PosList,'.tif',''));  %get only the positions
OutPos=PosList; %format for output position

%get DAPI images from first round of imaging (assumes Olympus)
DapiList=dir([DAPI '*_dapi.tif']);
DapiList={DapiList.name};
DapiList=strcat(DAPI ,DapiList); %add in path

% Format DAPI images for Cytell based imaging
if isempty(DapiList)
    DapiList=dir([DAPI '*_dapi_*.tif' ]);
    DapiList={DapiList.name};
    DapiList=strcat(DAPI ,DapiList); %add in path
    OutPos=strrep(PosList,'pyr16_spot_',''); %format for output position in cytell images
end



%make sure that the number of DAPI images equals number of poisitons
if length(DapiList) ~= length(PosList)
    error('Dapi Image Mismatch');
end


%% Segmentation and Quantification for each position
for i= 39:length(PosList)
    fprintf([OutPos{i} '\n'])
    %DapiImg=imread(DapiList{i});
    DapiIm=imread(DapiList{i});
    [s1 s2]=size(DapiIm);
    crop=ceil([s1/2-1048 s2/2-1048 1047 1047]);
    
    imwrite(imcrop(imread(DapiList{i}), crop), [SlideDir '/Stacks/' OutPos{i} '_stack_crop.tif'], 'Compression', 'lzw');
    %[s1 s2]=size(DapiImg);
    %stack=zeros(s1, s2, length(AFList)+1);
    %stack(:, :, 1)=DapiImg;
    for j=1:(length(AFList))
        %stack(:,:,j+1)=imread([SlideDir '/AFRemoved/' AFList{j} '_AFRemoved_'  OutPos{i} '.tif']);
        imwrite(imcrop(imread([SlideDir '/AFRemoved/' AFList{j} '_AFRemoved_pyr16_spot_'  OutPos{i} '.tif']),crop), [SlideDir '/Stacks/' OutPos{i} '_stack_crop.tif'], 'writemode', 'append', 'Compression', 'lzw');
        
    end
    
    %imwrite(stack(:,:,1), [SlideDir '/Stacks/' OutPos{i} '_stack.tif'])
    
    %imwrite(rgb2gray(a), [SlideDir '/Stacks/' OutPos{i} '_stack.tif'], 'writemode', 'append')
    
    %t = Tiff([SlideDir '/Stacks/' OutPos{i} '_stack.tif'], 'w');
    %t.write(stack)
    
    %imwrite(stack, [SlideDir '/Stacks/' OutPos{i} '_stack.tif'])
end
%end