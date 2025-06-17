addpath('function/');
ListOfNtr = [2, 5, 10];
numOfNtr = numel(ListOfNtr);
numOfIteration = 1000;
N0 = 1;
M = 16;
lengthOfBitSequence = 4*100;
SNR_BER = zeros(17, 6);

for i = 0:16 % 0~16dB
    Ex = 10^(i/10);
    sumOfBER = zeros(1, numOfNtr);
    for j = 1:numOfIteration
        FrequencyFlatChannel = generateFrequencyFlatChannel;
        bitSequence = generateRandomBitSequence(lengthOfBitSequence);
        transmittedSymbolSequence = mapBitsToSymbols(bitSequence, M);
        noiseSequence = generateAWGN(N0, numel(transmittedSymbolSequence));
        receivedSignalSequence = generateReceivedSignalInFreqFlat(transmittedSymbolSequence, noiseSequence, Ex, FrequencyFlatChannel);
        for k = 1:numOfNtr
            Ntr = ListOfNtr(k);
            zadoffChuTrainingSequence = generateZadoffChuTrainingSequence(1, Ntr);
            noiseSequenceForTraining = generateAWGN(N0, Ntr);
            receivedTrainingSequence = generateReceivedSignalInFreqFlat(zadoffChuTrainingSequence, noiseSequenceForTraining, Ex, FrequencyFlatChannel);
            estimatedChannel = channelEstimationInFreqFlatWithLS(zadoffChuTrainingSequence, receivedTrainingSequence);
            equalizedSymbolArray = equalizeFreqFlatChannel(receivedSignalSequence, estimatedChannel);
            estimatedSymbolArray = detectSymbolsWithML(equalizedSymbolArray, M, Ex);
            estimatedBitSequence = mapSymbolsToBits(estimatedSymbolArray, M);
            
            sumOfBER(k) = sumOfBER(k) + calculateBER(bitSequence, estimatedBitSequence);
        end
    end
    averageOfBER = sumOfBER/numOfIteration;
    for t = 1:numOfNtr
        SNR_BER(i+1, 2*t-1:2*t) = [i, averageOfBER(t)];
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

