function symbolArray = mapBitsToSymbols(bitSequence, M)
    switch M
        case 2,  symbolArray = bpskModulation(bitSequence);
        case 4, symbolArray = qpskModulation(bitSequence);
        case 16, symbolArray = qam16Modulation(bitSequence);
        otherwise, error('Unsupported M = %d', M);
    end
end

function symbolArray = bpskModulation(bitSequence)
    symbolArray = 2*bitSequence - 1;
end

function symbolArray = qpskModulation(bitSequence)
     bitsPerSymbol = 2;
     bitPairs = reshape(bitSequence, bitsPerSymbol, []);
     realPart = 1 - 2*bitPairs(2, :);
     imaginaryPart = 1 - 2*bitPairs(1, :);
     symbolArray = (realPart + 1i*imaginaryPart)/sqrt(2);
end

function symbolArray = qam16Modulation(bitSequence)
    bitsPerSymbol = 4;
    bitQuartets = reshape(bitSequence, bitsPerSymbol, []);
    realPamLevel = [-3, -1, 3, 1]/sqrt(10);
    imaginaryPamLevel = [3, 1, -3, -1]/sqrt(10);

    realIndex = 2*bitQuartets(1, :) + bitQuartets(2, :) + 1;
    imaginaryIndex = 2*bitQuartets(3, :) + bitQuartets(4, :) + 1;

    symbolArray = realPamLevel(realIndex) + imaginaryPamLevel(imaginaryIndex)*1i;
end
