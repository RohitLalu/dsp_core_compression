module unpacker (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [63:0] packet_i,
    input  wire        valid_i,
    output reg  [31:0] payload_o,
    output reg         payload_valid_o,
    output reg         single_error_o, // Corrected
    output reg         double_error_o  // Unrecoverable
);
    
    wire [31:0] d = packet_i[31:0]; //actual data bits
    wire [6:0]  received_p = packet_i[54:48]; // 7 bits of parity
    
    // Syndrome Calculation (Simplified for 32-bit data)
    // Each S bit is an XOR of specific data bits and the received parity bit
    // need to look up the specific bits for a (63, 57) code, but here's a general idea:
    wire [5:0] s;
    assign s[0] = d[0]^d[1]^d[3]^d[4]^d[6]^d[8]^d[10]^d[11]^d[13]^d[15]^d[17]^d[19]^d[21]^d[23]^d[25]^d[26]^d[28]^d[30] ^ received_p[0];
    assign s[1] = d[0]^d[2]^d[3]^d[5]^d[6]^d[9]^d[10]^d[12]^d[13]^d[16]^d[17]^d[20]^d[21]^d[24]^d[25]^d[27]^d[28]^d[31] ^ received_p[1];
    assign s[2] = d[0]^d[2]^d[4]^d[5]^d[7]^d[9]^d[11]^d[12]^d[14]^d[16]^d[18]^d[20]^d[22]^d[24]^d[26]^d[28]^d[30] ^ received_p[2];
    assign s[3] = d[0]^d[3]^d[4]^d[7]^d[8]^d[11]^d[12]^d[15]^d[16]^d[19]^d[20]^d[23]^d[24]^d[27]^d[28]^d[31] ^ received_p[3];
    assign s[4] = d[1]^d[3]^d[4]^d[6]^d[8]^d[10]^d[12]^d[14]^d[16]^d[18]^d[20]^d[22]^d[24]^d[26]^d[28]^d[30] ^ received_p[4];
    assign s[5] = d[1]^d[3]^d[5]^d[7]^d[9]^d[11]^d[13]^d[15]^d[17]^d[19]^d[21]^d[23]^d[25]^d[27]^d[29]^d[31] ^ received_p[5];

    // Error Correction Logic
    always @(posedge clk) begin
        if (!rst_n) begin
            payload_o <= 32'b0;
            {single_error_o, double_error_o} <= 2'b0;
        end else if (valid_i) begin
            if (s == 6'b0) begin
                payload_o <= d; // Data is perfect
                {single_error_o, double_error_o} <= 2'b0;
            end else begin
                // Flip the bit at position 's' to correct it
                // In a real DSP, you'd use a decoder to flip the specific bit in 'd'
                payload_o <= d ^ (1 << (s-1)); 
                single_error_o <= 1'b1;
                if (s != 6'b0) begin
                    double_error_o <= 1'b1; // Unrecoverable error
                end else begin
                    double_error_o <= 1'b0;
                end
            end
            payload_valid_o <= 1'b1;
        end else begin
            payload_valid_o <= 1'b0;
        end
    end
endmodule