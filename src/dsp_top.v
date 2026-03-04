module dsp_top (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [63:0] packet_in,
    input  wire        valid_in,
    output wire [31:0] compressed_data_out,
    output wire        valid_out,
    output wire        ecc_error        // High if checksum fails
);

    // Internal wires
    wire [31:0] payload;
    wire [31:0] residual;
    wire [5:0]  leading_zeros;

    wire valid_payload;
    wire valid_residual;
    wire single_error;
    wire double_error;
    assign ecc_error = single_error | double_error; // ECC error if either single or double

    //remove it when bit_packer is made
    wire clz_op; // Indicates when CLZ output is valid
    

    // 1. Packet Unpacker & ECC Check logic goes here...
        unpacker unpacker_inst (
            .clk(clk),
            .rst_n(rst_n),
            .packet_i(packet_in),
            .valid_i(valid_in),
            .payload_o(payload),
            .payload_valid_o(valid_payload),
            .single_error_o(single_error),
            .double_error_o(double_error)
        );

    // 2. Subtractor logic goes here...
    subtractor subtractor_inst (
        .clk(clk),
        .rst_n(rst_n),
        .data_i(payload),
        .valid_i(valid_payload),
        .residual_o(residual),
        .valid_o(valid_residual)
    );
    // 3. CLZ logic goes here...
    clz clz_inst (
        .enable(valid_residual),
        .in(residual),
        .count(leading_zeros)
        .valid_op(clz_op)
    );

    // 4. Bit-Packer logic goes here...

    assign valid_out = ~ecc_error & clz_op; // Output is valid if no ECC error and CLZ output is valid

endmodule