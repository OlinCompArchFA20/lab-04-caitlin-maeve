// TO DO
// - Change from posedge clk to always @* begin
// - Make reg for ALU results
// - Add memory
// - Finish case implementation
// - Make sure all values are initialized
// - Wire
// - Check types of vars, should they all be reg?

// DESIGN NOTES
// - Want to call decode for an instruction and get the values 

// QUESTIONS
// - Do 

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
reg [`W_CPU-1:0] inst;        // instruction input
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
DECODE #(.DLY(DLY)) slice_inst(inst, wa, ra1, ra2, reg_wen, imm_ext, imm, addr, alu_op, pc_src, mem_cmd, alu_src, reg_src);

// // // ////
// REGFILE //
// // // ////
// clk, rst <- from cpu
// reg_wen, wa, ra1, ra2 <- from decode 
reg [`W_CPU-1:0] wd;          // mem to reg, input
reg [`W_CPU-1:0] rd1;         // Da, to ALU, output
reg [`W_CPU-1:0] rd2;         // Db, to ALUsrc, output
REGFILE #(.DLY(DLY)) slice_inst(clk, rst, reg_wen, wa, wd, ra1, ra2, rd1, rd2);

// // // ////
// / ALU / //
// // // ////
// alu_op <- from decode
// rd1 <- from REGFILE
reg [`W_CPU-1:0] ALUb;        // second ALU input
reg [`W_CPU-1:0] result;      // result, output
reg overflow;                 // overflow, output <- unused 
reg isZero;                   // is zero, output <- unused 
ALU #(.DLY(DLY)) slice_inst(alu_op, rd1, ALUb, result, overflow, isZero);

reg [`PC_UPPER-1:0] PC;


always @* begin
  case(alu_src); // assign ALU B input
    `ALU_SRC_SHA : ALUb = `W_CPU'(inst[`FLD_SHAMT]); // TODO fix so that this is an input of alu
    `ALU_SRC_IMM : ALUb = imm_extended;
    `ALU_SRC_REG : ALUb = rd2;
    default: ALUb = rd2;
  endcase
  end

  always @* begin
   case(reg_src); // assigns register inputs
   // TODO, what is regsrc?
      // PC -> pc line
      // ALU -> register destination
      // MEM -> from memory to register
      //
      // Assign Aw, Dw
      `REG_SRC_PC :; // TODO i don't know what to put down for any of these :( can probably ignore pc for now though
      
      `REG_SRC_ALU :; // register_to_store_into = alu_output or something ? what are the names
      `REG_SRC_MEM :; // register_to_store_into = memory_we_just_read
     default:;
   endcase
  end

  always @* begin
    case(imm_ext);
    // zero ->'SIZE'(Value
    // In this Mux we are deciding whether to use sign extend or not (from imm)
      `IMM_SIGN_EXT :; //imm_extended =  // TODO ask what is happening in these, and how it relates to imm16
      `IMM_ZERO_EXT : imm_extended = imm_extend; // I think, like basically nothing happens
      default: imm_extended = imm_extend; // does IMM_ZERO_EXT case by default
    endcase
  end

//  TODO: not sure if this is necessary bc of memory.v file
  // always @(posedge clk) begin
  //   case(mem_cmd);
  //       `MEM_NOP :;
  //       `MEM_READ :;
  //       `MEM_WRITE :;
  //     default:;
  //   endcase
  // end

//   TODO: not sure if this is necessary bc of fetch.v file
  // always @(posedge clk) begin
  //   case(pc_src);
  //       `PC_SRC_NEXT : `W_CPU'(inst[`PC_UPPER]);;
  //       `PC_SRC_BRCH :;
  //       `PC_SRC_JUMP :;
  //       `PC_SRC_REGF :;
  //     default:; // does PC_SRC_NEXT case by default
  //   endcase
  // end

 // add muxes to the cpu file and stuff
// instantiate alu, memory
// wiring things together, wire alu to MEMORY

  //SYSCALL Catch
  always @(posedge clk) begin
    //Is the instruction a SYSCALL?
    if (inst[`FLD_OPCODE] == `OP_ZERO &&
        inst[`FLD_FUNCT]  == `F_SYSCAL) begin
        case(rd1)
          1 : $display("SYSCALL  1: a0 = %x",rd2);
          10: begin
              $display("SYSCALL 10: Exiting...");
              $finish;
            end
          default: //TODO add?;
        endcase
    end
  end

endmodule
