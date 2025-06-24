% simulation
addpath('function/');
Ntr = 10;
numOfIteration = 1000;
Ex = 1;
M = 16;
lengthOfBitSequence = log2(M)*100;
numOfSymbol = 100;
numOfSNR = 5;
SNR_BER_LS = zeros(numOfSNR, 2);
SNR_BER_LS(:, 1) = [10, 15, 20, 25, 30]; % [10, 15, 20, 25, 30] <- dB or not?
L = 3;
channelTaps = zeros(L);

t = generateZadoffChuTrainingSequence(1, Ntr); % 1xNtr row vector
T = generateTrainingMatrix(t, L);

for i = 1:numOfSNR
    N0 = 10^(-SNR_BER_LS(i, 1)/10);
    sumOfBER = 0;
    for j = 1:numOfIteration
        
    end
end

