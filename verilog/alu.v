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
      // math
      `F_ADD : begin
        {overflow, R} = A + B;
      end
      `F_ADDU : begin
        {overflow, R} = A + B;
      end
      `F_SUB : begin
        {overflow, R} = A + ~B;
      end
      `F_SUBU : begin
        {overflow, R} = A + ~B;
      end
      `F_SLT : begin
        R = `W_CPU'b0;
        if (A >= B)
        R = `W_CPU'b1;
        overflow = 1'b0;
      end
      `F_SLTU : begin
        R = `W_CPU'b0;
        if (A >= B)
        R = `W_CPU'b1;
        overflow = 1'b0;
      end
      // shifts
      `F_SLL : begin
        R = A << B; // TODO make sure this is correct
        overflow = 1'b0;
      end
      `F_SRL : begin
        R = A >> B;
        overflow = 1'b0;
      end
      `F_SRA : begin
        R = A >>> B;
        overflow = 1'b0;
      end
      // gates
      `F_AND : begin
        R = A & B;
        overflow = 1'b0;
      end
      // `NAND : begin
      //   R = ~(A & B);
      //   overflow = 1'b0;
      // end // note: not included in lab4b list or opcodes.v
      `F_OR : begin
        R = A | B;
        overflow = 1'b0;
      end
      `F_NOR : begin
        R = ~(A | B);
        overflow = 1'b0;
      end
      `F_XOR : begin
        R = A ^ B;
        overflow = 1'b0;
      end
      default : begin
        R =  `W_CPU-1'b0; // TODO check this is the right syntax
        overflow = 1'b0;
      end
    endcase
  end
endmodule
