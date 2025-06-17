% main code
% generate sequences and plot received signals in complex plane
listOfM = [2, 4, 16];
listOfEx = [1, 10, 1];
listOfN0 = [1, 10, 0.01];

figure;
plotIndex = 1;

for m = listOfM
    for i = 1:3
        Ex = listOfEx(i);
        N0 = listOfN0(i);
        
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
