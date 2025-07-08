addpath('function/');

listOfNr = [1, 2, 4, 8];
numOfNr = length(listOfNr);

numOfBER = 25;
listOfBerWithRAS = zeros(numOfNr, numOfBER);
listOfBerWithMRC = zeros(numOfNr, numOfBER);
snrRange = 0:numOfBER-1;

Ex = 1;
M = 16;
numOfBeamformingMethod = 2;
numOfIteration = 5000;
numOfSymbol = 100;
lengthOfBitSequence = log2(M)*numOfSymbol;

for idxBeamforming = 1:numOfBeamformingMethod
    for idxNr = 1:numOfNr
        Nr = listOfNr(idxNr);
        for idxSNR= 1:numOfBER
            N0 = Ex*10^(-snrRange(idxSNR)/10);
            sumBER = 0;
            for idxIteration = 1:numOfIteration
                bitSequence = generateRandomBitSequence(lengthOfBitSequence);
                s = mapBitsToSymbols(bitSequence, M); % row vector
                h = generateChannelVector(Nr, 1).'; % column vector 
        
                v = generateAWGN(N0, Nr*numOfSymbol).'; % column vector
                V = reshape(v, Nr, numOfSymbol);
                Y = h*s + V;
                
                switch idxBeamforming
                    case 1
                        % RAS (Receive Antenna Selection)
                        [~, idxOpt] = max(abs(h)); 
                        w = zeros(Nr,1);    
                        w(idxOpt) = h(idxOpt)/abs(h(idxOpt))^2;
                    case 2
                        % MRC (Maximum Ratio Combining)
                        w = h./(h'*h); 
                end  
                r = w'*Y; % row vector
        
                sHat = detectSymbolsWithML(r, M, Ex);
                estimatedBitSequence = mapSymbolsToBits(sHat, M);
    
                ber = calculateBER(bitSequence, estimatedBitSequence);
                sumBER = sumBER + ber;
            end
            avgBER = sumBER/numOfIteration;
            switch idxBeamforming
                case 1
                    listOfBerWithRAS(idxNr, idxSNR) = avgBER;
                case 2
                    listOfBerWithMRC(idxNr, idxSNR) = avgBER;
            end

        end
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

% RAS
for i = 1:numOfNr
    nameDisplay = sprintf("RAS, Nr = %d, %s", listOfNr(i), modulationNames(idx));
    semilogy(snrRange, listOfBerWithRAS(i,:), ...   
        markers{i}, ...
        'LineStyle', ':', ...        
        'LineWidth', 1.5, ...
        'Color', colors(i,:), ...
        'DisplayName', nameDisplay);
end

% MRC
for i = 1:numOfNr
    nameDisplay = sprintf("MRC, Nr = %d, %s", listOfNr(i), modulationNames(idx));
    semilogy(snrRange, listOfBerWithMRC(i,:), ...
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
