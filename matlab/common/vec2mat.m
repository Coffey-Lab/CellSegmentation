function [mat, padded] = vec2mat(vec, matCol, padding)
%VEC2MAT Convert a vector into a matrix.
%   MAT = VEC2MAT(VEC, MATCOL) converts the vector VEC into a matrix with
%   MATCOL columns, creating one row at a time. If the length of VEC is not
%   a multiple of MATCOL, then the function places extra entries of 0 in the
%   last row of MAT.
%
%   MAT = VEC2MAT(VEC, MATCOL, PADDING) is the same as the first syntax,
%   except that the extra entries are taken from the matrix PADDING, in order.
%   If the number of elements in PADDING is insufficient, the last element is
%   used for the remaining entries.
%
%   [MAT, PADDED] = VEC2MAT(...) returns an integer PADDED that indicates
%   how many extra entries were placed in the last row of MAT.
%
%   See also RESHAPE.

%   Copyright 1996-2011 The MathWorks, Inc.

error(nargchk(2, 3, nargin,'struct'));	% 2 or 3 inputs required
if ndims(vec) > 2
    error(message('comm:vec2mat:InvalidVec'));
elseif (length(matCol) ~= 1 || ~isfinite(matCol) || ~isreal(matCol)...
        || floor(matCol) ~= matCol || matCol < 1)
    error(message('comm:vec2mat:InvalidMatcol'));
end

[vecRow, vecCol] = size(vec);
vecLen = vecRow*vecCol;
if vecCol == matCol
    mat = vec;
    padded = 0;
    return;			% nothing to do
elseif vecRow > 1
    vec = reshape(vec.', 1, vecLen);
end

try
    if nargin < 3 || isempty(padding)
        padding = cast(0, class(vec));	% default padding
    else
        padding = cast(padding(:).', class(vec));
    end
catch exception
    throw(exception)
end
paddingLen = length(padding);

matRow = ceil(vecLen/matCol);
padded = matRow*matCol - vecLen;	% number of elements to be padded
vec = [vec, padding(1:min(padded, paddingLen)),...
       repmat(padding(paddingLen), 1, padded-paddingLen)];	% padding
mat = reshape(vec, matCol, matRow).';
