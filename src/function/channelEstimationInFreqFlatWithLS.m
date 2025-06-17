% precondition: trainingSequence and receivedSingal are row vector.
% postcondition: estimatedChannel is 1x1 complex scalar h_hat determined by least square method.
function estimatedChannel = channelEstimationInFreqFlatWithLS(trainingSequence, receivedSignal)
    estimatedChannel = (trainingSequence*receivedSignal')/(trainingSequence*trainingSequence');
end
