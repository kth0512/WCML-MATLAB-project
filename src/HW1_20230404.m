function randomBitSequence = generateRandomBitSequence(length)
    randomBitSequence = randi([0 1], 1, length);
end

function symbolArray = mapBitsToSymbols(bitSequence, M)
    switch M
        case 2,  symbolArray = BPSK(bitSequence);
        case 4, symbolArray = QPSK(bitSequence);
        case 16, symbolArray = QAM16(bitSequence);
        otherwise, error('Unsupported M = %d', M);
    end

end

function symbolArray = BPSK(bitSequence)
    symbolArray = 2*bitSequence - 1;
end

function symbolArray = QPSK(bitSequence)
     bitsPerSymbol = 2;
     bitPairs = reshape(bitSequence, bitsPerSymbol, []);
     realPart = 1 - 2*bitPairs(2, :);
     imaginaryPart = 1 - 2*bitPairs(1, :);
     symbolArray = (realPart + 1i*imaginaryPart)/sqrt(2);
end

function symbolArray = QAM16(bitSequence)
    bitsPerSymbol = 4;
    bitQuartets = reshape(bitSequence, bitsPerSymbol, []);
    realPamLevel = [-3, -1, 3, 1]/sqrt(10);
    imaginaryPamLevel = [3, 1, -3, -1]/sqrt(10);

    realIndex = 2*bitQuartets(1, :) + bitQuartets(2, :) + 1;
    imaginaryIndex = 2*bitQuartets(3, :) + bitQuartets(4, :) + 1;

    symbolArray = realPamLevel(realIndex) + imaginaryPamLevel(imaginaryIndex)*1i;
end

function noiseArray = generateAWGN(N0, length)  
    noiseArray = zeros(1, length);

    for i = 1:length
        realPart = normrnd(0, sqrt(N0/2));
        imaginaryPart = normrnd(0, sqrt(N0/2));
        noiseArray(i) = realPart + 1i*imaginaryPart;
    end
end 

function receivedSignalArray = generateReceivedSignal(symbolArray, noiseArray, Ex)
    receivedSignalArray = sqrt(Ex)*symbolArray + noiseArray;
end

% main code
% generate sequences and plot received signals in complex plane
MArray = [2, 4, 16];
ExArray = [1, 10, 1];
N0Array = [1, 10, 0.01];

figure;
plotIndex = 1;

for m = MArray
    for i = 1:3
        Ex = ExArray(i);
        N0 = N0Array(i);
        
        bitSequence = generateRandomBitSequence(1024);
        symbolSequence = mapBitsToSymbols(bitSequence, m);
        noiseSequence = generateAWGN(N0, numel(symbolSequence));
        receivedSignalSequence = generateReceivedSignal(symbolSequence, noiseSequence, Ex);

        realPart = real(receivedSignalSequence);
        imaginaryPart = imag(receivedSignalSequence);
        
        subplot(3, 3, plotIndex)
        scatter(realPart, imaginaryPart, 3,'filled');
        xlabel('In-Phase');
        ylabel('Quadrature');
        title('scatter plot')
        
        switch N0
            case 1 
                xlim([-3.5, 3.5])
                ylim([-3.5, 3.5])

            case 10
                xlim([-10.5, 10.5])
                ylim([-10.5, 10.5]) 

            case 0.01
                xlim([-1.5, 1.5])
                ylim([-1.5, 1.5])
        end

        plotIndex = plotIndex + 1;
    end
end
