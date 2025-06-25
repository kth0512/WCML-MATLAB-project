function receivedSignal = generateReceivedSignalInFreqSel(symbolArray, noiseArray, channelTaps)
    receivedSignal = conv(symbolArray, channelTaps, 'same') + noiseArray;
end

