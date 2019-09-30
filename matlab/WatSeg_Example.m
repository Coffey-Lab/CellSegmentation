warning off
clear all
close all

dir='/Users/etmckinley/Dropbox (VUMC)/Research/Manuscripts/Cell Segmentation/Example MxIF Data';
CellSegQuant(dir ,1,1,1,0, 1)

% 
%   dir='/Users/etmckinley/Dropbox (VUMC)/EBC_GE/Processed Data/077700001001/Example Data';
%   nuc={'PCNA' 'pHistoneH3' 'Survivin'};
%   mem={'BetaCatenin' 'NaKATPase' 'CD44V6' 'VILLIN' 'CKPCK26' 'CK20' 'E_cad' 'PCAD'};
%   epi={'CKPCK26' 'BetaCatenin'  'CD44V6'};
% 
%   resegmuc2Nuc_quant_cell_cytell(dir,nuc, mem, epi ,1,0)
% dir='/Users/etmckinley/Dropbox (VUMC)/scan_alpha/150000602093';
% 
% dir='/Users/etmckinley/Dropbox (VUMC)/Functions/ETM/2093 test2';
% nuc={'PCNA'};
% mem={'BCAT' 'ECAD' 'NAKATPASE' 'VILLIN'};
% epi={'BCAT' 'ECAD' 'NAKATPASE' 'VILLIN'};


% dir='/Users/etmckinley/Dropbox (VUMC)/EBC_GE/Processed Data/077700001000';
% nuc={'PCNA' 'pHistoneH3' 'Survivin'};
% mem={'BetaCatenin' 'NaKATPase' 'CD44V6' 'VILLIN' 'E_cad' 'CKPCK26' };
% epi={'CKPCK26' 'BetaCatenin'  'CD44V6' 'CK20' 'Muc2' 'E_cad'};



%  dir='/Users/etmckinley/Dropbox (VUMC)/EBC_GE/Processed Data/077700001000';
%  nuc={'PCNA' 'pHistoneH3' 'Survivin'};
%  mem={'BetaCatenin' 'NaKATPase' 'CD44V6' 'VILLIN' };
% %  epi={'CKPCK26' 'BetaCatenin'  'CD44V6' };
% % % 

   % slides=150000602123:150000602136;

    %dir='/Users/etmckinley/Dropbox (VUMC)/EBC_GE/Processed Data/077700001001';
    %dir='/Users/etmckinley/Dropbox (VUMC)/scan_alpha/150000602123';
    % dir='/Users/etmckinley/Dropbox (VUMC)/scan_alpha/150000602124';
%dir='/Users/etmckinley/Dropbox (VUMC)/scan_alpha/150000602125';
 
     %dir='/Users/etmckinley/Dropbox (VUMC)/scan_alpha/150000602126';
      %dir='/Users/etmckinley/Dropbox (VUMC)/scan_alpha/150000602127';
      %dir='/Users/etmckinley/Dropbox (VUMC)/scan_alpha/150000602128';
     % dir='/Users/etmckinley/Dropbox (VUMC)/scan_alpha/150000602129';
     % dir='/Users/etmckinley/Dropbox (VUMC)/scan_alpha/150000602130';
     % dir='/Users/etmckinley/Dropbox (VUMC)/scan_alpha/150000602131';
    % dir='/Users/etmckinley/Dropbox (VUMC)/scan_alpha/150000602132';
     % dir='/Users/etmckinley/Dropbox (VUMC)/scan_alpha/150000602133';
    % dir='/Users/etmckinley/Dropbox (VUMC)/scan_alpha/150000602134';
      %dir='/Users/etmckinley/Dropbox (VUMC)/scan_alpha/150000602135';
     %dir='/Users/etmckinley/Dropbox (VUMC)/scan_alpha/150000602136';
     
     %dir='/Users/etmckinley/Dropbox (VUMC)/scan_alpha/150000602123';
   % resegmuc2Nuc_quant_cell_olympus_ML_IL_str(dir,1,1, 1)
  % for i=1:length(slides)
  %     dir=['/Users/etmckinley/Dropbox (VUMC)/scan_alpha/' num2str(slides(i))];
  %     CellSegQuant(dir ,1,0,1, 1)
  % end
   
  %dir='/Users/etmckinley/Dropbox (VUMC)/scan_alpha/H714_tumor';
  %CellSegQuant(dir ,1,0,0, 1)
   
   %resegmuc2Nuc_quant_cell_olympus_ML_IL_str(dir ,1,0, 1)
%        nuc={'SURVIVN' 'SOX9'};
% % % % % 
%      mem={'BCAT' 'NAKATPASE' 'CD44V6'  'PCK26'};
%       epi={'BCAT' 'CD44V6' 'PCK26'  'Muc2' 'NKCC' };
%       str={'VIM'};
      
%       resegmuc2Nuc_quant_cell_olympus_ML(dir,nuc, mem, epi , str, 1,0,1)

%      resegmuc2Nuc_quant_cell_olympus_ML_IL(dir,nuc, mem, epi ,1, 1)
% % %  
% % %pctRunOnAll warning off   
% resegmuc2Nuc_quant_cell_olympus_ML(dir,nuc, mem, epi , str, 1,0,1)
%resegmuc2Nuc_quant_cellO(dir,nuc, mem, epi ,1,0)

% % % 
%  resegmuc2Nuc_quant_cell_parallel(dir,nuc, mem, epi ,1,0)

%function 
%seg_quant_cell(SlideDir, NucList, MemList, EpiList ,quantify, unsharp)
%reseg_quant_cell(dir,nuc, mem, epi ,1,1,1)


%
%Parresegmuc2Nuc_quant_cell(dir,nuc, mem, epi ,0,0)



% 

%resegmuc2Nuc_quant_cell_cytell_ML_IL_str(dir,1,1,0, 39)