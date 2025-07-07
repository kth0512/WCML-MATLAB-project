function channelVector = generateChannelVector(numOfChannelTaps, variance)
    channelVector = zeros(1, numOfChannelTaps);
    for i = 1:numOfChannelTaps
        channelVector(i) = generateFrequencyFlatChannel(variance);
    end
end
