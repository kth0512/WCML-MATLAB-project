% simulation
addpath('function/');

Ntr = 10;
Ex = 1;
M = 16;
L = 3;

lengthOfBitSequence = log2(M)*100;
numOfIteration = 1000;
numOfSymbol = 100;
numOfSNR = 5;
numOfLf = 2;

SNRdB = [10, 15, 20, 25, 30]; % [10, 15, 20, 25, 30] <- dB or not?
BER = zeros(numOfLf, numOfSNR);
listOfLf = [5, 10];

t = generateZadoffChuTrainingSequence(1, Ntr); % 1xNtr row vector
T = generateTrainingMatrix(t, L);
filter = calculateLeftInverse(T);

for i = 1:numOfSNR
    N0 = 10^(-SNRdB(i)/10);
    sumOfBER = 0;
    for j = 1:numOfIteration
        h = generateFrequencySelectiveChannel(3, 1/3);
        bitSequence = generateRandomBitSequence(lengthOfBitSequence);
        s = mapBitsToSymbols(bitSequence, M);
        v = generateAWGN(N0, numOfSymbol+Ntr+L-1);
        t_s = [t s];
        y = generateReceivedSignalInFreqSel(t_s, v, h);
        yforChannelEst = y(L:Ntr);
        hEst = channelEstimation(filter, yforChannelEst.');
        
        for Lf = listOfLf
            H = toeplitz([hEst ; zeros(Lf-1,1)],[hEst ; zeros(Lf-1,1)]);

        end
       
    end
    
end

