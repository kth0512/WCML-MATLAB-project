% precondition: length > 0 && N0 >= 0
% postcondition: noiseArray is a 1xlength complex row vector such that each element v is AWGN with variance N0. i.e.) v ~ 𝒞𝒩(0, N0)
function noiseArray = generateAWGN(N0, length)  
    realPart = normrnd(0, sqrt(N0/2), [1, length]);
    imaginaryPart = normrnd(0, sqrt(N0/2), [1, length]);
    noiseArray = realPart + 1i*imaginaryPart;
end 
