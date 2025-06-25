function frequencySelectiveChannel = generateFrequencySelectiveChannel(numOfChannelTaps, variance)
    frequencySelectiveChannel = zeros(1, numOfChannelTaps);
    for i = 1:numOfChannelTaps
        frequencySelectiveChannel(i) = generateFrequencyFlatChannel(variance);
    end
end
