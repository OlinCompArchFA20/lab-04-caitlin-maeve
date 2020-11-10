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
      default : 
        R = {W_CPU-1(1'b0)};
        overflow = 1'b0;
      // math
      `ADD: begin
        {overflow, R} = A + B;
      end
      `SUB: begin
        {overflow, R} = A + ~B;
      end
      `SLT: begin
        R = {W_CPU-1(1'b0)};
        if (!(A < B)
          R[0] = 1;
        overflow = 1'b0;
      end
      // shifts
      `SLL: begin
        R =
      end
      `SRL: begin
      end
      // gates
      `AND: begin
        R = A & B;
        overflow = 1'b0;
      end
      `NAND: begin
        R = ~(A & B);
        overflow = 1'b0;
      end
      `OR: begin
        R = A | B;
        overflow = 1'b0;
      end
      `NOR: begin
        R = ~(A | B);
        overflow = 1'b0;
      end
      `XOR: begin
        R = A ^ B;
        overflow = 1'b0;
      end
    endcase
  end
endmodule
