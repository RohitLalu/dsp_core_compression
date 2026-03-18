`ifndef HAMMING_GENERATOR_V
`define HAMMING_GENERATOR_V

`include "../full_adder.v"

        //specific block for (7,4) Hamming code generator + 1 special addition which i dont know how to check. could say that bit is for DEC
        //structure is like: 3 bits of error checks, 4 bits of actual transmitted bits, 1 bit of DEC // total 8 bits
        module hamming_generator (
            input [3:0] in_word,
            output [7:0] padded_word,
            output overflow
          );
          wire s0,c0;
          wire s1,c1;
          wire s2,c2;
          wire s3,c3;

          full_adder fa0(in_word[0],in_word[2],in_word[3],s0,c0);
          full_adder fa1(in_word[0],in_word[1],in_word[2],s1,c1);
          full_adder fa2(in_word[1],in_word[2],in_word[3],s2,c2);
          full_adder fa3(c0,c1,c2,s3,c3);

          assign padded_word = {s0,s1,s2,in_word,s3};
          assign overflow=c3;

        endmodule

`endif
