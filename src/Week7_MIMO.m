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
            end
        end
    end
end
