function ndOptimal = findOptimalEqualizerDelay(H, Lf, L)
    I = eye(Lf + L - 1);                    
    P = H * calculateLeftInverse(H);        
    E = P - I;                              
    columnNorms = vecnorm(E, 2, 1);         
    [~, ndOptimal] = min(columnNorms);     
    ndOptimal = ndOptimal - 1;              
end
