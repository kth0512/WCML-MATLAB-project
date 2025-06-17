function receivedSignalArray = generateReceivedSignalInFreqFlat(symbolArray, noiseArray, Ex, h)
    receivedSignalArray = sqrt(Ex)*h*symbolArray + noiseArray;
end
