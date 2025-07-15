function [rootPower, idxActive] = waterFillingAllocation(lambda, Ex, N0);
    g = N0./(lambda.^2);

    muLow = min(g);
    muHigh = max(g) + Ex;

    tolerance = 1e-8;

    while muHigh - muLow > tolerance
        muMid = 0.5*(muLow + muHigh);
        if (sum(max(0, muMid - g))) > Ex
            muHigh = muMid;
        else
            muLow = muMid;
        end
    end

    muOpt = 0.5*(muLow + muHigh);

    p = max(0, muOpt - g);
    idxActive = p>0;
    rootPower = diag(sqrt(p(idxActive))); 
end

