addpath('function/');

listOfNt = [1, 2, 4, 8];
numOfNt = length(listOfNt);

numOfBER = 25;
listOfBerWithSpatialRepetition = zeros(numOfNt, numOfBER);
listOfBerWithMRT = zeros(numOfNt, numOfBER);
snrRange = 0:numOfBER-1;

Ex = 1;
M = 16;
numOfBeamformingMethod = 2;
numOfIteration = 1000;
numOfSymbol = 100;
lengthOfBitSequence = log2(M)*numOfSymbol;

for idxBeamforming = 1:numOfBeamformingMethod
    for idxNt = 1:numOfNt
        Nt = listOfNt(idxNt);
        for idxSNR= 1:numOfBER
            N0 = Ex*10^(-snrRange(idxSNR)/10);
            sumBER = 0;
            for idxIteration = 1:numOfIteration
                bitSequence = generateRandomBitSequence(lengthOfBitSequence);
                s = mapBitsToSymbols(bitSequence, M); % row vector
                h = generateChannelVector(Nt, 1).'; % column vector 
        
                v = generateAWGN(N0, numOfSymbol); % row vector
               
                switch idxBeamforming
                    case 1
                        % Spatital Repetition
                        f = sqrt(Ex/Nt)*ones(Nt, 1);
                    case 2
                        % MRt (Maximum Ratio Transmission)
                        f = sqrt(Ex)*h/norm(h);
                end  
                y = (h'*f)*s + v; % row vector
                yHat = (1/(h'*f))*y;

                sHat = detectSymbolsWithML(yHat, M, Ex);
                estimatedBitSequence = mapSymbolsToBits(sHat, M);

                ber = calculateBER(bitSequence, estimatedBitSequence);
                sumBER = sumBER + ber;
            end
            avgBER = sumBER/numOfIteration;
            switch idxBeamforming
                case 1
                    listOfBerWithSpatialRepetition(idxNt, idxSNR) = avgBER;
                case 2
                    listOfBerWithMRT(idxNt, idxSNR) = avgBER;
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
for i = 1:numOfNt
    nameDisplay = sprintf("SR, Nt = %d, %s", listOfNt(i), modulationNames(idx));
    semilogy(snrRange, listOfBerWithSpatialRepetition(i,:), ...   
        markers{i}, ...
        'LineStyle', ':', ...        
        'LineWidth', 1.5, ...
        'Color', colors(i,:), ...
        'DisplayName', nameDisplay);
end

% MRC
for i = 1:numOfNt
    nameDisplay = sprintf("MRT, Nt = %d, %s", listOfNt(i), modulationNames(idx));
    semilogy(snrRange, listOfBerWithMRT(i,:), ...
        markers{i}, ...
        'LineWidth', 1.5, ...
        'Color', colors(i, :), ...
        'MarkerEdgeColor', colors(i, :), ...
        'DisplayName', nameDisplay);
end

set(gca, 'YScale', 'log');
xlabel('SNR(dB)')
ylabel('BER')
title('MISO');
legend('Location', 'best');
ylim([1e-6 1])
hold off;
