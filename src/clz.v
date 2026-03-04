module clz (
    input enable,
    input wire [31:0] in,
    output reg [4:0] count
);

    always @(*) begin
        pri_enc pri_enc_inst (
            .en(enable),
            .data_i(in),
            .index_o(count)
        );
    end
endmodule