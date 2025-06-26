% simulation
addpath('function/');
listOfNtr = [2, 5, 10];
numOfNtr = numel(listOfNtr);
numOfIteration = 100000;
Ex = 1;
M = 16;
lengthOfBitSequence = log2(M)*100;
numOfSymbol = 100;
SNR_BER = zeros(41, 6);


for i = 1:numOfNtr
    Ntr = listOfNtr(i);
    t = sqrt(Ex)*generateZadoffChuTrainingSequence(1, Ntr);
    filterFor = conj(t)/(t*t');
    for j = 0:40 
        N0 = 10^(-j/10);
        sumOfBER = 0;
        for k = 1:numOfIteration
            % transmit symbol signal s and receive signal y
            h = generateFrequencyFlatChannel(1);
            bitSequence = generateRandomBitSequence(lengthOfBitSequence);
            s = mapBitsToSymbols(bitSequence, M);
            v = generateAWGN(N0, numOfSymbol+Ntr);
            symbolWithTraining = [t s];
            y = generateReceivedSignalInFreqFlat(symbolWithTraining, v, Ex, h);
            yTraining = y(1:Ntr);

            % estimate h with Least Square and equalize channel effect
            hHat = channelEstimation(filterFor, yTraining.'); 
            yEq = equalizeFreqFlatChannel(y, hHat);
            sHat = detectSymbolsWithML(yEq(Ntr+1:numOfSymbol+Ntr), M, Ex);
            estimatedBitSequence = mapSymbolsToBits(sHat, M);

            % calculate BER
            BER = calculateBER(bitSequence, estimatedBitSequence);
            sumOfBER = sumOfBER + BER;
        end
        averageOfBER = sumOfBER/numOfIteration;
        SNR_BER(j+1, 2*i-1:2*i) = [j, averageOfBER];
    end
end

% plot BER VS SNR(dB) Curve
figure;
hold on; 
grid on;

% measured value
markers = {'-o', '-^', '-s'}; 
colors  = [  0    0.4470 0.7410;    
            0.4940 0.1840 0.5560;  
            0.4660 0.6740 0.1880]; 
modulationNames = ["BPSK", "QPSK", "16-QAM"];
modulationOrders = [2, 4, 16];           
[~, idx]  = ismember(M, modulationOrders);

for i = 1:numOfNtr
    nameDisplay = sprintf("Ntr = %d, %s, LS", listOfNtr(i), modulationNames(idx));
    semilogy(SNR_BER(:, 2*i - 1), SNR_BER(:, 2*i), ...
        markers{i}, ...
        'LineWidth', 1.5, ...
        'Color', colors(i, :), ...
        'MarkerEdgeColor', colors(i, :), ...
        'DisplayName', nameDisplay);
end

% theoretical value
SNR_Range = 0:40;                             
SNR_Linear = 10.^(SNR_Range/10);

theoreticalBPSK = 0.5 * (1 - sqrt(SNR_Linear ./ (1 + SNR_Linear)));
semilogy(SNR_Range, theoreticalBPSK, ...
    'LineStyle', '--', ...
    'Color',       [0.8500, 0.3250, 0.0980], ...
    'LineWidth',   1.5, ...
    'DisplayName','theoretical BPSK');

theoreticalQPSK = 0.5 * (1 - sqrt(SNR_Linear ./ (2 + SNR_Linear)));
semilogy(SNR_Range, theoreticalQPSK, ...
    'LineStyle', '--', ...
    'Color',       [0.0000, 0.6000, 0.7000], ...
    'LineWidth',   1.5, ...
    'DisplayName','theoretical QPSK');

set(gca, 'YScale', 'log');
xlabel('SNR(dB)')
ylabel('BER')
title('Frequency Flat BER VS SNR');
legend('Location', 'best');
ylim('auto')
hold off;
