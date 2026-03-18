
`ifndef FULL_ADDER_V
`define FULL_ADDER_V

        module full_adder (
            input a,
            input b,
            input cin,
            output sum,
            output carry
          );
          wire common;
          assign common=a^b;
          assign sum=common^cin;
          assign carry=a&b|common&cin;

        endmodule

`endif
