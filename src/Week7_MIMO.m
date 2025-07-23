addpath('function/');

listOfAntennaNumber = [2, 4];
numofAntennaNumber = length(listOfAntennaNumber);

snrRange = 0:3:30;
numOfSNR = length(snrRange);

listOfBer = zeros(numofAntennaNumber^2, numOfSNR);

Ex = 1;
M = 16;
numOfIteration = 100000;
numOfSymbol = 100;
lengthOfBitSequence = log2(M)*numOfSymbol;

for idxNt = 1:numofAntennaNumber
    Nt = listOfAntennaNumber(idxNt);
    for idxNr = 1:numofAntennaNumber 
        Nr = listOfAntennaNumber(idxNr);
        for idxSNR = 1:numOfSNR
            N0 = Ex*10^(-snrRange(idxSNR)/10);
            sumBER = 0;
            for idxIteration = 1:numOfIteration
                H = generateChannelMatrix(Nr, Nt, 1);
                [U, S, V] = svd(H, 'econ');
                lambda = diag(S);
                [rootPower, idxActive] = waterFillingAllocation(lambda, Ex, N0);
                Ns = sum(idxActive);
                F = V(:, idxActive)*rootPower;
                W = U(:, idxActive);
                slotNumber = ceil(numOfSymbol/Ns);
                numOfPaddedSymbols = Ns*slotNumber - numOfSymbol;
                    
                b = generateRandomBitSequence(lengthOfBitSequence);
                s = [mapBitsToSymbols(b, M), zeros(1, numOfPaddedSymbols)];
                v = generateAWGN(N0, Nr*slotNumber);
                symbolMatrix = reshape(s, Ns, slotNumber);
                noiseMatrix = reshape(v, Nr, slotNumber);
                R = W'*H*F*symbolMatrix + W'*noiseMatrix;

                lambdaActive = lambda(idxActive);
                gainVector = diag(rootPower).*lambdaActive;
                Req = R./gainVector;
                r = reshape(Req, 1, Ns*slotNumber);
                rSymbol = r(1:numOfSymbol);

                sHat = detectSymbolsWithML(rSymbol, M, Ex);
                bHat = mapSymbolsToBits(sHat, M);

                ber = calculateBER(b, bHat);
                sumBER = sumBER + ber;
            end
            avgBER = sumBER/numOfIteration;
            listOfBer((idxNt-1)*numofAntennaNumber+idxNr, idxSNR) = avgBER;
        end
    end
end

figure;
hold on; 
grid on;

% measured value
markers = {'-s', '-o', '-d', '-^'}; 
colors  = [ 1 0 0;    
            0.4660 0.6740 0.1880;  
            0 0.4470 0.7410 
            0.9290 0.6940 0.1250]; 
modulationNames = ["BPSK", "QPSK", "16-QAM"];
modulationOrders = [2, 4, 16];           
[~, idx]  = ismember(M, modulationOrders);

for i = 1:numofAntennaNumber
    for j = 1:numofAntennaNumber
        idxAntenna = (i-1)*numofAntennaNumber+j;
        nameDisplay = sprintf("Nt = %d, Nr = %d, %s", listOfAntennaNumber(i), listOfAntennaNumber(j), modulationNames(idx));
        semilogy(snrRange, listOfBer(idxAntenna,:), ...   
            markers{idxAntenna}, ...      
            'LineWidth', 1.5, ...
            'Color', colors(idxAntenna,:), ...
            'DisplayName', nameDisplay);
    end
end

set(gca, 'YScale', 'log');
xlabel('SNR(dB)')
ylabel('BER')
title('MIMO');
legend('Location', 'best');
ylim('auto')
hold off;
