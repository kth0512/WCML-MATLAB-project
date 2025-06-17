function receivedSignalArray = generateReceivedSignalInAWGN(symbolArray, noiseArray, Ex)
    receivedSignalArray = sqrt(Ex)*symbolArray + noiseArray;
end
