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
        s = mapBitsToSymbols(b, m);
        v = generateAWGN(N0, numel(s));
        y = generateReceivedSignalInAWGN(s, v, Ex);      

        s_hat = detectSymbolsWithML(y, m, Ex);
        est_b = mapSymbolsToBits(s_hat, m);

        ber_sum = ber_sum + calculateBER(b, est_b);
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
        s_3 = mapBitsToSymbols(b_3, m);
        v_3 = generateAWGN(N0, numel(s_3));
        y_3 = generateReceivedSignalInAWGN(s_3, v_3, Ex);      

        s_hat_3 = detectSymbolsWithML(y_3, m, Ex);
        est_b_3 = mapSymbolsToBits(s_hat_3, m);

        est_b = zeros(1, N);

        for k = 1:N
            count = est_b_3(3*k - 2) + est_b_3(3*k - 1) + est_b_3(3*k);
            if count >= 2
                est_b(k) = 1;
            end 
        end 

        ber_sum = ber_sum + calculateBER(b, est_b);
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
