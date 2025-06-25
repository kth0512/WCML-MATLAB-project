function receivedSignal = generateReceivedSignalInFreqSel(symbolArray, noiseArray, channelTaps)
    receivedSignal = conv(symbolArray, channelTaps) + noiseArray;
end

