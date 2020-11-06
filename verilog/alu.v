`include "lib/opcodes.v"
`timescale 1ns / 1ps

module ALU
 (input      [`W_OPCODE-1:0]  alu_op,
  input      [`W_CPU-1:0]     A,
  input      [`W_CPU-1:0]     B,
  output reg [`W_CPU-1:0]     R,
  output reg overflow,
  output reg isZero);


  always @* begin
    case(alu_op)
      default : ;
    endcase
  end

endmodule

# `include "lib/definesALU.v"
# `timescale 1ns / 1ps
# 
# module ALU
#  #(parameter W = 4,
#            DLY = 5)
#   (input     [2:0] Ctrl,// Control word to select operation
#    input      [W-1:0] A,// Input Operand
#    input      [W-1:0] B,// Output Operand
#    output reg [W-1:0] R,// Result
#    output reg      cout,// Was there a carry out? Unsigned overflow
#    output reg overflow);// Result overflowed
# 
#   wire [W:0]   carry;
#   wire [W-1:0] result;
# 
#   reg subtraction; // for two's complement
# 
#   always 0* begin
#     case (Ctrl) // because Ctrl determines what we are doing
#       'ADD_: begin subtraction = 1'b0; end
#       'SUB_: begin subtraction = 1'b1; end // make sure it's signed for 2's
#       default: begin subtraction = 1'b0; end
#     endcase
#   end
# 
#   assin carry[0] = subtraction; // so that we add a 1 or not add a 1
# 
#   generate genvar i;
#     for (i=0;i<W;i=i+1) begin
#       ALU_SLICE #(.DLY(DLY)) slice_inst(Ctrl,A[i],B[i],carry[i],result[i],carry[i+1]);
#     end
#   endgenerate
# 
#   // checking if there is an overflow (we check the last two carrys)
#   xor #DLY xoroverflow(overflow, carry[W-1], carry[W]);
# 
#   // setting cout value to carry
#   assign cout = carry;
# 
#   // setting R value to result
#   assign R = result;
# 
# endmodule
