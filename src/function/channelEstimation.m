% precondition : filter is L×N, receivedSignal is N×1 (dims match)
% postcondition: estimatedChannel is 1×L, with  estimatedChannel.' = filter*receivedSignal
function estimatedChannel = channelEstimation(filter, receivedSignal)
    estimatedChannel = (filter*receivedSignal).';
end
