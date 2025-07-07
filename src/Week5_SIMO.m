listOfNr = [1, 2, 4, 8];
numOfNr = length(listOfNr);

listOfBER = zeros(4, 25);
numOfBER = size(listOfBER, 2);
snrRange = 0:numOfBER-1;

Ex = 1;
M = 16;

numOfIteration = 10000;
numOfSymbol = 100;
lengthOfBitSequence = log2(M)*numOfSymbol;

for idxNr = 1:numOfNr
    Nr = listOfNr(idxNr);
    for idxSNR= 1:numOfBER
        N0 = Ex*10^(-snrRange(idxSNR)/10);
        sumBER = 0;
        for idxIteration = 1:numOfIteration
            bitSequence = generateRandomBitSequence(lengthOfBitSequence);
            s = mapBitsToSymbols(bitSequence, M); % row vector
            h = generateFrequencySelectiveChannel(Nr, 1).'; % column vector 
    
            v = generateAWGN(N0, Nr*numOfSymbol).'; % column vector
            V = reshape(v, Nr, numOfSymbol);
            Y = h*s + V;
            
            w = h; % MRC
            r = (w'*Y)./(w'*h); % row vector
    
            sHat = detectSymbolsWithML(r, M, Ex);
            estimatedBitSequence = mapSymbolsToBits(sHat, M);

            ber = calculateBER(bitSequence, estimatedBitSequence);
            sumBER = sumBER + ber;
        end
        avgBER = sumBER/numOfIteration;
        listOfBER(idxNr, idxSNR) = avgBER;
    end
end

figure;
hold on; 
grid on;

% measured value
markers = {'-s', '-o', '-d', '-^'}; 
colors  = [ 0 0 1;    
            0 0.5 0;  
            1 0 0 
            0.5 0 0.5]; 
modulationNames = ["BPSK", "QPSK", "16-QAM"];
modulationOrders = [2, 4, 16];           
[~, idx]  = ismember(M, modulationOrders);

for i = 1:numOfNr
    nameDisplay = sprintf("Nr = %d, %s", listOfNr(i), modulationNames(idx));
    semilogy(snrRange, listOfBER(i,:), ...
        markers{i}, ...
        'LineWidth', 1.5, ...
        'Color', colors(i, :), ...
        'MarkerEdgeColor', colors(i, :), ...
        'DisplayName', nameDisplay);
end
set(gca, 'YScale', 'log');
xlabel('SNR(dB)')
ylabel('BER')
title('SIMO');
legend('Location', 'best');
ylim([1e-6 1])
hold off;
