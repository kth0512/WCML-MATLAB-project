function equalizedSymbolArray = equalizeFreqFlatChannel(receivedSignal, estimatedChannel)
    equalizedSymbolArray = receivedSignal./estimatedChannel;
end

