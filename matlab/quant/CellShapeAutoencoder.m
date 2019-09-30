function [autoencoder, trainList]=CellShapeAutoencoder(FileList, train_frac)

%concatenate all the cellImages into one array
CellImages=[];
trainList=[];
for iFile = 1:numel(FileList)
  Data  = load([FileList{iFile}]);
  Field = Data.CellImages;
  
  ID=[1:numel(Field)]';
  Pos=repmat(str2num(FileList{iFile}(end-6:end-4)), numel(Field),1 );
  Training=zeros(numel(Field),1); 
  trainList=vertcat(trainList, table(ID, Pos, Training));
  
  CellImages = vertcat(CellImages, Field);
end

index=randsample(1:numel(CellImages), round(train_frac*numel(CellImages)));
trainList.Training(index)=1;

TrainCells=CellImages(index);

hiddenSize = 256;

autoencoder = trainAutoencoder(TrainCells,hiddenSize, ...
    'MaxEpochs',400, ...
    'L2WeightRegularization',0.004, ...
    'SparsityRegularization',4, ...
    'SparsityProportion',0.15, ...
    'ScaleData', false);

feat = encode(autoencoder,CellImages);
feat=single(feat);
feat=array2table(feat', 'VariableNames', strseq('Enc', 1:hiddenSize));

trainList=[trainList feat];


