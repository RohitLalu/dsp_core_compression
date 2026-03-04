module clz (
    input enable,
    input wire [31:0] in,
    output reg [4:0] count,
    output valid_op
);
        pri_enc pri_enc_inst (
            .en(enable),
            .data_i(in),
            .index_o(count)
        );
        assign valid_op=enable; // Output is valid when enable is high
endmodule