function [bwOut,thinnedImg] = longestConstrainedPath(bwin,varargin)
% BWOUT = LONGESTCONSTRAINEDPATH(BW)
% BWOUT = LONGESTCONSTRAINEDPATH(BW,'thinOpt',thinOption)
%
% Calculates the longest continuous path in the infinitely thinned bw
% image, following the calculation of the bwdistgeodesic transform.
% Robustly ignores spurs. Note that only a single path is detected; if
% there are multiple paths the same length, only one will be returned.
%
% INPUTS:
% bwin:    2D binary input image.
%
% PV PAIRS:
% 'thinOpt': {'Thin','Skel'}. Thinning option.
%            'Thin' uses infinite thinning (bwmorph(bwin, 'thin', Inf);
%            'Skel' uses infinite skeletonization (bwmorph(bwin,
%            'skeleton', Inf); DEFAULT: 'Thin'.
% 'geodesicMethod':
%            'Method' used in call to bwdistgeodesic. One of:
%            {'cityblock', 'chessboard','quasi-euclidean'}. DEFAULT:
%            'quasi-euclidean'.
%
% OUTPUT:
% bwOut:   2D binary image showing the longest calculated path.
%
% thinnedImg: 2D thinned image (using infinite 'thinning' or
%          'skeletonization'  in bwmorph).
%
% % EXAMPLES
% imgName = fullfile(toolboxdir('images'),'imdata\logo.tif');
% bw = imread(imgName);
% bw = imclearborder(~bw);
% bwOut = longestConstrainedPath(bw);
% imshow(bwOut)
%
% Brett Shoelson, PhD
% brett.shoelson@mathworks.com
% 
% See also: bwmorph bwdistgeodesic

% Copyright 2015 The MathWorks, Inc.

validateattributes(bwin,{'numeric' 'logical'},{'real' 'nonsparse' '2d'}, ...
	mfilename, '', 1);
[thinOpt, geodesicMethod] = parseInputs(varargin{:});
% 8-connected only:
M = size(bwin, 1);
neighborOffsets = [-1, M, 1, -M, M + 1, M-1, -M + 1, -M - 1]; %8-connected
thinOpt = lower(thinOpt);

switch thinOpt
	case 'skel'
		thinnedImg = bwmorph(bwin, 'skeleton', Inf);
	case 'thin'
		%This is the default; seems to perform better than skel
		thinnedImg = bwmorph(bwin, 'thin', Inf);
end
endpoints = find(bwmorph(thinnedImg, 'endpoints'));
if numel(endpoints)==2
	bwOut = thinnedImg;
	return
end
mask = false(size(thinnedImg));
mask(bwmorph(thinnedImg, 'endpoints')) = true; %endpoints mask
bwdg = bwdistgeodesic(thinnedImg,mask,geodesicMethod);
bwdg(bwdg==0)= NaN;
%imshow(bwdg)%,[]
%set(gca,'xlim',[50.76 78.646],'ylim',[76.227 100.69])
%Now the maximum position value of tmp must be on the longest path, and we
%can pare the graph by keeping only its largest two neighbors
bwOut = false(size(thinnedImg));
startPoint = find(bwdg==max(bwdg(:)));% SEED?
startPoint = startPoint(1); %In case there are multiple paths...
bwdg(startPoint) = NaN;
bwOut(startPoint)= true;
%[r,c] = ind2sub(size(bwOut),startPoint)
%hold on; plot(c,r,'ro','markersize',10); drawnow
neighbors = bsxfun(@plus,startPoint,neighborOffsets);
[sortedNeighbors,inds] = sort(bwdg(neighbors));
bothNeighbors = neighbors(inds(1:2));
%[rb,cb] = ind2sub(size(bwOut),bothNeighbors);hold on; plot(cb,rb,'b.','markersize',14); drawnow
for ii = 2:-1:1
	%plot(cb(ii),rb(ii),'mo','markersize',8); drawnow
	activePixel = bothNeighbors(ii);
	%[r,c] = ind2sub(size(bwOut),activePixel)
	%hold on; plot(c,r,'y.')
	while ~isempty(activePixel)%currNNZ ~= nnz(bwOut)% ~isempty(activePixel) && iter < 1000 %&& ~ismember(activePixel,evaluatedPixels)
		%currNNZ = nnz(bwOut)
		bwOut(activePixel)= true;
		bwdg(activePixel) = NaN;
		
		%imshow(bwdg);set(gca,'xlim',[22.766 109.36],'ylim',[31.55 107.5]);impixelinfo;drawnow
		%for jj = 1:numel(activePixel)
		neighbors = bsxfun(@plus,activePixel,neighborOffsets);
		%neighbors = bsxfun(@plus,activePixel(jj),neighborOffsets);
		activePixel = neighbors(bwdg(neighbors)==max(bwdg(neighbors)));
		if ~isempty(activePixel)% What to do for dupes?
			activePixel = activePixel(1);
			%[r,c] = ind2sub(size(bwOut),activePixel);
			%hold on; plot(c,r,'g.');drawnow
		end
		%end
		%[r,c] = ind2sub(size(bwOut),activePixel);hold on;plot(c,r,'g.');drawnow;
	end
end
%figure,imshow(bwOut)

	function [thinOpt,geodesicMethod] = parseInputs(varargin)
		% Setup parser with defaults
		parser = inputParser;
		parser.CaseSensitive = false;
		parser.FunctionName  = 'longestConstrainedPath';
		parser.addParameter('thinOpt','Thin');
		parser.addParameter('geodesicMethod','quasi-euclidean');
		% Parse input
		parser.parse(varargin{:});
		% Assign outputs
		r = parser.Results;
		[thinOpt,geodesicMethod] = deal(r.thinOpt,r.geodesicMethod);
	end

end