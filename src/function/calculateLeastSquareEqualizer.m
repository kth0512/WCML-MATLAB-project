function leastSquareEqualizer = calculateLeastSquareEqualizer(H, nd, Lf, L)
    e = zeros(Lf+L-1,1);  
    e(nd+1)=1;
    leastSquareEqualizer = calculateLeftInverse(H)*e;
end
