`include "lib/opcodes.v"
`include "lib/debug.v"
`timescale 1ns / 1 ps

module DECODE
 (input [`W_CPU-1:0] inst,

  // Register File control
  output reg [`W_REG-1:0]     wa,      // Register Write Address
  output reg [`W_REG-1:0]     ra1,     // Register Read Address 1
  output reg [`W_REG-1:0]     ra2,     // Register Read Address 2
  output reg                  reg_wen, // Register Write Enable
  // Immediate
  output reg [`W_IMM_EXT-1:0] imm_ext, // 1-Sign or 0-Zero extend
  output reg [`W_IMM-1:0]     imm,     // Immediate Field
  // Jump Address
  output reg [`W_JADDR-1:0]   addr,    // Jump Addr Field
  // ALU Control
  output reg [`W_FUNCT-1:0]   alu_op,  // ALU OP
  // Muxing
  output reg [`W_PC_SRC-1:0]  pc_src,  // PC Source
  output reg [`W_MEM_CMD-1:0] mem_cmd, // Mem Command
  output reg [`W_ALU_SRC-1:0] alu_src, // ALU Source
  output reg [`W_REG_SRC-1:0] reg_src);// Mem to Reg

  // Unconditionally pull some instruction fields
  wire [`W_REG-1:0] rs;
  wire [`W_REG-1:0] rt;
  wire [`W_REG-1:0] rd;
  assign rs   = inst[`FLD_RS];
  assign rt   = inst[`FLD_RT];
  assign rd   = inst[`FLD_RD];
  assign imm  = inst[`FLD_IMM];
  assign addr = inst[`FLD_ADDR];

  always @(inst) begin
    if (`DEBUG_DECODE)
      /* verilator lint_off STMTDLY */
      #1 // Delay Slightly
      $display("op = %x rs = %x rt = %x rd = %x imm = %x addr = %x",inst[`FLD_OPCODE],rs,rt,rd,imm,addr);
      /* verilator lint_on STMTDLY */
  end

// this will behave like a LUT, it looks things up by an opcode
  always @* begin // look at the greensheet
    case(inst[`FLD_OPCODE])
    // add, addi, addiu, addu, and, andi, nor, or, ori, slt, slti, sltiu, sltu, sll, srl, sub, subu, nop
     // alu_op = alu_cntrl
    `LUI : begin
    wa = rt; ra1 = REG_0; ra2 = REG_0; reg_wen = `WREN; // TODO figure out if this is right
    imm_ext = `IMM_SIGN_EXT; mem_cmd = `MEM_NOP;
    alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
    pc_src  = `PC_SRC_NEXT;  alu_op  = `F_OR; end //

    `ADDI : begin
    wa = rt; ra1 = rs; ra2 = REG_0; reg_wen = `WREN;
    imm_ext = `IMM_SIGN_EXT; mem_cmd = `MEM_NOP;
    alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
    pc_src  = `PC_SRC_NEXT;  alu_op  = `F_ADD; end

    `ADDIU : begin
    wa = rt; ra1 = rs; ra2 = REG_0; reg_wen = `WREN;
    imm_ext = `IMM_SIGN_EXT; mem_cmd = `MEM_NOP;
    alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
    pc_src  = `PC_SRC_NEXT;  alu_op  = `F_ADDU; end

    `ANDI : begin
    wa = rt; ra1 = rs; ra2 = REG_0; reg_wen = `WREN;
    imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
    alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
    pc_src  = `PC_SRC_NEXT;  alu_op  = `F_AND; end

    `ORI : begin
    wa = rt; ra1 = rs; ra2 = REG_0; reg_wen = `WREN;
    imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
    alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
    pc_src  = `PC_SRC_NEXT;  alu_op  = `F_OR; end

    `XORI : begin
    wa = rt; ra1 = rs; ra2 = REG_0; reg_wen = `WREN;
    imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
    alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
    pc_src  = `PC_SRC_NEXT;  alu_op  = `F_XOR; end

    `SLTI : begin end
    wa = rt; ra1 = rs; ra2 = REG_0; reg_wen = `WREN;
    imm_ext = `IMM_SIGN_EXT; mem_cmd = `MEM_NOP;
    alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
    pc_src  = `PC_SRC_NEXT;  alu_op  = `F_SLT; end

    `SLTIU : begin end
    wa = rt; ra1 = rs; ra2 = REG_0; reg_wen = `WREN;
    imm_ext = `IMM_SIGN_EXT; mem_cmd = `MEM_NOP;
    alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
    pc_src  = `PC_SRC_NEXT;  alu_op  = `F_SLTU; end

    `OP_ZERO: begin // split them up because of the ALU operation
      case(inst[`FLD_FUNCT]) // keep note of differences in alu_src, alu_op, and reg_wen
        begin
        `F_BREAK : begin // break is the same as nop!
        wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WDIS;
        imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
        alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
        pc_src  = `PC_SRC_NEXT;  alu_op  = `F_BREAK; end// inst[`FLD_FUNCT]; end

        `F_ADD : begin
        wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
        imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP; // TODO ask if mem_nop is correct for these
        alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
        pc_src  = `PC_SRC_NEXT;  alu_op  = `F_ADD; end

        `F_ADDU : begin
        wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
        imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
        alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
        pc_src  = `PC_SRC_NEXT;  alu_op  = `F_ADDU; end

        `F_SUB : begin
        wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
        imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
        alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
        pc_src  = `PC_SRC_NEXT;  alu_op  = `F_SUB; end

        `F_SUBU : begin
        wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
        imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
        alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
        pc_src  = `PC_SRC_NEXT;  alu_op  = `F_SUBU; end

        `F_AND : begin
        wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
        imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
        alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
        pc_src  = `PC_SRC_NEXT;  alu_op  = `F_AND; end

        `F_XOR : begin
        wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
        imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
        alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
        pc_src  = `PC_SRC_NEXT;  alu_op  = `F_XOR; end

        `F_NOR : begin
        wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
        imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
        alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
        pc_src  = `PC_SRC_NEXT;  alu_op  = `F_NOR; end

        `F_OR : begin
        wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
        imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
        alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
        pc_src  = `PC_SRC_NEXT;  alu_op  = `F_OR; end

        `F_SLT : begin
        wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
        imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
        alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
        pc_src  = `PC_SRC_NEXT;  alu_op  = `F_SLT; end

        `F_SLTU : begin
        wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
        imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
        alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
        pc_src  = `PC_SRC_NEXT;  alu_op  = `F_SLTU; end

        `F_SLL : begin
        wa = rd; ra1 = rt; ra2 = REG_0; reg_wen = `WREN;
        imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
        alu_src = `ALU_SRC_SHA;  reg_src = `REG_SRC_ALU;
        pc_src  = `PC_SRC_NEXT;  alu_op  = `F_SLL; end

        `F_SLLV : begin // uses specified register instead of shamt
        wa = rd; ra1 = rt; ra2 = REG_0; reg_wen = `WREN;
        imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
        alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
        pc_src  = `PC_SRC_NEXT;  alu_op  = `F_SLLV; end

        `F_SRL : begin
        wa = rd; ra1 = rt; ra2 = REG_0; reg_wen = `WREN;
        imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
        alu_src = `ALU_SRC_SHA;  reg_src = `REG_SRC_ALU;
        pc_src  = `PC_SRC_NEXT;  alu_op  = `F_SRL; end

        `F_SRLV : begin
        wa = rd; ra1 = rt; ra2 = REG_0; reg_wen = `WREN;
        imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
        alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
        pc_src  = `PC_SRC_NEXT;  alu_op  = `F_SRLV; end

        `F_SRA  : begin
        wa = rd; ra1 = rt; ra2 = REG_0; reg_wen = `WREN;
        imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
        alu_src = `ALU_SRC_SHA;  reg_src = `REG_SRC_ALU;
        pc_src  = `PC_SRC_NEXT;  alu_op  = `F_SRA; end

        `F_SRAV : begin
        wa = rd; ra1 = rt; ra2 = REG_0; reg_wen = `WREN;
        imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
        alu_src = `ALU_SRC_SHA;  reg_src = `REG_SRC_ALU;
        pc_src  = `PC_SRC_NEXT;  alu_op  = `F_SRAV; end
        end

      default: begin // not doing an imm operation, passing data from register through ALU, basically break?
        wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WDIS;
        imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
        alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
        pc_src  = `PC_SRC_NEXT;  alu_op  = inst[`FLD_FUNCT]; end

    endcase
  end
endmodule
