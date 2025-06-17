function estimatedSymbolArray = detectSymbolsWithML(receivedSignalArray, M, Ex)
    switch M
        case 2,  estimatedSymbolArray = bpskDemodulation(receivedSignalArray);
        case 4, estimatedSymbolArray = qpskDemodulation(receivedSignalArray);
        case 16, estimatedSymbolArray = qam16Demodulation(receivedSignalArray, Ex);
        otherwise, error('Unsupported M = %d', M);
    end
end

function estimatedSymbolArray = bpskDemodulation(receivedSignalArray)
    realPart = real(receivedSignalArray);
    estimatedSymbolArray = 2*(realPart >= 0) - 1;
end


function estimatedSymbolArray = qpskDemodulation(receivedSignalArray)
    realPart = real(receivedSignalArray);
    imaginaryPart = imag(receivedSignalArray);
    
    realPartOfEstimatedSymbol = 2*(realPart >= 0) - 1;
    imaginaryPartOfEstimatedSymbol = 2*(imaginaryPart >= 0) - 1;
    estimatedSymbolArray = [realPartOfEstimatedSymbol ; imaginaryPartOfEstimatedSymbol]/sqrt(2);
end

function estimatedSymbolArray = qam16Demodulation(receivedSignalArray, Ex)
        l = length(receivedSignalArray);
        estimatedSymbolArray =   sqrt(1/10)*ones(2, l); % row1: real, row2: imag
        for i = 1:l
            if real(receivedSignalArray(i)) > 2*sqrt(Ex/10)
                estimatedSymbolArray(1, i) = 3*sqrt(1/10);
            elseif real(receivedSignalArray(i)) < -2*sqrt(Ex/10)
                estimatedSymbolArray(1, i) = -3*sqrt(1/10);
            elseif real(receivedSignalArray(i)) < 0
                estimatedSymbolArray(1, i) = -sqrt(1/10);
            end

            if imag(receivedSignalArray(i)) > 2*sqrt(Ex/10)
                estimatedSymbolArray(2, i) = 3*sqrt(1/10);
            elseif imag(receivedSignalArray(i)) < -2*sqrt(Ex/10)
                estimatedSymbolArray(2, i) = -3*sqrt(1/10);
            elseif imag(receivedSignalArray(i)) < 0
                estimatedSymbolArray(2, i) = -sqrt(1/10);
            end
        end
end
