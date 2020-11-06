`include "defines.v"
`timescale 1ns / 1ps

module ALU_SLICE
 #(parameter DLY = 5)
  (input [2:0] Ctrl,
   input A, B, Cin,
   output reg R, Cout);

  // Gates and wires go here

  // MUX
  // Update 1'b0 to the appropriate wire from above

//
and #DLY andgate

  always @* begin // for all inputs, block gets executed whenever input values change! (vs assign which gets executed once).
    case (Ctrl)
      `ADD_: begin
      # DLY
      {Cout,R} =  A + B + Cin;
      // R = output wire
      end

      `SUB_:  begin
      {Cout,R} =  A + ~B + Cin;
      // TODO fix...?
      end

      `XOR_:  begin
      R = A ^ B;
      end

      `SLT_:  begin // this is the comparator 
      if (A == 1'b0 & B == 1'b1) begin // if A is less than B
      R = ~A + B + Cin; // TODO fix?
      end
      else
      R = A + ~B + Cin;
      end
      // Co doesn't matter, this is the comparator

      `AND_:  begin
      R = A & B;
      end

      `NAND_: begin
      R = ~(A & B);
      end

      `NOR_:  begin
      R = ~(A | B);
      end

      `OR_:   begin
      R = A | B;
      end
      default: /* default catch */;
    endcase
  end

endmodule
