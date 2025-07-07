% simulation
addpath('function/');

Ntr = 10;
Ex = 1;
M = 16;
L = 3;

numOfIteration = 1000;
numOfSymbol = 100;
lengthOfBitSequence = log2(M)*numOfSymbol;

SNRdB = 10:5:30;
numOfSNR = length(SNRdB);

listOfLf = [5, 10, 100];
numOfLf = length(listOfLf);
BER = zeros(numOfLf, numOfSNR);

t = generateZadoffChuTrainingSequence(1, Ntr); % 1xNtr row vector
T = generateTrainingMatrix(t, L);
filter = calculateLeftInverse(T);

for i = 1:numOfSNR
    N0 = 10^(-SNRdB(i)/10);
    sumOfBER = zeros(1, numOfLf);
    for j = 1:numOfIteration
        h = generateChannelVector(3, 1/3);
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
            H = toeplitz([hEst ; zeros(Lf-1,1)],[hEst(1), zeros(1,Lf - 1)]); 
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
markers = {'-s', '-s', '-s'}; 
colors  = [ 1      0.4980 0.0549;    
            0.1216 0.4667 0.7059;  
            0.49   0.70   0.26]; 
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
xticks(10:5:30);
set(gca, 'YScale', 'log');
xlabel('SNR(dB)')
ylabel('BER')
title('Frequency Selective');
legend('Location', 'best');
ylim([10^(-4), 1])
hold off;
