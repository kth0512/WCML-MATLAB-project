function leastSquareEqualizer = calculateLeastSquareEqualizer(H, nd)
    e = zeros(Lf,1);  
    e(nd+1)=1;
    leastSquareEqualizer = calculateLeftInverse(H)*e;
end
