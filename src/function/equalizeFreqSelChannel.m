function estimatedSymbols = equalizeFreqSelChannel(f, y, nd, numOfSymbol, Lf)
    lengthOfy = length(y);
    Y = zeros(numOfSymbol, Lf);
    for i = 0:Lf-1
        for j = 1:numOfSymbol
            if 1 <= (-i+j+nd) && (-i+j+nd) <= lengthOfy
                Y(j, i+1) = y(nd-i+j);
            else
                Y(j, i+1) = 0;
            end
        end
    end
    estimatedSymbols = (Y*f).';
end

