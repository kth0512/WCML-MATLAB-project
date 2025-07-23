addpath('function/');

L = 3;
Lc = L-1;
N = 128;
M = 16;
Ex = 1; % freq domain

snrRange = 0:5:30;
numOfSNR = length(snrRange);

listOfBer = zeros(1, numOfSNR);

numOfIteration = 1000;
numOfSymbol = 128;
lengthOfBitSequence = log2(M)*numOfSymbol;


for idxSNR = 1:numOfSNR
    sumOfBER = 0;
    for idxIter = 1:numOfIteration
        
        % Transmitter
        b = generateRandomBitSequence(lengthOfBitSequence);
        S_f = mapBitsToSymbols(b, M);
        s_t = ifft(S_f, N).';

        % Channel
        h = generateChannelVector(L, 1/L).'; % column vector
        h_padded = [h; zeros(N-L,1)];   
        H_circ = gallery('circul', h_padded).';   
        v_bar = generateAWGN(1/(10^(snrRange(idxSNR)/10)), N).'; % frequency domian

        % Receiver
        y_bar = H_circ*s_t + v_bar;
        Y_f = fft(y_bar, N);
        H_f = fft(h_padded, N);
        S_eq = Y_f ./ H_f; 
        SHat = detectSymbolsWithML(S_eq, M, Ex);
        bHat = mapSymbolsToBits(SHat, M);
        
        % BER
        sumOfBER = sumOfBER + calculateBER(b, bHat);    
    end
    avgBER = sumOfBER/numOfIteration;
    listOfBer(idxSNR) = avgBER;
end

%plot 
figure;
hold on; 
grid on;

% measured value
modulationNames = ["BPSK", "QPSK", "16-QAM"];
modulationOrders = [2, 4, 16];           
[~, idx]  = ismember(M, modulationOrders);
     
nameDisplay = sprintf("OFDM, Lc = %d, %s", Lc, modulationNames(idx));
semilogy(snrRange, listOfBer,'-s','LineWidth', 1.5, 'Color', 'b', 'DisplayName', nameDisplay);
  
set(gca, 'YScale', 'log');
xlabel('SNR(dB)')
ylabel('BER')
title('OFDM');
legend('Location', 'best');
ylim('auto')
hold off;
