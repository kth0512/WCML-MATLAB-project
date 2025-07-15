addpath('function/');

listOfAntennaNumber = [2, 4];
numofAntennaNumber = length(listOfAntennaNumber);

snrRange = 0:3:30;
numOfSNR = length(snrRange);

listOfBer = zeros(numofAntennaNumber^2, numOfSNR);

Ex = 1;
M = 16;
numOfIteration = 1000;
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
                [U, Lambda, V] = svd(H, 'econ');
                lambda = diag(Lambda);
                rootPower = waterFillingAllocation(lambda, Ex, N0);
                Ns = size(rootPower, 2);
                F = V(1:Ns, 1:Ns)*rootPower;
                W = U(1:Ns, 1:Ns);
                slotNumber = ceil(numOfSymbol/Ns);
                numOfPaddedSymbols = Ns*slotNumber - numOfSymbol;
                
                % 차원 확실히 체크
                b = generateRandomBitSequence(lengthOfBitSequence);
                s = [mapBitsToSymbols(b, M); zeros(1, numOfPaddedSymbols)];
                v = generateAWGN(N0, Ns*slotNumber);
                S = reshape(s, Ns, slotNumber);
                V = reshape(v, Ns, slotNumber);
                R = W'*H*F*S + W'*V;
                r = reshape(R, 1, Ns*slotNumber);
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
colors  = [ 0 0 1;    
            0 0.5 0;  
            1 0 0 
            0.5 0 0.5]; 
modulationNames = ["BPSK", "QPSK", "16-QAM"];
modulationOrders = [2, 4, 16];           
[~, idx]  = ismember(M, modulationOrders);

for i = 1:numOfNt
    for j = 1:numOfNr
        idx = (i-1)*numofAntennaNumber+j;
        nameDisplay = sprintf("Nt = %d, Nr = %d, %s", listOfAntennaNumber(i), listOfAntennaNumber(j), modulationNames(idx));
        semilogy(snrRange, listOfBer(idx,:), ...   
            markers{idx}, ...
            'LineStyle', ':', ...        
            'LineWidth', 1.5, ...
            'Color', colors(idx,:), ...
            'DisplayName', nameDisplay);
    end
end

set(gca, 'YScale', 'log');
xlabel('SNR(dB)')
ylabel('BER')
title('MIMO');
legend('Location', 'best');
ylim([1e-6 1])
hold off;
