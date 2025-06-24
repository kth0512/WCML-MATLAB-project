function trainingMatrix = generateTrainingMatrix(trainingSequence, numOfChannelTaps)
    trainingMatrix = toeplitz(trainingSequence(numOfChannelTaps:end), flip(trainingSequence(1:numOfChannelTaps)));
end
