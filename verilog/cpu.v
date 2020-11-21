// TO DO - Add memory
// - Finish case implementation
// - Wire
// - Check types of vars, should they all be reg?
// - Verify:
//    - implementation of sign extend
// DESIGN NOTES
// - Want to call decode for an instruction and get the values
// - Need to use registers for values in mux, otherwise you can't change them (can't use wires)
// - Wires need to be declared outside, and values will update in time for ALU

// QUESTIONS


`include "fetch.v"
`include "decode.v"
`include "regfile.v"
`include "alu.v"
`include "memory.v"

`timescale 1ns / 1ps

module SINGLE_CYCLE_CPU
  (input clk,
   input rst);

// // // ////
// DECODE  //
// // // ////
reg [`W_CPU-1:0] instruction;        // instruction input
// Register
reg [`W_REG-1:0] wa;          // reg write address
reg [`W_REG-1:0] ra1;         // reg read address 1
reg [`W_REG-1:0] ra2;         // reg read address 2
reg reg_wen;                  // reg write enable
// Immediate
reg [`W_IMM_EXT-1:0] imm_ext; // 1-sign or 0-zero extend
reg [`W_IMM-1:0] imm;         // imm field
// Jump Address
reg [`W_JADDR-1:0] addr;      // jump address  field
//  ALU Control
reg [`W_FUNCT-1:0] alu_op;    // alu op
// Muxing
reg [`W_PC_SRC-1:0] pc_src;   // PC source
reg [`W_MEM_CMD-1:0] mem_cmd; // Memory command
reg [`W_ALU_SRC-1:0] alu_src; // ALU Source
reg [`W_REG_SRC-1:0] reg_src; // Mem to Reg
DECODE decode_inst(instruction, wa, ra1, ra2, reg_wen, imm_ext, imm, addr, alu_op, pc_src, mem_cmd, alu_src, reg_src);

// main difference to use registers and wires is that you can modify them in the muxes

// // // ////
// REGFILE //
// // // ////
// clk, rst <- from cpu
// reg_wen, wa, ra1, ra2 <- from decode
// wa is the address (Aw)
// wd is the data (Dw)
reg [`W_CPU-1:0] wd;          // data to write, input
reg [`W_CPU-1:0] rd1;         // Da, to ALU, output
reg [`W_CPU-1:0] rd2;         // Db, to ALUsrc, output
REGFILE reg_inst(clk, rst, reg_wen, wa, wd, ra1, ra2, rd1, rd2);

// // // ////
// / ALU / //
// // // ////
// alu_op <- from decode
// rd1 <- from REGFILE
reg [`W_CPU-1:0] ALUb;        // second ALU input
reg [`W_CPU-1:0] result;      // result, output
reg overflow;                 // overflow, output <- unused
reg isZero;                   // is zero, output <- unused
ALU alu_inst(alu_op, rd1, ALUb, result, overflow, isZero);

// // // ////
//  FETCH  //
// // // ////
// clk, rst <- from cpu
reg [`W_EN-1:0] branch_ctrl;        // unused for now, input
//reg [`W_JADDR-1:0] jump_addr = `W_JADDR'b0;    // unused for now, input
//reg [`W_IMM-1:0] imm;     // related to branch
reg [`W_CPU-1:0] pc_current;     // next_pc, output
reg [`W_CPU-1:0] reg_addr;
FETCH fetch_inst(clk, rst, pc_src, branch_ctrl, reg_addr, addr, imm, pc_current);
// used to be jump_addr

// // // ////
// / MEM / //
// // // ////
// clk, rst <- from cpu, input
// `PC <- PC register, input
// result <- from ALU, input
// instruction <- output
// we define mem_cmd, an input at the top for the decode
reg [`W_CPU-1:0] data_in;     // input, unused
reg [`W_CPU-1:0] data_addr;   // input, output of the ALU
reg [`W_CPU-1:0] data_out;    // data_out, output
//reg [`W_CPU-1:0] instruction; //instruction, output
MEMORY stage_MEMORY(clk, rst, pc_current, instruction, mem_cmd, result, result, data_out);

// // // ///
// Other ///
// // // ///
reg [`W_CPU-1:0] imm_extended; // extended imm

  always @* begin
   case(reg_src) // assigns wd (Dw)
      `REG_SRC_ALU : begin wd = result; end
      `REG_SRC_MEM : begin wd = data_out; end
      `REG_SRC_PC : begin wd = pc_current; end // wd = `PC
     default: begin wd = result; end
   endcase
  end

  always @* begin
  case(alu_src) // assign ALUb
    `ALU_SRC_SHA : begin ALUb = `W_CPU'(instruction[`FLD_SHAMT]); end
    `ALU_SRC_IMM : begin ALUb = imm_extended; end
    `ALU_SRC_REG : begin ALUb = rd2; end
    default: begin ALUb = rd2; end
  endcase
  end

  always @* begin
    case(imm_ext)
      `IMM_SIGN_EXT : begin imm_extended = { {`W_CPU-`W_IMM{imm[`W_IMM-1]}}, imm}; end
      `IMM_ZERO_EXT : begin imm_extended = { {`W_CPU-`W_IMM{1'b0}}, imm}; end // extend with 0s
      default: begin imm_extended = { {`W_CPU-`W_IMM{1'b0}}, imm}; end // extend with 0s
    endcase
  end

  always @* begin
    case(instruction[`FLD_OPCODE])
      `BEQ : begin
      if (isZero == 1) begin
        branch_ctrl = 1'b1;
      end else begin
        branch_ctrl = 1'b0; end
      end
      `BNE : begin
      if (isZero == 0) begin
        branch_ctrl = 1'b1;
      end else begin
        branch_ctrl = 1'b0; end
      end
      default: begin branch_ctrl = 1'b0; end
    endcase
  end

  //SYSCALL Catch
  always @(posedge clk) begin
    if (instruction[`FLD_OPCODE] == `OP_ZERO &&
        instruction[`FLD_FUNCT]  == `F_SYSCAL) begin
        case(rd1)
          1 : $display("SYSCALL  1: a0 = %x",rd2);
          10: begin
              $display("SYSCALL 10: Exiting...");
              $finish;
            end
        endcase
    end
  end

endmodule
