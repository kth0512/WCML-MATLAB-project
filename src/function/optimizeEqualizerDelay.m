function ndOptimal = optimizeEqualizerDelay(H, Lf)
    ndOptimal = 0;
    Jmin = inf;
    projectionMatrix = (H/(H'*H))*H';
    I = eye(Lf);
    for nd = 0:Lf-1
        e = zeros(1, Lf);  
        e(nd+1)=1;
        J = norm((projectionMatrix - I)*e, 2)^2;
        if (J < Jmin)
            Jmin = J;
            ndOptimal = nd;
        end     
    end
end
