module subtractor (
    input wire clk,
    input wire rst_n,
    input wire [31:0] data_i,
    input wire valid_i,
    output reg [31:0] residual_o,
    output reg valid_o
);
    reg [31:0] prev_data;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            prev_data  <= 32'b0;
            residual_o <= 32'b0;
            valid_o    <= 1'b0;
        end else if (valid_i) begin
            residual_o <= data_i - prev_data; // The "Predictive" step
            prev_data  <= data_i;            // Update for next cycle
            valid_o    <= 1'b1;
        end else begin
            valid_o    <= 1'b0;
        end
    end
endmodule