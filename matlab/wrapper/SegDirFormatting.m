function [AFRemoved, DAPI, OutDir]=SegDirFormatting(SlideDir)
%SegDirFormatting Create and format data structure of single cell
%segmentation
%Inputs:
%SlideDir= directory for slide containing AFRemoved images folder and
%Registered images folder - assumes Round 001 is baseline and all fies are
%tif format
%
%Outputs
%AFRemoved= string for location of AFRemoved images
%DAPI=string for location of DAPI images
%OutDir= cell array of strings for the output files

if isunix   %if mac use '/'
    
    AFRemoved=[SlideDir '/AFRemoved/'];
    
    DAPI=[SlideDir '/RegisteredImages/S001/'];
    
    
    
    
    % check if various output directories exist and create them if not
    if ~exist([SlideDir '/SegQuant'], 'dir')
        mkdir([SlideDir '/SegQuant']);
    end
    
    if ~exist([SlideDir '/SegQuant/Stacks'], 'dir')
        mkdir([SlideDir '/SegQuant/Stacks']);
    end
    
    
    if ~exist([SlideDir '/SegQuant/CellSeg'], 'dir')
        mkdir([SlideDir '/SegQuant/CellSeg']);
    end
    
    if ~exist([SlideDir '/SegQuant/CellSegFinal'], 'dir')
        mkdir([SlideDir '/SegQuant/CellSegFinal']);
    end
    
    if ~exist([SlideDir '/SegQuant/EpiMask'], 'dir')
        mkdir([SlideDir '/SegQuant/EpiMask']);
        
    end
    if ~exist([SlideDir '/SegQuant/Novlp'], 'dir')
        mkdir([SlideDir '/SegQuant/Novlp']);
        
    end
    if ~exist([SlideDir '/SegQuant/NucMask'], 'dir')
        mkdir([SlideDir '/SegQuant/NucMask']);
        
    end
    
    if ~exist([SlideDir '/SegQuant/SuperMem'], 'dir')
        mkdir([SlideDir '/SegQuant/SuperMem']);
        
    end
    
    if ~exist([SlideDir '/SegQuant/MemMask'], 'dir')
        mkdir([SlideDir '/SegQuant/MemMask']);
        
    end
    if ~exist([SlideDir '/SegQuant/NucMaskFinal'], 'dir')
        mkdir([SlideDir '/SegQuant/NucMaskFinal']);
        
    end
    if ~exist([SlideDir '/SegQuant/PosStats'], 'dir')
        mkdir([SlideDir '/SegQuant/PosStats']);
        
    end
    
    if ~exist([SlideDir '/SegQuant/ML'], 'dir')
        mkdir([SlideDir '/SegQuant/ML']);
        
    end
    
    if ~exist([SlideDir '/SegQuant/TumorMask'], 'dir')
        mkdir([SlideDir '/SegQuant/TumorMask']);
    end
    
    if ~exist([SlideDir '/SegQuant/CellShape'], 'dir')
        mkdir([SlideDir '/SegQuant/CellShape']);
    end
    
    %load the OutDir cell array
    OutDir{1}=[SlideDir '/SegQuant/CellSeg/'];
    OutDir{2}=[SlideDir '/SegQuant/CellSegMask/'];
    OutDir{3}=[SlideDir '/SegQuant/EpiMask/'];
    OutDir{4}=[SlideDir '/SegQuant/Novlp/'];
    OutDir{5}=[SlideDir '/SegQuant/NucMask/'];
    OutDir{6}=[SlideDir '/SegQuant/NucSeg/'];
    OutDir{7}=[SlideDir '/SegQuant/SuperMem/'];
    OutDir{8}=[SlideDir '/SegQuant/'];
    OutDir{9}=[SlideDir '/SegQuant/AFMask/'];
    OutDir{10}=[SlideDir '/SegQuant/MemMask/'];
    OutDir{11}=[SlideDir '/SegQuant/NucMaskFinal/'];
    OutDir{12}=[SlideDir '/SegQuant/CellSegFinal/'];
    OutDir{13}=[SlideDir '/SegQuant/PosStats/'];
    OutDir{14}=[SlideDir '/SegQuant/ML/'];
    OutDir{15}=[SlideDir '/SegQuant/Stacks/'];
    OutDir{16}=[SlideDir '/SegQuant/TumorMask/'];
    OutDir{17}=[SlideDir '/SegQuant/CellShape/'];
    
elseif ispc %if pc use '\'
    
    AFRemoved=[SlideDir '\AFRemoved\'];
    
    DAPI=[SlideDir '\RegisteredImages\S001\'];
    
    % check if various output directories exist and create them if not
    if ~exist([SlideDir '\SegQuant'], 'dir')
        mkdir([SlideDir '\SegQuant']);
    end
    if ~exist([SlideDir '\SegQuant\CellSeg'], 'dir')
        mkdir([SlideDir '\SegQuant\CellSeg']);
        
    end
    if ~exist([SlideDir '\SegQuant\CellSegFinal'], 'dir')
        mkdir([SlideDir '\SegQuant\CellSegFinal']);
        
    end
    
    if ~exist([SlideDir '\SegQuant\EpiMask'], 'dir')
        mkdir([SlideDir '\SegQuant\EpiMask']);
        
    end
    if ~exist([SlideDir '\SegQuant\Novlp'], 'dir')
        mkdir([SlideDir '\SegQuant\Novlp']);
        
    end
    if ~exist([SlideDir '\SegQuant\NucMask'], 'dir')
        mkdir([SlideDir '\SegQuant\NucMask']);
        
    end
    
    if ~exist([SlideDir '\SegQuant\SuperMem'], 'dir')
        mkdir([SlideDir '\SegQuant\SuperMem']);
        
    end
    
    if ~exist([SlideDir '\SegQuant\MemMask'], 'dir')
        mkdir([SlideDir '\SegQuant\MemMask']);
        
    end
    if ~exist([SlideDir '\SegQuant\NucMaskFinal'], 'dir')
        mkdir([SlideDir '\SegQuant\NucMaskFinal']);
        
    end
    if ~exist([SlideDir '\SegQuant\PosStats'], 'dir')
        mkdir([SlideDir '\SegQuant\PosStats']);
        
    end
    
    if ~exist([SlideDir '\SegQuant\ML'], 'dir')
        mkdir([SlideDir '\SegQuant\ML']);
        
    end
    
    if ~exist([SlideDir '\SegQuant\TumorMask'], 'dir')
        mkdir([SlideDir '\SegQuant\TumorMask']);
        
    end
    
     if ~exist([SlideDir '\SegQuant\Stacks'], 'dir')
        mkdir([SlideDir '\SegQuant\Stacks']);
        
     end
    
     if ~exist([SlideDir '\SegQuant\CellShape'], 'dir')
        mkdir([SlideDir '\SegQuant\CellShape']);
    end
     
    %load the OutDir cell array
    OutDir{1}=[SlideDir '\SegQuant\CellSeg\'];
    OutDir{2}=[SlideDir '\SegQuant\CellSegMask\'];
    OutDir{3}=[SlideDir '\SegQuant\EpiMask\'];
    OutDir{4}=[SlideDir '\SegQuant\Novlp\'];
    OutDir{5}=[SlideDir '\SegQuant\NucMask\'];
    OutDir{6}=[SlideDir '\SegQuant\NucSeg\'];
    OutDir{7}=[SlideDir '\SegQuant\SuperMem\'];
    OutDir{8}=[SlideDir '\SegQuant\'];
    OutDir{9}=[SlideDir '\SegQuant\AFMask\'];
    OutDir{10}=[SlideDir '\SegQuant\MemMask'];
    OutDir{11}=[SlideDir '\SegQuant\NucMaskFinal'];
    OutDir{12}=[SlideDir '\SegQuant\CellSegFinal\'];
    OutDir{13}=[SlideDir '\SegQuant\PosStats\'];
    OutDir{14}=[SlideDir '\SegQuant\ML\'];
    OutDir{15}=[SlideDir '\SegQuant\Stacks\'];
    OutDir{14}=[SlideDir '\SegQuant\TumorMask\'];
    OutDir{17}=[SlideDir '\SegQuant\CellShape\'];
end


