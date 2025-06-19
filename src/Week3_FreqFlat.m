addpath('function/');
ListOfNtr = [2, 5, 10];
numOfNtr = numel(ListOfNtr);
numOfIteration = 1000;
N0 = 1;
M = 16;
lengthOfBitSequence = 4*100;
numOfSymbol = 100;
SNR_BER = zeros(41, 6);
SNR_BER_LMMSE = zeros(41, 6);

for i = 1:numOfNtr
    Ntr = ListOfNtr(i);
    zadoffChuTrainingSequence = generateZadoffChuTrainingSequence(1, Ntr);
    filterForLS = (zadoffChuTrainingSequence')/(zadoffChuTrainingSequence*zadoffChuTrainingSequence');
    filterForLMMSE = (zadoffChuTrainingSequence')/(zadoffChuTrainingSequence*zadoffChuTrainingSequence' + N0);
    for j = 0:40 
        Ex = 10^(j/10);
        sumOfBERLS = 0;
        sumOfBERLMMSE = 0;
        for k = 1:numOfIteration
            h = generateFrequencyFlatChannel;
            bitSequence = generateRandomBitSequence(lengthOfBitSequence);
            s = mapBitsToSymbols(bitSequence, M);
            v = generateAWGN(N0, numOfSymbol+Ntr);
            symbolWithTraining = [zadoffChuTrainingSequence s];
            y = generateReceivedSignalInFreqFlat(symbolWithTraining, v, Ex, h);
            yTraining = y(1:Ntr);

            % Least Square (LS)
            hHat = channelEstimationInFreqFlat(filterForLS, yTraining); % zadoffChuTrainingSequence is not multiplied with sqrt(Ex)
            yEq = equalizeFreqFlatChannel(y, hHat);
            sHat = detectSymbolsWithML(yEq(Ntr+1:numOfSymbol+Ntr), M, 1);
            estimatedBitSequence = mapSymbolsToBits(sHat, M);
            BER = calculateBER(bitSequence, estimatedBitSequence);
            sumOfBER = sumOfBER + BER;

            % Linear Minimum Mean Square Error (LMMSE)
            hHatLMMSE = channelEstimationInFreqFlat(filterForLMMSE, yTraining); % zadoffChuTrainingSequence is not multiplied with sqrt(Ex)
            yEqLMMSE = equalizeFreqFlatChannel(y, hHatLMMSE);
            sHatLMMSE = detectSymbolsWithML(yEqLMMSE(Ntr+1:numOfSymbol+Ntr), M, 1);
            estimatedBitSequenceLMMSE = mapSymbolsToBits(sHatLMMSE, M);
            BERLMMSE = calculateBER(bitSequence, estimatedBitSequenceLMMSE);
            sumOfBERLMMSE = sumOfBERLMMSE + BERLMMSE;


        end
        % Least Square
        averageOfBER = sumOfBER/numOfIteration;
        SNR_BER(j+1, 2*i-1:2*i) = [j, averageOfBER];

        % Linear Minimum Mean Square Error
        averageOfBERLMMSE = sumOfBERLMMSE/numOfIteration;
        SNR_BER_LMMSE(j+1, 2*i-1:2*i) = [j, averageOfBERLMMSE];
    end
end

figure;
hold on;
grid on;
semilogy(SNR_BER(:, 1), SNR_BER(:, 2), '-o', 'LineWidth', 1.5, 'Color', [0, 0.4470, 0.7410], 'MarkerEdgeColor', [0, 0.4470, 0.7410], 'DisplayName', 'Ntr = 2');
semilogy(SNR_BER(:, 3), SNR_BER(:, 4), '-^', 'LineWidth', 1.5, 'Color', [0.4940, 0.1840, 0.5560], 'MarkerEdgeColor', [0.4940, 0.1840, 0.5560], 'DisplayName', 'Ntr = 5');
semilogy(SNR_BER(:, 5), SNR_BER(:, 6), '-s', 'LineWidth', 1.5, 'Color', [0.4660, 0.6740, 0.1880], 'MarkerEdgeColor', [0.4660, 0.6740, 0.1880], 'DisplayName', 'Ntr = 10');
set(gca, 'YScale', 'log');
xlabel('SNR(dB)')
ylabel('BER')
title('BER VS SNR Curve');
legend('Location', 'best');
ylim([10^(-5), 1])
hold off;

figure;
hold on;
grid on;
semilogy(SNR_BER_LMMSE(:, 1), SNR_BER_LMMSE(:, 2), '--o', 'LineWidth', 1.5, 'Color', [0, 0.4470, 0.7410], 'MarkerEdgeColor', [0, 0.4470, 0.7410], 'DisplayName', 'Ntr = 2');
semilogy(SNR_BER_LMMSE(:, 3), SNR_BER_LMMSE(:, 4), '--^', 'LineWidth', 1.5, 'Color', [0.4940, 0.1840, 0.5560], 'MarkerEdgeColor', [0.4940, 0.1840, 0.5560], 'DisplayName', 'Ntr = 5');
semilogy(SNR_BER_LMMSE(:, 5), SNR_BER_LMMSE(:, 6), '--s', 'LineWidth', 1.5, 'Color', [0.4660, 0.6740, 0.1880], 'MarkerEdgeColor', [0.4660, 0.6740, 0.1880], 'DisplayName', 'Ntr = 10');
set(gca, 'YScale', 'log');
xlabel('SNR(dB)')
ylabel('BER')
title('BER VS SNR Curve');
legend('Location', 'best');
ylim([10^(-5), 1])
hold off;
