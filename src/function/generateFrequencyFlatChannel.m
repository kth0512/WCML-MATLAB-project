function frequencyFlatChannel = generateFrequencyFlatChannel
    realPartOfChannel = normrnd(0, sqrt(1/2));
    imaginaryPartOfChannel = normrnd(0, sqrt(1/2));
    frequencyFlatChannel = realPartOfChannel + imaginaryPartOfChannel*1i;
end
