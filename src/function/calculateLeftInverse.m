function leftInverse = calculateLeftInverse(A)
    leftInverse = (A'*A)\(A');
end