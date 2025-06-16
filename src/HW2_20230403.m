% WEEK 10 CODE (for experiment, with slight modification)
function bin_bit_seq = random_bit_seq_generating(N)
    bin_bit_seq = randi([0 1], 1, N);
end

function s_array = symbol_mapping(b, M, N)
     if M == 2
         s_array = zeros(1, N);
         for i = 1:N 
             s_array(i) = 2*b(i)-1;
         end
     elseif M == 4
         s_array = zeros(1, N/2);
         coeffcient = [1/sqrt(2), -1/sqrt(2)];
         for i = 1:2:N
             s_array((i+1)/2) = coeffcient(b(i+1)+1)+1i*coeffcient(b(i)+1);  
         end
     elseif M == 16
         s_array = zeros(1, N/4);
         coeffcient = [3/sqrt(10), 1/sqrt(10); -3/sqrt(10), -1/sqrt(10)];
         for i = 1:4:N
             real_index = coeffcient(2-b(i), 1+b(i+1));
             imag_index = coeffcient(1+b(i+2), 1+b(i+3));
             s_array((i+3)/4) = real_index+1i*imag_index;
         end
    end
end

function v_array = awgn_generating(N0, M, N) 
    k = N/log2(M);
    re_v = normrnd(0, sqrt(N0/2), [1, k]);
    im_v = normrnd(0, sqrt(N0/2), [1, k]);
    v_array = re_v + 1i*im_v;
end

function y_array = received_signals_generating(s_array, v_array, E_x)
    y_array = sqrt(E_x)*s_array + v_array;
end

% WEEK 11 CODE
function s_hat_array = ml_detection(y_array, M, Ex)
    l = length(y_array);
   
    if M == 2 
        s_hat_array = ones(1, l); 
        for i = 1:l
            if real(y_array(i)) < 0
                s_hat_array(i) = -1;

            end
        end

    elseif M == 4
        s_hat_array = sqrt(1/2)*ones(2, l); % row1: real, row2: imag
        for i = 1:l
            if real(y_array(i)) < 0
                s_hat_array(1, i) = -sqrt(1/2);
            end
            if imag(y_array(i)) < 0
                s_hat_array(2, i) = -sqrt(1/2);
            end

        end 
    elseif M == 16 % Ex
        s_hat_array =   sqrt(1/10)*ones(2, l); % row1: real, row2: imag
        for i = 1:l
            if real(y_array(i)) > 2*sqrt(Ex/10)
                s_hat_array(1, i) = 3*sqrt(1/10);
            elseif real(y_array(i)) < -2*sqrt(Ex/10)
                s_hat_array(1, i) = -3*sqrt(1/10);
            elseif real(y_array(i)) < 0
                s_hat_array(1, i) = -sqrt(1/10);
            end

            if imag(y_array(i)) > 2*sqrt(Ex/10)
                s_hat_array(2, i) = 3*sqrt(1/10);
            elseif imag(y_array(i)) < -2*sqrt(Ex/10)
                s_hat_array(2, i) = -3*sqrt(1/10);
            elseif imag(y_array(i)) < 0
                s_hat_array(2, i) = -sqrt(1/10);
            end
        end


    end 

end

function estimated_bit_seq = inverse_symbol_mapping(s_hat_array, M)
    if M == 2
        estimated_bit_seq = 0.5*(s_hat_array + 1);

    elseif M == 4
        l = length(s_hat_array);
        estimated_bit_mat = zeros(2, l);
        for i = 1:l
            if s_hat_array(1, i) < 0 % real: -sqrt(1/2)
                estimated_bit_mat(2, i) = 1;
            end 
            if s_hat_array(2, i) < 0
                estimated_bit_mat(1, i) = 1;
            end
        end
        estimated_bit_seq = estimated_bit_mat(:)';
        
                
    elseif M == 16
        l = length(s_hat_array); 
        estimated_bit_mat = zeros(4, l);
        for i = 1:l
            if s_hat_array(1, i) == 3*sqrt(1/10)
                estimated_bit_mat(1, i) = 1;
            elseif s_hat_array(1, i) == sqrt(1/10)
                estimated_bit_mat(1, i) = 1;
                estimated_bit_mat(2, i) = 1;
            elseif s_hat_array(1, i) == -sqrt(1/10)
                estimated_bit_mat(2, i) = 1;
            end

            if s_hat_array(2, i) == sqrt(1/10)
                estimated_bit_mat(4, i) = 1;
            elseif s_hat_array(2, i) == -sqrt(1/10)
                estimated_bit_mat(3, i) = 1;
                estimated_bit_mat(4, i) = 1;
            elseif s_hat_array(2, i) == -3*sqrt(1/10)
                estimated_bit_mat(3, i) = 1;
            end
        end
            
        estimated_bit_seq = estimated_bit_mat(:)';
    end

end 

function ber = cal_ber(bin_bit_seq, estimated_bit_seq, N)
    error_count = sum(bin_bit_seq ~= estimated_bit_seq);
    ber = error_count/N;
end


    
% main code
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

        b = random_bit_seq_generating(N);
        s = symbol_mapping(b, m, N);
        v = awgn_generating(N0, m, N);
        y = received_signals_generating(s, v, Ex);      

        s_hat = ml_detection(y, m, Ex);
        est_b = inverse_symbol_mapping(s_hat, m);

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

        b = random_bit_seq_generating(N);
        b_3 = repelem(b, 3);
        s_3 = symbol_mapping(b_3, m, N_3);
        v_3 = awgn_generating(N0, m, N_3);
        y_3 = received_signals_generating(s_3, v_3, Ex);      

        s_hat_3 = ml_detection(y_3, m, Ex);
        est_b_3 = inverse_symbol_mapping(s_hat_3, m);

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
