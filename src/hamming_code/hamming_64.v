`ifndef HAMMING_64_V
`define HAMMING_64_V

`include "hamming_generator.v"

        module hamming_64 (
            input [31:0] in_word,
            output [63:0] padded_word,
            output overflow
          );
          wire [7:0] w0,w1,w2,w3,w4,w5,w6,w7;
          wire c0,c1,c2,c3,c4,c5,c6,c7;
          hamming_generator hg0(in_word[3:0],w0,c0);
          hamming_generator hg1(in_word[7:4],w1,c1);
          hamming_generator hg2(in_word[11:8],w2,c2);
          hamming_generator hg3(in_word[15:12],w3,c3);
          hamming_generator hg4(in_word[19:16],w4,c4);
          hamming_generator hg5(in_word[23:20],w5,c5);
          hamming_generator hg6(in_word[27:24],w6,c6);
          hamming_generator hg7(in_word[31:28],w7,c7);
          assign overflow=c0&c1&c2&c3&c4&c5&c6&c7;
          assign padded_word = {w7,w6,w5,w4,w3,w2,w1,w0};

        endmodule

`endif
