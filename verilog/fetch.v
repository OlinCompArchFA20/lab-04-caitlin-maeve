`include "lib/opcodes.v"
`include "lib/debug.v"
`timescale 1ns / 1ps

module FETCH
 (input                      clk,
  input                      rst,
  input      [`W_PC_SRC-1:0] pc_src,
  input      [`W_EN-1:0]     branch_ctrl,
  input      [`W_CPU-1:0]    reg_addr,
  input      [`W_JADDR-1:0]  jump_addr,
  input      [`W_IMM-1:0]    imm_addr,
  output reg [`W_CPU-1:0]    pc_next);


  always @(posedge clk, posedge rst) begin
    if (rst) begin
      pc_next <= `W_CPU'd0;
    end
    else begin
      case(pc_src)
      //`PC_SRC_NEXT : begin pc_next = pc_next + 4; end
      `PC_SRC_BRCH : begin
      if (branch_ctrl == 1'b1) begin
      pc_next = pc_next + 4 + (`W_CPU(imm_addr)<<2); //{14'b{imm_addr[`W_CPU-`W_IMM_EXT], imm_addr, 2'b0}; // TODO fix syntax
      end else begin
      pc_next = pc_next + 4;
      end
      end
      `PC_SRC_JUMP : begin
      pc_next = {pc_next[`PC_UPPER], jump_addr, `W_WORD'b0};
      end
      `PC_SRC_REGF : begin
      pc_next = reg_addr;
      end
        default     :  begin
        pc_next <= pc_next + 4; end
      endcase
      if (`DEBUG_PC && ~rst)
        $display("-- PC, PC/4 = %x, %d",pc_next,pc_next/4);
    end
  end
endmodule
