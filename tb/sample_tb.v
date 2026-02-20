`include "~/Desktop/dsp_core_compression/rtl/sample.v"

module sample_tb;

reg a;
reg b;
wire c;

uut sample s1(
    .a(a),
    .b(b),
    .c(c)
);

initial begin
    a = 0;
    b = 0;
    #10;
    
    a = 0;
    b = 1;
    #10;
    
    a = 1;
    b = 0;
    #10;
    
    a = 1;
    b = 1;
    #10;
    
    $finish;
end

endmodule
