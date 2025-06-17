addpath('function/');
ListOfNtr = [2, 5, 10];
numOfNtr = numel(ListOfNtr);
numOfIteration = 1000;
N0 = 1;
M = 16;
lengthOfBitSequence = 4*100;
numOfSymbol = 100;
SNR_BER = zeros(101, 6);

for i = 1:numOfNtr
    Ntr = ListOfNtr(i);
    for j = 0:100 % 0~16dB
        Ex = 10^(j/10);
        sumOfBER = 0;
        zadoffChuTrainingSequence = generateZadoffChuTrainingSequence(1, Ntr);
        for k = 1:numOfIteration
            h = generateFrequencyFlatChannel;
            bitSequence = generateRandomBitSequence(lengthOfBitSequence);
            s = mapBitsToSymbols(bitSequence, M);
            v = generateAWGN(N0, numOfSymbol+Ntr);
            symbolWithTraining = [zadoffChuTrainingSequence s];
            y = generateReceivedSignalInFreqFlat(symbolWithTraining, v, Ex, h);
            yTraining = y(1:Ntr);
            hHat = channelEstimationInFreqFlatWithLS(zadoffChuTrainingSequence, yTraining);
            yEq = equalizeFreqFlatChannel(y, hHat);
            sHat = detectSymbolsWithML(yEq(Ntr+1:numOfSymbol+Ntr), M, 1);
            estimatedBitSequence = mapSymbolsToBits(sHat, M);
            BER = calculateBER(bitSequence, estimatedBitSequence);
            sumOfBER = sumOfBER + BER;
        end
        averageOfBER = sumOfBER/numOfIteration;
        SNR_BER(j+1, 2*i-1:2*i) = [j, averageOfBER];
    end
end
disp(SNR_BER)
figure;
hold on;
semilogy(SNR_BER(:, 1), SNR_BER(:, 2), '-o', 'MarkerEdgeColor', 'b', 'DisplayName', 'Ntr = 2');
semilogy(SNR_BER(:, 3), SNR_BER(:, 4), '-o', 'MarkerEdgeColor', 'r', 'DisplayName', 'Ntr = 5');
semilogy(SNR_BER(:, 5), SNR_BER(:, 6), '-o', 'MarkerEdgeColor', 'g', 'DisplayName', 'Ntr = 10');
set(gca, 'YScale', 'log');
xlabel('SNR(dB)')
ylabel('BER')
title('BER VS SNR Curve');
legend('Location', 'best');
ylim([10^(-8), 1])
hold off;

