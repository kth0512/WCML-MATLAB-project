function frequencySelectiveChannel = generateFrequencySelectiveChannel(numOfChannelTaps, variance)
    frequencySelectiveChannel = zeros(numOfChannelTaps);
    for i = 1:numOfChannelTaps
        frequencySelectiveChannel(i) = generateFrequencyFlatChannel(1/3);
    end
end
