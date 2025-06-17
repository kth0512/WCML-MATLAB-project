function ber = calculateBER(bin_bit_seq, estimated_bit_seq, N)
    error_count = sum(bin_bit_seq ~= estimated_bit_seq);
    ber = error_count/N;
end
