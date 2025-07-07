function ber = calculateBER(originalBitSequence, estimatedBitSequence)
    length = numel(estimatedBitSequence);
    errorCount = sum(originalBitSequence ~= estimatedBitSequence, 'all');
    ber = errorCount/length;
end
