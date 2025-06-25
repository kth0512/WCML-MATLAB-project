function ndOptimal = findOptimalEqualizerDelay(H, Lf)
    ndOptimal = 0;
    Jmin = inf;
    I = eye(Lf);
    projectionMatrix = H*calculateLeftInverse(H);
    for nd = 0:Lf-1
        e = zeros(Lf,1);  
        e(nd+1)=1;
        J = norm((projectionMatrix - I)*e, 2)^2;
        if (J < Jmin)
            Jmin = J;
            ndOptimal = nd;
        end     
    end
end
