function ber = calculateBER(originalBitSequence, estimatedBitSequence)
    length = numel(estimatedBitSequence);
    errorCount = sum(originalBitSequence ~= estimatedBitSequence);
    ber = errorCount/length;
end
