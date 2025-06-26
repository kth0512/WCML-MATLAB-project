function estimatedSymbols = equalizeFreqSelChannel(f, y, nd, numOfSymbol, Lf)
    lengthOfy = length(y);
    Y = zeros(numOfSymbol, Lf);
    % 1-based
    for i = 1:numOfSymbol
        for j = 1:Lf
            if 1 <= (nd+1+i-j) && (nd+1+i-j) <= lengthOfy
                Y(i, j) = y(nd+1+i-j);
            else
                Y(i, j) = 0;
            end
        end
    end
    estimatedSymbols = (Y*f).';
end

