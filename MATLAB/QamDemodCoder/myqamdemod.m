function x = myqamdemod(y, M)

% x = comm.internal.qam.demodulate(y, M ...)
M = single(M);

% intX = computeHardInt(y, M)
% z = coder.nullcopy(zeros(size(y), 'single'));
z = zeros(size(y));

if mod(log2(M),2) % Cross constellation, including M=2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % const = comm.internal.qam.getSquareConstellation(M)
    % constellation = getSquareConstellation(M)
    nbits = log2(M);
    %const = coder.nullcopy(complex(zeros(1,M,'like',M),zeros(1,M,'like',M)));
    const = complex(zeros(1,M),zeros(1,M));
    
    % Trivial case, M = 2
    if (nbits == 1)
        realConst = [-1 1];
        %const(:) = realConst.*exp(1i*0);
        const(:) = complex(realConst,0);
        
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Out of comm.internal.qam.getSquareConstellation(M)
    % Into z(:) = genqamdemod(y,const)
    %z(:) = genqamdemod(y,const);
    for i = 1:size(y,3)
        for j = 1:size(y,2)
           for k = 1:size(y,1)
               %compute the minimum distance for each symbol
               [~, idx] = min(abs(y(k,j,i) - const));
                z(k,j,i) = idx-1;
           end
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

else % Square constellation, starting with M=4
    sqrtM = sqrt(M);
    rIdx = round( ((real(y) + (sqrtM-1)) ./ 2) );
    % clip values that are outside the valid range
    rIdx(rIdx < 0) = 0;
    rIdx(rIdx > (sqrtM-1)) = sqrtM-1;
    
    % Quadrature/imaginary rail
    % Move the imaginary part of input signal; scale appropriately and round
    % the values to get index of ideal constellation points
    iIdx = round(((imag(y) + (sqrtM-1)) ./ 2));
    % clip values that are outside the valid range
    iIdx(iIdx < 0) = 0;
    iIdx(iIdx > (sqrtM-1)) = sqrtM-1;
    
    % compute output from indices of ideal constellation points
    z(:) = sqrtM-iIdx-1 +  sqrtM*rIdx;

end

% Out of genqamdemod
% Out of computeHardInt
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Into preX = comm.internal.utilities.gray2bin(intX, 'qam', M);
% [output, mapping] = gray2bin(x, modulation, order)
% Into mapping = comm.internal.qam.getGrayMapping(order, x);
%      mapping = getGrayMapping(M, protoType)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%mapping = comm.internal.qam.getGrayMapping(M,z);
protoType = z;
nBits = int32(0);
nBits(1) = log2(M);
binMapping = int32((0:M-1)');
SymbolIndex = int32(zeros(size(binMapping)));

% mapping = zeros(M, 1, 'like', protoType);
mapping = cast(zeros(M, 1), 'like', protoType);
%mapping = complex(zeros(M,1),zeros(M,1));
outSymbolIndex = zeros(M, 1, 'like', mapping);
%outSymbolIndex = complex(zeros(M,1),zeros(M,1));
tmpM = int32(M);
tmpOne = int32(1);

if bitget(nBits,1)
    % Cross constellation
    
    nBitsI = bitshift(nBits+1, -1); % divide by 2
    nBitsQ = bitshift(nBits-1, -1);
    
    symbolI = bitshift(binMapping, -nBitsQ);
    symbolQ = bitand(binMapping, cast(bitshift(tmpM-tmpOne,-nBitsI),'like',binMapping));
    %symbolQ = bitand(binMapping, int32(bitshift(tmpM-tmpOne,-nBitsI)));
    
    i = 1;
    while i < nBitsI
        tmpI = symbolI;
        tmpI = bitshift(tmpI,-i);
        symbolI = coder.sameSizeBinaryOp(@bitxor,symbolI,tmpI);
        % i takes on values 1,2,4,8,...,2^n - n is an integer
        i = i + i;
    end
    
    i = 1;
    while i < nBitsQ
        tmpQ = symbolQ;
        tmpQ = bitshift(tmpQ,-i);
        symbolQ = coder.sameSizeBinaryOp(@bitxor, symbolQ, tmpQ);
        % i takes on values 1,2,4,8,...,2^n - n is an integer
        i = i + i;
    end
    
    SymbolIndex(:) = bitshift(symbolI,nBitsQ) + symbolQ;
    
else % square constellation
    
    nBitsBy2 = bitshift(nBits,-1);
    symbolI = bitshift(binMapping, -nBitsBy2);
    %symbolQ = bitand(binMapping, cast(bitshift(tmpM-tmpOne,-nBitsBy2),'like',binMapping));
    symbolQ = bitand(binMapping, int32(bitshift(tmpM-tmpOne,-nBitsBy2)));
    
    i = 1;
    while i < nBitsBy2
        tmpI = symbolI;
        tmpI = bitshift(tmpI,-i);
        symbolI = coder.sameSizeBinaryOp(@bitxor,symbolI,tmpI);
        
        tmpQ = symbolQ;
        tmpQ = bitshift(tmpQ,-i);
        symbolQ = coder.sameSizeBinaryOp(@bitxor, symbolQ, tmpQ);
        
        % i takes on values 1,2,4,8,...,2^n - n is an integer
        i = i + i;
    end
    
    SymbolIndex(:) = bitshift(symbolI, nBitsBy2) + symbolQ;
    
end

outSymbolIndex(:) = SymbolIndex;

% Make sure that mapping is a vector, when used to name the symbols
% column-wise starting from left upper corner, results in a gray mapped
% constellation.
mapping(outSymbolIndex + cast(1,'like',outSymbolIndex)) = 0:M-1;
%mapping(outSymbolIndex + (1)) = 0:M-1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Out of getGrayMapping(order,x)
% Still in gray2bin
if isrow(z)
    % mapping AND x, both, are vectors AND they have
    % different orientations. As mapping is always a column
    % vector, this degenerates into isrow(x) check.
    tmpMapping = mapping';
    %preX = tmpMapping(z + cast(1,'like',z));
    preX = tmpMapping(z + 1);
else
    %preX = mapping(z + cast(1,'like',z));
    preX = mapping(z + 1);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Out of gray2bin
% Still in demodulate
x = preX;