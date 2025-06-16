function bin_bit_seq = random_bit_seq_generating
    bin_bit_seq = randi([0 1], 1, 1024);
end

function s_array = symbol_mapping(b, M)
    s_array = [];
     if M == 2
         for i = 1:1024
             s_array = [s_array, 2*b(i)-1];
         end
     elseif M == 4
         coeffcient = [1/sqrt(2), -1/sqrt(2)];
         for i = 1:2:1024
             s_array = [s_array, coeffcient(b(i+1)+1)+1i*coeffcient(b(i)+1)];  
         end
     elseif M == 16
         coeffcient = [3/sqrt(10), 1/sqrt(10); -3/sqrt(10), -1/sqrt(10)];
         for i = 1:4:1024
             real_index = coeffcient(2-b(i), 1+b(i+1));
             imag_index = coeffcient(1+b(i+2), 1+b(i+3));
             s_array = [s_array, real_index+1i*imag_index];
         end
    end
end

function v_array = awgn_generating(N0, M) 
    v_array = [];
    N = 1024/log2(M);
    for i = 1:N
        re_v = normrnd(0, sqrt(N0/2));
        im_v = normrnd(0, sqrt(N0/2));
        v_array = [v_array, re_v + 1i*im_v];
    end
end 

function y_array = received_signals_generating(s_array, v_array, E_x)
    y_array = sqrt(E_x)*s_array + v_array;
end

% main code
M = [2, 4, 16];
Ex_N0 = [1, 1; 10, 10; 1, 0.01];

figure;
plot_index = 1;

for m = M
    for i = 1:3
        Ex = Ex_N0(i, 1);
        N0 = Ex_N0(i, 2);
        
        b = random_bit_seq_generating;
        s = symbol_mapping(b, m);
        v = awgn_generating(N0, m);
        y = received_signals_generating(s, v, Ex);

        re = real(y);
        im = imag(y);
        
        subplot(3, 3, plot_index)
        scatter(re, im, 3,'filled');
        xlabel('In-Phase');
        ylabel('Quadrature');
        title('scatter plot')
        
        if N0 == 1
            xlim([-3.5, 3.5])
            ylim([-3.5, 3.5])

        elseif N0 == 10
            xlim([-10.5, 10.5])
            ylim([-10.5, 10.5]) 

        elseif N0 == 0.01
            xlim([-1.5, 1.5])
            ylim([-1.5, 1.5])
        end

        plot_index = plot_index + 1;
    end
end
