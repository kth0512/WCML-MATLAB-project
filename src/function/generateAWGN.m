function noiseArray = generateAWGN(N0, length)  
    realPart = normrnd(0, sqrt(N0/2), [1, length]);
    imaginaryPart = normrnd(0, sqrt(N0/2), [1, length]);
    noiseArray = realPart + 1i*imaginaryPart;
end 
