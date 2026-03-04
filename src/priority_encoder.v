module pri_enc (
    input en,
    input wire [31:0] data_i,
    output reg [4:0] index_o
);
integer i;
    always@(*) begin
        if (en) begin
                    for (i = 31; i >= 0; i = i - 1) begin
        if (!valid && data_i[i]) begin
            index_o  = i[4:0];
        end
    end
    end
end

    
endmodule