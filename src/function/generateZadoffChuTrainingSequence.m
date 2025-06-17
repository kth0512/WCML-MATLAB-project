% precondition: M, Np ∈ ℕ && M is relatively prime with Np
% postcondition: zadoffChuTrainingSequence is Zadoff-Chu training sequence (row vector) with length Np
function zadoffChuTrainingSequence = generateZadoffChuTrainingSequence(M, Np)
    n = 0:Np-1;
    if mod(Np, 2) == 0
        zadoffChuTrainingSequence = exp(1i*pi*M*n.^2/Np);
    else
        zadoffChuTrainingSequence = exp(1i*pi*M*n.*(n+1)/Np);
    end


