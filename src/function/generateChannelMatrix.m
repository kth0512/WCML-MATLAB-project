function H = generateChannelMatrix(numOfRows, numOfColunms, variance)
    H = sqrt(variance/2)*(randn(numOfRows, numOfColunms)+1i*randn(numOfRows, numOfColunms));
end

