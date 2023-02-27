function y = qammod(x, M, varargin)
%QAMMOD Quadrature amplitude modulation
%
%   Y = QAMMOD(X,M) outputs the complex envelope of the modulation of the
%   message signal X using quadrature amplitude modulation. M is the
%   alphabet size and must be an integer power of two. The message signal X
%   must consist of integers between 0 and M-1. X can be a scalar, a
%   vector, a matrix or an array with 3 dimensions.
%
%   Y = QAMMOD(X,M,SYMBOL_ORDER) specifies how the function maps an integer
%   or group of log2(M) input bits to the corresponding symbol. If
%   SYMBOL_ORDER is set to 'gray', then the function uses a Gray-coded
%   ordering. If SYMBOL_ORDER is set to 'bin', then the function uses a
%   natural binary-coded ordering. If SYMBOL_ORDER is an integer-valued
%   vector with M elements, the function uses the ordering specified by
%   this vector. This vector must have unique elements in the range [0,
%   M-1]. The first element of this vector corresponds to the top-leftmost
%   point of the constellation, with subsequent elements running down
%   column-wise, from left to right. The last element corresponds to the
%   bottom-rightmost point. The default value is 'gray'.
%
%   Y = QAMMOD(X,M,...,Name,Value) specifies additional name-value pair
%   arguments described below:
%
%   'InputType'          One of the strings: 'integer', or 'bit'. 'integer'
%                        indicates that the message signal is integer
%                        valued between 0 and M-1. 'bit' indicates that the
%                        message signal is binary (0 or 1). In this case,
%                        the number of rows (dimension 1) must be an
%                        integer multiple of log2(M). A group of log2(M)
%                        bits are mapped onto a symbol, with the first bit
%                        representing the MSB and the last bit representing
%                        the LSB. The default value is 'integer'.
%
%   'UnitAveragePower'   A logical scalar value. If true, the QAM
%                        constellation is scaled to average power of 1. If
%                        false, the QAM constellation with minimum distance
%                        of 2 between constellation points is used. The
%                        default value is false.
%
%   'OutputDataType'     Output fixed-point type as a signed, unscaled
%                        numerictype object in MATLAB simulation, and as a
%                        signed, scaled numerictype object during C code or
%                        MEX generation. When this argument is not
%                        specified, if the input datatype is double or
%                        built-in integers, the output datatype is double;
%                        if the input datatype is single, the output
%                        datatype is single. When the input is fixed-point,
%                        this parameter must be specified.
%
%   'PlotConstellation'  A logical scalar value. If true, the QAM
%                        constellation is plotted. The default value is
%                        false.
%
% Example 1:
%    % 32-QAM modulation. Default: Integer input, Gray coding, minimum
%    % distance of 2 between constellation points
%    x = (0:31)';
%    y = qammod(x, 32);
% 
% Example 2:
%    % 16-QAM modulation, with LTE specific symbol mapping and
%    % constellation % scaled to average power of 1. Default: Integer input
%    x = randi([0, 15], 20, 4, 2);
%    lteSymMap = [11 10 14 15 9 8 12 13 1 0 4 5 3 2 6 7];
%    y = qammod(x, 16, lteSymMap, 'UnitAveragePower', true);
% 
% Example 3: 
%    % 64-QAM modulation with binary mapping, bit input and signed
%    % fixed-point output data type with 16 bits of word length and 10 
%    % bits of fraction length. Default: minimum distance of 2 between
%    % constellation points
%    x = randi([0, 1], 10*log2(64), 3);
%    y = qammod(x, 64, 'bin', 'InputType', 'bit', ...
%               'OutputDataType', numerictype(1,16,10));
%
% Example 4:
%    % Visualize the constellation for 16-QAM modulation, with gray
%    % mapping, bit input and constellation scaled to average power of 1.
%    x = randi([0, 1], log2(16), 1);
%    y = qammod(x, 16, 'InputType', 'bit', 'UnitAveragePower', true, ...
%               'PlotConstellation', true);
% 
%   See also QAMDEMOD, PSKMOD, APSKMOD, DVBSAPSKMOD, MIL188QAMMOD.

%    Copyright 1996-2022 The MathWorks, Inc.
    
    %#codegen
    
    narginchk(2, 11);
    
    [symbolOrder, symbolOrderVector, bitInput, unitAveragePower, ...
        plotConstellation, outputDataType] = validateInputArgs(M, varargin{:});
    
    validateInput(x, M, bitInput, outputDataType);
    
    [y, const] = comm.internal.qam.modulate(x, M, symbolOrder, symbolOrderVector, ...
        bitInput, unitAveragePower, outputDataType);
    
    if plotConstellation && comm.internal.utilities.isSim()
        comm.internal.utilities.plotConstellation('QAM', double(M), const, symbolOrder, ...
            symbolOrderVector, bitInput, unitAveragePower);
    end
    
end

function [symbolOrder, symbolOrderVector, bitInput, unitAveragePower, ...
        plotConstellation, outputDataType] = validateInputArgs(M, varargin)
    
    nInArgs = nargin;
    plotConstellation = false;
    unitAveragePower = false;
    
    validateM(M);    
    if nInArgs==1
        % qammod(x, M)
        symbolOrder = 'gray';
        symbolOrderVector = 0:M-1; % not used
        outputDataType = [];
        bitInput = false;
    elseif nInArgs==2
        bitInput = false;
        outputDataType = [];
        % qammod(x, M, symbolOrder)
        [symbolOrder, symbolOrderVector] = parseSymbolOrder(varargin{1}, M);
    elseif nInArgs==3
        % qammod(x, M, P1, V1)
        symbolOrder = 'gray';
        symbolOrderVector = 0:M-1; % not used
        [bitInput, unitAveragePower, plotConstellation, outputDataType] = ...
            validatePVpair(varargin{:});
    else
        % qammod(x, M, arg1, arg2, arg3, ...)
        if isnumeric(varargin{1})
            % qammod(x, M, symbolOrderVector, P1, V1, ...)
            [symbolOrder, symbolOrderVector] = parseSymbolOrder(varargin{1}, M);
            [bitInput, unitAveragePower, plotConstellation, outputDataType] = ...
                validatePVpair(varargin{2:end});
        else
            if mod(nInArgs,2)
                % qammod(x, M, P1, V1, P2, V2, ...)
                symbolOrder = 'gray';
                symbolOrderVector = 0:M-1; % not used
                [bitInput, unitAveragePower, plotConstellation, outputDataType] = ...
                    validatePVpair(varargin{:});
            else
                % qammod(x, M, symbolOrderStr, P1, V1, ...)
                [symbolOrder, symbolOrderVector] = parseSymbolOrder(varargin{1}, M);
                [bitInput, unitAveragePower, plotConstellation, outputDataType] = ...
                    validatePVpair(varargin{2:end});
            end                
        end
    end
    
end

function [symbolOrder, symbolOrderVector] = parseSymbolOrder(inputSymbolOrder, M)
    % Determine if inputSymbolOrder is string ('bin', 'gray') or a numeric
    % vector, perform necessary validation and return symbolOrder,
    % symbolOrderVector appropriately.
    
    if isnumeric(inputSymbolOrder)
        % numeric vector
        symbolOrder = 'custom';
        symbolOrderVector = inputSymbolOrder;
        validateSymbolOrderVector(symbolOrderVector, M);
    else
        % string
        symbolOrderVector = 0:M-1;
        symbolOrder = inputSymbolOrder;
        validateSymbolOrderString(symbolOrder);
    end
end

function [bitInput, unitAvgPowerBool, plotConstBool, outDType] = validatePVpair(varargin)
    % parse and validate input arguments
         
    defaults = struct('InputType', 'integer', 'UnitAveragePower', false, ...
        'PlotConstellation', false, 'OutputDataType', []);
    res = comm.internal.utilities.nvParser(defaults, varargin{:});    
    inpType = res.InputType;
    unitAvgPower = res.UnitAveragePower;
    plotConst = res.PlotConstellation;
    outDType = res.OutputDataType;
    
    validInputType = {'integer', 'bit'};
    validatestring(inpType, validInputType, mfilename, 'InputType');
    validateattributes(unitAvgPower, {'logical','numeric'}, ...
        {'scalar','real','nonnan'}, mfilename, 'UnitAveragePower');
    validateattributes(plotConst, {'logical','numeric'}, ...
        {'scalar','real','finite','nonnan'}, mfilename, 'PlotConstellation');
    if ~isempty(outDType)
        validateOutputDataType(outDType);
    end
    
    bitInput = strncmpi(inpType, 'b', 1);
    unitAvgPowerBool = logical(unitAvgPower);
    plotConstBool = logical(plotConst);
    
end

function validateM(M)
    validateattributes(M, {'numeric'}, {'scalar','positive','integer'}, mfilename, 'M', 2);
    if (ceil(log2(double(M))) ~= log2(double(M)))
        coder.internal.error('comm:qammod:Mpow2');
    end
end

function validateSymbolOrderString(symbolOrder)
    validatestring(symbolOrder, {'bin','gray'}, mfilename, 'SYMBOL_ORDER');
end

function validateSymbolOrderVector(symbolOrder, M)
    validateattributes(symbolOrder, {'numeric'}, {'vector','real','integer', ...
        'numel',M,'>=',0,'<',M}, mfilename, 'SYMBOL_ORDER');
    coder.internal.errorIf(numel(unique(symbolOrder)) ~= M, 'comm:shared:SymbolOrderVector');
    coder.internal.errorIf(mod(log2(M),2) ~= 0, 'comm:qammod:SymbolOrderNotSupported');
end

function validateOutputDataType(outDType)
    validateattributes(outDType, {'embedded.numerictype','embedded.fi'}, {}, mfilename, 'OutputDataType');
    isValid = ~isfloat(outDType) && isfixed(outDType) && ...
        ~isempty(outDType.SignednessBool) && outDType.SignednessBool;
    coder.internal.errorIf(~isValid, 'comm:qammod:InvalidOutputDataType');
    if ~comm.internal.utilities.isSim()
        unspecifiedScaling = coder.const(strcmpi(get(outDType,'Scaling'), 'Unspecified'));
        coder.internal.errorIf(unspecifiedScaling, 'comm:qammod:InvalidOutputDataTypeCG');        
    end    
end

function validateInput(x, M, bitInput, outDType)
    if isfi(x)
        % fixed-point input
        
        coder.internal.errorIf(isempty(outDType), 'comm:qammod:OutputDataTypeMustBeSpecified');
        coder.internal.errorIf(M > 2^10, 'comm:qammod:InvalidM');

        Mtmp = fi(M-1, 1, 16, 0);
        xCol = x(:); 
        if bitInput
            if ~isreal(x) || any(xCol < 0) || any(xCol > 1)
                coder.internal.error('comm:qammod:xrealBit');
            end
            nBits = int32(0);
            tmpM = int32(M);
            while tmpM ~= 1
                nBits(1) = nBits(1) + 1;
                tmpM = bitshift(tmpM, -1);
            end
            coder.internal.errorIf(mod(size(x,1), nBits) ~= 0, 'comm:shared:xSizeBit');
        else
            if ~isreal(x) || any(xCol < 0) || any(xCol > Mtmp)
                coder.internal.error('comm:qammod:xreal');
            end
        end
    else
        % float or built-in integer input
        if bitInput
            validateattributes(x, {'numeric'}, {'real','binary'}, mfilename, 'X', 1);
            nBits = log2(M);
            coder.internal.errorIf(mod(size(x,1), nBits) ~= 0, 'comm:shared:xSizeBit');
        else
            validateattributes(x, {'numeric'}, {'real','integer','>=',0,'<',M}, mfilename, 'X', 1);
        end
    end
end
