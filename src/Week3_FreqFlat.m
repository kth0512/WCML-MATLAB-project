addpath('function/');
ListOfNtr = [2, 5, 10];
numOfNtr = numel(ListOfNtr);
numOfIteration = 1000;
Ex = 1;
M = 16;
lengthOfBitSequence = 4*100;
numOfSymbol = 100;
SNR_BER_LS = zeros(41, 6);
SNR_BER_LMMSE = zeros(41, 6);

for i = 1:numOfNtr
    Ntr = ListOfNtr(i);
    t = sqrt(Ex)*generateZadoffChuTrainingSequence(1, Ntr);
    filterForLS = (t')/(t*t');
    for j = 0:40 
        N0 = 10^(-j/10);
        sumOfBERLS = 0;
        sumOfBERLMMSE = 0;
        filterForLMMSE = (t')/(t*t' + N0);
        for k = 1:numOfIteration
            h = generateFrequencyFlatChannel;
            bitSequence = generateRandomBitSequence(lengthOfBitSequence);
            s = mapBitsToSymbols(bitSequence, M);
            v = generateAWGN(N0, numOfSymbol+Ntr);
            symbolWithTraining = [t s];
            y = generateReceivedSignalInFreqFlat(symbolWithTraining, v, Ex, h);
            yTraining = y(1:Ntr);

            % Least Square (LS)
            hHatLS = channelEstimationInFreqFlat(filterForLS, yTraining); % zadoffChuTrainingSequence is not multiplied with sqrt(Ex)
            yEqLS = equalizeFreqFlatChannel(y, hHatLS);
            sHatLS = detectSymbolsWithML(yEqLS(Ntr+1:numOfSymbol+Ntr), M, Ex);
            estimatedBitSequenceLS = mapSymbolsToBits(sHatLS, M);
            BERLS = calculateBER(bitSequence, estimatedBitSequenceLS);
            sumOfBERLS = sumOfBERLS + BERLS;

            % Linear Minimum Mean Square Error (LMMSE)
            hHatLMMSE = channelEstimationInFreqFlat(filterForLMMSE, yTraining); % zadoffChuTrainingSequence is not multiplied with sqrt(Ex)
            yEqLMMSE = equalizeFreqFlatChannel(y, hHatLMMSE);
            sHatLMMSE = detectSymbolsWithML(yEqLMMSE(Ntr+1:numOfSymbol+Ntr), M, Ex);
            estimatedBitSequenceLMMSE = mapSymbolsToBits(sHatLMMSE, M);
            BERLMMSE = calculateBER(bitSequence, estimatedBitSequenceLMMSE);
            sumOfBERLMMSE = sumOfBERLMMSE + BERLMMSE;
        end
        % Least Square
        averageOfBERLS = sumOfBERLS/numOfIteration;
        SNR_BER_LS(j+1, 2*i-1:2*i) = [j, averageOfBERLS];

        % Linear Minimum Mean Square Error
        averageOfBERLMMSE = sumOfBERLMMSE/numOfIteration;
        SNR_BER_LMMSE(j+1, 2*i-1:2*i) = [j, averageOfBERLMMSE];
    end
end

disp(SNR_BER_LMMSE)
disp(SNR_BER_LS)
figure;
hold on;
grid on;

semilogy(SNR_BER_LS(:, 1), SNR_BER_LS(:, 2), '-o', 'LineWidth', 1.5, 'Color', [0, 0.4470, 0.7410], 'MarkerEdgeColor', [0, 0.4470, 0.7410], 'DisplayName', 'Ntr = 2, LS');
semilogy(SNR_BER_LS(:, 3), SNR_BER_LS(:, 4), '-^', 'LineWidth', 1.5, 'Color', [0.4940, 0.1840, 0.5560], 'MarkerEdgeColor', [0.4940, 0.1840, 0.5560], 'DisplayName', 'Ntr = 5, LS');
semilogy(SNR_BER_LS(:, 5), SNR_BER_LS(:, 6), '-s', 'LineWidth', 1.5, 'Color', [0.4660, 0.6740, 0.1880], 'MarkerEdgeColor', [0.4660, 0.6740, 0.1880], 'DisplayName', 'Ntr = 10, LS');

semilogy(SNR_BER_LMMSE(:, 1), SNR_BER_LMMSE(:, 2), ':o', 'LineWidth', 1.5, 'Color', [0, 0.4470, 0.7410], 'MarkerEdgeColor', [0, 0.4470, 0.7410], 'DisplayName', 'Ntr = 2, LMMSE');
semilogy(SNR_BER_LMMSE(:, 3), SNR_BER_LMMSE(:, 4), ':^', 'LineWidth', 1.5, 'Color', [0.4940, 0.1840, 0.5560], 'MarkerEdgeColor', [0.4940, 0.1840, 0.5560], 'DisplayName', 'Ntr = 5, LMMSE');
semilogy(SNR_BER_LMMSE(:, 5), SNR_BER_LMMSE(:, 6), ':s', 'LineWidth', 1.5, 'Color', [0.4660, 0.6740, 0.1880], 'MarkerEdgeColor', [0.4660, 0.6740, 0.1880], 'DisplayName', 'Ntr = 10, LMMSE');

set(gca, 'YScale', 'log');
xlabel('SNR(dB)')
ylabel('BER')
title('BER VS SNR Curve');
legend('Location', 'best');
ylim('auto')
hold off;
