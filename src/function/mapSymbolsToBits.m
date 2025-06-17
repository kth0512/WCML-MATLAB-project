
function estimatedBitSequence = mapSymbolsToBits(estimatedSymbolArray, M)
    if M == 2
        estimatedBitSequence = 0.5*(estimatedSymbolArray + 1);

    elseif M == 4
        l = length(estimatedSymbolArray);
        estimated_bit_mat = zeros(2, l);
        for i = 1:l
            if estimatedSymbolArray(1, i) < 0 % real: -sqrt(1/2)
                estimated_bit_mat(2, i) = 1;
            end 
            if estimatedSymbolArray(2, i) < 0
                estimated_bit_mat(1, i) = 1;
            end
        end
        estimatedBitSequence = estimated_bit_mat(:)';
        
                
    elseif M == 16
        l = length(estimatedSymbolArray); 
        estimated_bit_mat = zeros(4, l);
        for i = 1:l
            if estimatedSymbolArray(1, i) == 3*sqrt(1/10)
                estimated_bit_mat(1, i) = 1;
            elseif estimatedSymbolArray(1, i) == sqrt(1/10)
                estimated_bit_mat(1, i) = 1;
                estimated_bit_mat(2, i) = 1;
            elseif estimatedSymbolArray(1, i) == -sqrt(1/10)
                estimated_bit_mat(2, i) = 1;
            end

            if estimatedSymbolArray(2, i) == sqrt(1/10)
                estimated_bit_mat(4, i) = 1;
            elseif estimatedSymbolArray(2, i) == -sqrt(1/10)
                estimated_bit_mat(3, i) = 1;
                estimated_bit_mat(4, i) = 1;
            elseif estimatedSymbolArray(2, i) == -3*sqrt(1/10)
                estimated_bit_mat(3, i) = 1;
            end
        end
            
        estimatedBitSequence = estimated_bit_mat(:)';
    end

end 
