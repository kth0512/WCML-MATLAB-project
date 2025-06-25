function ndOptimal = findOptimalEqualizerDelay(H, Lf, L)
    ndOptimal = 0;
    Jmin = inf;
    I = eye(Lf+L-1);
    projectionMatrix = H*calculateLeftInverse(H);
    for nd = 0:Lf+L-2
        e = zeros(Lf+L-1,1);  
        e(nd+1)=1;
        J = norm((projectionMatrix - I)*e, 2)^2;
        if (J < Jmin)
            Jmin = J;
            ndOptimal = nd;
        end     
    end
end
