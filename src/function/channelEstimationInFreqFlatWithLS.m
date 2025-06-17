% precondition: trainingSequence and receivedSingal are row vector with same dimesion.
% postcondition: estimatedChannel is 1x1 complex scalar h_hat determined by least square method.
function estimatedChannel = channelEstimationInFreqFlatWithLS(trainingSequence, receivedSignal)
    estimatedChannel = (receivedSignal*trainingSequence')/(trainingSequence*trainingSequence');
end
