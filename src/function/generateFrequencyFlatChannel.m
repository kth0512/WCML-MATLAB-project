% precondition: true
% postcondition: frequencyFlatChannel is a 1x1 complex scalar h such that h ~ 𝒞𝒩(0, 1) 
function frequencyFlatChannel = generateFrequencyFlatChannel
    realPartOfChannel = normrnd(0, sqrt(1/2));
    imaginaryPartOfChannel = normrnd(0, sqrt(1/2));
    frequencyFlatChannel = realPartOfChannel + imaginaryPartOfChannel*1i;
end
