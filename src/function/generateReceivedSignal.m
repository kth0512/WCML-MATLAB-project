function receivedSignalArray = generateReceivedSignal(symbolArray, noiseArray, Ex)
    receivedSignalArray = sqrt(Ex)*symbolArray + noiseArray;
end
