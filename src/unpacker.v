    // Packet Mapping
    // [63:56] Padding (0xAA): 8 bits
    // [55:48] Hamming Parity Bits : 8 bits (7 Hamming + 1 overall parity)
    // [47:32] Extra Padding : 16 bits
    // [31:0]  Payload : 32 bits
    // Using Hamming(39,32) with SECDED (Single Error Correction, Double Error Detection)


module unpacker (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [63:0] packet_i,
    input  wire        valid_i,
    output reg  [31:0] payload_o,
    output reg         payload_valid_o,
    output reg         single_error_o, // Single error detected and corrected
    output reg         double_error_o  // Double error detected (uncorrectable)
);
    
    wire [31:0] data = packet_i[31:0];      // 32-bit data payload
    wire [7:0]  parity_code = packet_i[55:48]; // 8 parity bits (7 Hamming + 1 overall)
    
    // Syndrome Calculation for Hamming(39,32)
    // Parity bits position: P1=p[0], P2=p[1], P4=p[2], P8=p[3], P16=p[4], P32=p[5]
    // Position = data bit index + 1 (1-indexed for Hamming code)
    wire [6:0] syndrome;
    
    // P1: checks positions with bit 0 set (1,3,5,7,9,11,...)
    assign syndrome[0] = data[0]^data[2]^data[4]^data[6]^data[8]^data[10]^data[12]^data[14]^
                         data[16]^data[18]^data[20]^data[22]^data[24]^data[26]^data[28]^data[30] ^ parity_code[0];
    
    // P2: checks positions with bit 1 set (2,3,6,7,10,11,...)
    assign syndrome[1] = data[1]^data[2]^data[5]^data[6]^data[9]^data[10]^data[13]^data[14]^
                         data[17]^data[18]^data[21]^data[22]^data[25]^data[26]^data[29]^data[30] ^ parity_code[1];
    
    // P4: checks positions with bit 2 set (4,5,6,7,12,13,...)
    assign syndrome[2] = data[3]^data[4]^data[5]^data[6]^data[11]^data[12]^data[13]^data[14]^
                         data[19]^data[20]^data[21]^data[22]^data[27]^data[28]^data[29]^data[30] ^ parity_code[2];
    
    // P8: checks positions with bit 3 set (8-15, 24-31)
    assign syndrome[3] = data[7]^data[8]^data[9]^data[10]^data[11]^data[12]^data[13]^data[14]^
                         data[23]^data[24]^data[25]^data[26]^data[27]^data[28]^data[29]^data[30] ^ parity_code[3];
    
    // P16: checks positions with bit 4 set (16-31)
    assign syndrome[4] = data[15]^data[16]^data[17]^data[18]^data[19]^data[20]^data[21]^data[22]^
                         data[23]^data[24]^data[25]^data[26]^data[27]^data[28]^data[29]^data[30] ^ parity_code[4];
    
    // P32: checks all bits (for 32-bit data, checks positions 32+)
    assign syndrome[5] = data[31] ^ parity_code[5];
    
    // Overall parity check (SECDED): all data bits + all parity bits
    wire overall_parity;
    assign overall_parity = ^data ^ ^parity_code[6:0];
    
    // Full syndrome indicates error position (0 = no error)
    wire [6:0] error_pos = syndrome;
    
    // Error detection logic:
    // syndrome==0 && overall_parity==0: No error
    // syndrome!=0 && overall_parity==1: Single-bit error at position 'syndrome'
    // syndrome!=0 && overall_parity==0: Double-bit error (uncorrectable)
    // syndrome==0 && overall_parity==1: Error in parity bits only (single bit error, ignore)
    
    wire single_err = (error_pos != 7'b0) && overall_parity;
    wire double_err = (error_pos != 7'b0) && ~overall_parity;
    
    // Error Correction Logic
    always @(posedge clk) begin
        if (!rst_n) begin
            payload_o <= 32'b0;
            payload_valid_o <= 1'b0;
            {single_error_o, double_error_o} <= 2'b0;
        end else if (valid_i) begin
            payload_valid_o <= 1'b1;
            
            if (single_err) begin
                // Single error: correct it
                payload_o <= data ^ (32'b1 << (error_pos - 1));
                single_error_o <= 1'b1;
                double_error_o <= 1'b0;
            end else if (double_err) begin
                // Double error: cannot correct, output original data
                payload_o <= data;
                single_error_o <= 1'b0;
                double_error_o <= 1'b1;
            end else begin
                // No error detected
                payload_o <= data;
                single_error_o <= 1'b0;
                double_error_o <= 1'b0;
            end
        end else begin
            payload_valid_o <= 1'b0;
        end
    end
endmodule