% simulation
addpath('function/');

Ntr = 10;
Ex = 1;
M = 16;
L = 3;

lengthOfBitSequence = log2(M)*100;
numOfIteration = 100000;
numOfSymbol = 100;
numOfSNR = 5;
numOfLf = 2;

SNRdB = 10:5:30; % dB or not?
BER = zeros(numOfLf, numOfSNR);
listOfLf = [5, 10];

t = generateZadoffChuTrainingSequence(1, Ntr); % 1xNtr row vector
T = generateTrainingMatrix(t, L);
filter = calculateLeftInverse(T);

for i = 1:numOfSNR
    N0 = 10^(-SNRdB(i)/10);
    sumOfBER = zeros(1, numOfLf);
    for j = 1:numOfIteration
        h = generateFrequencySelectiveChannel(3, 1/3);
        bitSequence = generateRandomBitSequence(lengthOfBitSequence);
        s = mapBitsToSymbols(bitSequence, M);
        v = generateAWGN(N0, numOfSymbol+Ntr+L-1);
        t_s = [t s];
        y = generateReceivedSignalInFreqSel(t_s, v, h);
        yforChannelEst = y(L:Ntr);
        hEst = channelEstimation(filter, yforChannelEst.').';
        
        for k = 1:numOfLf
            Lf = listOfLf(k);
            % calculate equalizer
            H = toeplitz([hEst ; zeros(Lf-1,1)],[hEst(1), zeros(1,Lf - 1)]); % 여기까지 굿
            ndOptimal = findOptimalEqualizerDelay(H, Lf, L);
            f_nd_LS = calculateLeastSquareEqualizer(H, ndOptimal, Lf, L); %  Lf x 1 column vector

            % perform equalization
            equalizedSignal = equalizeFreqSelChannel(f_nd_LS, y(Ntr+1:end), ndOptimal, numOfSymbol, Lf);
            sHat = detectSymbolsWithML(equalizedSignal, M, Ex);
            estimatedBitSequence = mapSymbolsToBits(sHat, M);
           
            sumOfBER(k) = sumOfBER(k) + calculateBER(bitSequence, estimatedBitSequence); 
        end

    end
    averageOfBER = sumOfBER/numOfIteration;
    for l = 1:numOfLf
        BER(l, i) = averageOfBER(l);
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

for i = 1:numOfLf
    nameDisplay = sprintf("Lf = %d, %s, LS", listOfLf(i), modulationNames(idx));
    semilogy(SNRdB, BER(i,:), ...
        markers{i}, ...
        'LineWidth', 1.5, ...
        'Color', colors(i, :), ...
        'MarkerEdgeColor', colors(i, :), ...
        'DisplayName', nameDisplay);
end

set(gca, 'YScale', 'log');
xlabel('SNR(dB)')
ylabel('BER')
title('Frequency Selective');
legend('Location', 'best');
ylim([10^(-4), 1])
hold off;
