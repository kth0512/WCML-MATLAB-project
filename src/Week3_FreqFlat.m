addpath('function/');
ListOfNtr = [2, 5, 10];
numOfNtr = numel(ListOfNtr);
numOfIteration = 100000;
Ex = 1;
M = 16;
lengthOfBitSequence = 4*100;
numOfSymbol = 100;
SNR_BER_LS = zeros(41, 6);

for i = 1:numOfNtr
    Ntr = ListOfNtr(i);
    t = sqrt(Ex)*generateZadoffChuTrainingSequence(1, Ntr);
    filterForLS = (t')/(t*t');
    for j = 0:40 
        N0 = 10^(-j/10);
        sumOfBERLS = 0;
        for k = 1:numOfIteration
            h = generateFrequencyFlatChannel;
            bitSequence = generateRandomBitSequence(lengthOfBitSequence);
            s = mapBitsToSymbols(bitSequence, M);
            v = generateAWGN(N0, numOfSymbol+Ntr);
            symbolWithTraining = [t s];
            y = generateReceivedSignalInFreqFlat(symbolWithTraining, v, Ex, h);
            yTraining = y(1:Ntr);

            % Least Square (LS)
            hHatLS = channelEstimationInFreqFlat(filterForLS, yTraining); 
            yEqLS = equalizeFreqFlatChannel(y, hHatLS);
            sHatLS = detectSymbolsWithML(yEqLS(Ntr+1:numOfSymbol+Ntr), M, Ex);
            estimatedBitSequenceLS = mapSymbolsToBits(sHatLS, M);
            BERLS = calculateBER(bitSequence, estimatedBitSequenceLS);
            sumOfBERLS = sumOfBERLS + BERLS;
        end
        % Least Square
        averageOfBERLS = sumOfBERLS/numOfIteration;
        SNR_BER_LS(j+1, 2*i-1:2*i) = [j, averageOfBERLS];
    end
end

disp(SNR_BER_LS)
figure;
hold on;
grid on;

semilogy(SNR_BER_LS(:, 1), SNR_BER_LS(:, 2), '-o', 'LineWidth', 1.5, 'Color', [0, 0.4470, 0.7410], 'MarkerEdgeColor', [0, 0.4470, 0.7410], 'DisplayName', 'Ntr = 2, LS');
semilogy(SNR_BER_LS(:, 3), SNR_BER_LS(:, 4), '-^', 'LineWidth', 1.5, 'Color', [0.4940, 0.1840, 0.5560], 'MarkerEdgeColor', [0.4940, 0.1840, 0.5560], 'DisplayName', 'Ntr = 5, LS');
semilogy(SNR_BER_LS(:, 5), SNR_BER_LS(:, 6), '-s', 'LineWidth', 1.5, 'Color', [0.4660, 0.6740, 0.1880], 'MarkerEdgeColor', [0.4660, 0.6740, 0.1880], 'DisplayName', 'Ntr = 10, LS');

% ideal value
SNR_Range = 0:40;                             
SNR_Linear = 10.^(SNR_Range/10);

theoreticalBPSK = 0.5 * (1 - sqrt(SNR_Linear ./ (1 + SNR_Linear)));
semilogy(SNR_Range, theoreticalBPSK, 'k--', ...
    'LineWidth',1.5, 'DisplayName','theoretical BPSK');

theoreticalQPSK = 0.5 * (1 - sqrt(SNR_Linear ./ (2 + SNR_Linear)));
semilogy(SNR_Range, theoreticalQPSK, 'm--', ...
    'LineWidth',1.5, 'DisplayName','theoretical QPSK');


set(gca, 'YScale', 'log');
xlabel('SNR(dB)')
ylabel('BER')
title('BER VS SNR Curve');
legend('Location', 'best');
ylim('auto')
hold off;
