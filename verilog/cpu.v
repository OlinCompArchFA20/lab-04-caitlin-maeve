`include "fetch.v"
`include "decode.v"
`include "regfile.v"
`include "alu.v"
`include "memory.v"

`timescale 1ns / 1ps

module SINGLE_CYCLE_CPU
  (input clk,
   input rst);

reg ALUcntrl;
reg [`W_CPU-1:0] rd1;
reg [`W_CPU-1:0] rd2;
reg [`W_IMM-1:0] imm_extend;
reg [`W_CPU-1:0] imm_extended;
reg [`W_CPU-1:0] ALUa; //outputs from reg file, input to alu
reg [`W_CPU-1:0] ALUb; //outputs from reg file, input to alu
reg [`PC_UPPER-1:0] PC;

// TO DO
// - Change from posedge clk to always @* begin
// - Make reg for ALU results
// - Instantiate values
// - Finish case implementation

// DESIGN NOTES
// - 

// QUESTIONS
// - Do 

// instatiate (ALU, Reg File, Mem)
ALU #(.DLY(DLY)) slice_inst(ALUcntrl, ALUa, ALUb, result, overflow, isZero);
assign R = result;
 #(.DLY(DLY)) slice_inst(ALUcntrl, ALUa, ALUb, result, overflow, isZero);
// Check overflow - IGNORING
// xor #DLY xoroverflow(overflow, carry[W-1], carry[W]);
// assign cout = overflow;

always @* begin
  case(alu_src); // assign ALU B input
    `ALU_SRC_SHA : ALUb = `W_CPU'(inst[`FLD_SHAMT]); // TODO fix so that this is an input of alu
    `ALU_SRC_IMM : ALUb = imm_extended;
    `ALU_SRC_REG : ALUb = rd2;
    default: ALUb = rd2;
  endcase
  end

  always @* begin
   case(reg_src);
   // TODO, what is regsrc?
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
