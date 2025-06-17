function estimatedSymbolArray = maximumLikelihoodDetection(receivedSignalArray, M, Ex)
    switch M
        case 2,  estimatedsymbolArray = demodulateBPSK(bitSequence);
        case 4, estimatedsymbolArray = demodulateQPSK(bitSequence);
        case 16, estimatedsymbolArray = demodulate16QAM(bitSequence);
        otherwise, error('Unsupported M = %d', M);
    end
end
    % -----------------------------
    l = length(receivedSignalArray);
   
    if M == 2 
        estimatedSymbolArray = ones(1, l); 
        for i = 1:l
            if real(receivedSignalArray(i)) < 0
                estimatedSymbolArray(i) = -1;

            end
        end

    elseif M == 4
        estimatedSymbolArray = sqrt(1/2)*ones(2, l); % row1: real, row2: imag
        for i = 1:l
            if real(receivedSignalArray(i)) < 0
                estimatedSymbolArray(1, i) = -sqrt(1/2);
            end
            if imag(receivedSignalArray(i)) < 0
                estimatedSymbolArray(2, i) = -sqrt(1/2);
            end

        end 
    elseif M == 16 % Ex
        estimatedSymbolArray =   sqrt(1/10)*ones(2, l); % row1: real, row2: imag
        for i = 1:l
            if real(receivedSignalArray(i)) > 2*sqrt(Ex/10)
                estimatedSymbolArray(1, i) = 3*sqrt(1/10);
            elseif real(receivedSignalArray(i)) < -2*sqrt(Ex/10)
                estimatedSymbolArray(1, i) = -3*sqrt(1/10);
            elseif real(receivedSignalArray(i)) < 0
                estimatedSymbolArray(1, i) = -sqrt(1/10);
            end

            if imag(receivedSignalArray(i)) > 2*sqrt(Ex/10)
                estimatedSymbolArray(2, i) = 3*sqrt(1/10);
            elseif imag(receivedSignalArray(i)) < -2*sqrt(Ex/10)
                estimatedSymbolArray(2, i) = -3*sqrt(1/10);
            elseif imag(receivedSignalArray(i)) < 0
                estimatedSymbolArray(2, i) = -sqrt(1/10);
            end
        end


    end 

end

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

function ber = cal_ber(bin_bit_seq, estimated_bit_seq, N)
    error_count = sum(bin_bit_seq ~= estimated_bit_seq);
    ber = error_count/N;
end


    
% main code
addpath('function/');
M = [2, 4, 16];
N0 = 1;
N = 100000;
snr_ber = zeros(17, 6); 

for t = 1:3
    m = M(t);
    for i = 0:16 % 0~16dB
    Ex = 10^(i/10);
    ber_sum = 0;

        for j = 1:100

        b = generateRandomBitSequence(N);
        s = mapBitsToSymbols(b, m, N);
        v = generateAWGN(N0, numel(s));
        y = generateReceivedSignal(s, v, Ex);      

        s_hat = maximumLikelihoodDetection(y, m, Ex);
        est_b = mapSymbolsToBits(s_hat, m);

        ber_sum = ber_sum + cal_ber(b, est_b, N);
        end

    ber_avg = ber_sum/100;
    snr_ber(i+1, 2*t - 1:2*t) = [i, ber_avg];
    end

end
disp(snr_ber)
figure;
hold on;
semilogy(snr_ber(:, 1), snr_ber(:, 2), '-o', 'MarkerEdgeColor', 'b', 'DisplayName', 'BPSK');
semilogy(snr_ber(:, 3), snr_ber(:, 4), '-o', 'MarkerEdgeColor', 'r', 'DisplayName', 'QPSK');
semilogy(snr_ber(:, 5), snr_ber(:, 6), '-o', 'MarkerEdgeColor', 'g', 'DisplayName', '16-QAM');
set(gca, 'YScale', 'log');
xlabel('SNR(dB)')
ylabel('BER')
title('BER VS SNR Curve');
legend('Location', 'best');
ylim([10^(-8), 1])
hold off;

% 3 repetitions
M = [2, 4, 16];
N0 = 1;
N = 100000;
snr_ber = zeros(17, 6); 
N_3 = 3*100000;

for t = 1:3
    m = M(t);
    for i = 0:16 % 0~16dB
    Ex = 10^(i/10);
    ber_sum = 0;

        for j = 1:100

        b = generateRandomBitSequence(N);
        b_3 = repelem(b, 3);
        s_3 = mapBitsToSymbols(b_3, m, N_3);
        v_3 = generateAWGN(N0, numel(s_3));
        y_3 = generateReceivedSignal(s_3, v_3, Ex);      

        s_hat_3 = maximumLikelihoodDetection(y_3, m, Ex);
        est_b_3 = mapSymbolsToBits(s_hat_3, m);

        est_b = zeros(1, N);

        for k = 1:N
            count = est_b_3(3*k - 2) + est_b_3(3*k - 1) + est_b_3(3*k);
            if count >= 2
                est_b(k) = 1;
            end 
        end 

        ber_sum = ber_sum + cal_ber(b, est_b, N);
        end

    ber_avg = ber_sum/100;
    snr_ber(i+1, 2*t - 1:2*t) = [i, ber_avg];
    end

end

figure;
hold on;
semilogy(snr_ber(:, 1), snr_ber(:, 2), '-o', 'MarkerEdgeColor', 'b', 'DisplayName', 'BPSK');
semilogy(snr_ber(:, 3), snr_ber(:, 4), '-o', 'MarkerEdgeColor', 'r', 'DisplayName', 'QPSK');
semilogy(snr_ber(:, 5), snr_ber(:, 6), '-o', 'MarkerEdgeColor', 'g', 'DisplayName', '16-QAM');
set(gca, 'YScale', 'log');
xlabel('SNR(dB)')
ylabel('BER')
title('BER VS SNR Curve (3 repetitions)');
legend('Location', 'best');
ylim([10^(-8), 1])
hold off;
