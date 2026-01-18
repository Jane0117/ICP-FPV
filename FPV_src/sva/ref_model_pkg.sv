`timescale 1ns / 1ps

package ref_model_pkg;
    import common::*;

    function automatic void ref_decode(instruction_type instr,
                                       output control_type control,
                                       output logic decode_failed);
        control = '0;
        decode_failed = 1'b0;
        unique case (instr.opcode)
            7'b0110011: begin
                control.encoding  = R_TYPE;
                control.reg_write = 1'b1;
                unique casez({instr.funct7[5], instr.funct3})
                    4'b0_000: control.alu_op = ALU_ADD;
                    4'b1_000: control.alu_op = ALU_SUB;
                    4'b?_001: control.alu_op = ALU_SLL;
                    4'b?_010: control.alu_op = ALU_SLT;
                    4'b?_011: control.alu_op = ALU_SLTU;
                    4'b?_100: control.alu_op = ALU_XOR;
                    4'b0_101: control.alu_op = ALU_SRL;
                    4'b1_101: control.alu_op = ALU_SRA;
                    4'b?_110: control.alu_op = ALU_OR;
                    4'b?_111: control.alu_op = ALU_AND;
                    default: decode_failed = 1'b1;
                endcase
            end
            7'b0010011: begin
                control.encoding  = I_TYPE;
                control.reg_write = 1'b1;
                control.alu_src   = 1'b1;
                unique casez({instr.funct7[5], instr.funct3})
                    4'b?_000: control.alu_op = ALU_ADD;
                    4'b?_001: control.alu_op = ALU_SLL;
                    4'b?_010: control.alu_op = ALU_SLT;
                    4'b?_011: control.alu_op = ALU_SLTU;
                    4'b?_100: control.alu_op = ALU_XOR;
                    4'b0_101: control.alu_op = ALU_SRL;
                    4'b1_101: control.alu_op = ALU_SRA;
                    4'b?_110: control.alu_op = ALU_OR;
                    4'b?_111: control.alu_op = ALU_AND;
                    default: decode_failed = 1'b1;
                endcase
            end
            7'b0000011: begin
                control.encoding   = I_TYPE;
                control.reg_write  = 1'b1;
                control.alu_src    = 1'b1;
                control.mem_read   = 1'b1;
                control.mem_to_reg = 1'b1;
                control.alu_op     = ALU_ADD;
                unique casez(instr.funct3)
                    3'b000: control.mem_size = 2'b00;
                    3'b001: control.mem_size = 2'b01;
                    3'b010: control.mem_size = 2'b10;
                    3'b100: control.mem_size = 2'b00;
                    3'b101: control.mem_size = 2'b01;
                    default: decode_failed = 1'b1;
                endcase
                unique casez(instr.funct3)
                    3'b0??: control.mem_sign = 1'b1;
                    3'b1??: control.mem_sign = 1'b0;
                    default: decode_failed = 1'b1;
                endcase
            end
            7'b1100111: begin
                control.encoding  = I_TYPE;
                control.is_branch = 1'b1;
                control.reg_write = 1'b1;
                control.alu_op    = ALU_ADD;
            end
            7'b1101111: begin
                control.encoding  = J_TYPE;
                control.is_branch = 1'b0;
                control.reg_write = 1'b1;
                control.alu_op    = ALU_ADD;
            end
            7'b0100011: begin
                control.encoding = S_TYPE;
                control.alu_src  = 1'b1;
                control.mem_write= 1'b1;
                control.alu_op   = ALU_ADD;
                unique casez(instr.funct3)
                    3'b000: control.mem_size = 2'b00;
                    3'b001: control.mem_size = 2'b01;
                    3'b010: control.mem_size = 2'b10;
                    default: decode_failed = 1'b1;
                endcase
            end
            7'b1100011: begin
                control.encoding  = B_TYPE;
                control.is_branch = 1'b1;
                unique casez({instr.funct3, instr.opcode})
                    BEQ_INSTRUCTION:  control.alu_op = ALU_SUB;
                    BNE_INSTRUCTION:  control.alu_op = B_BNE;
                    BLT_INSTRUCTION:  control.alu_op = B_BLT;
                    BGE_INSTRUCTION:  control.alu_op = B_BGE;
                    BLTU_INSTRUCTION: control.alu_op = B_LTU;
                    BGEU_INSTRUCTION: control.alu_op = B_GEU;
                    default: decode_failed = 1'b1;
                endcase
            end
            7'b0110111: begin
                control.encoding  = U_TYPE;
                control.reg_write = 1'b1;
                control.alu_src   = 1'b1;
                control.alu_op    = ALU_LUI;
            end
            7'b0010111: begin
                control.encoding  = U_TYPE;
                control.reg_write = 1'b1;
                control.alu_op    = ALU_ADD;
            end
            default: begin
                if (instr == 32'h00001111 || instr == 32'h00000000)
                    control = '0;
                else
                    decode_failed = 1'b1;
            end
        endcase
    endfunction

    function automatic logic ref_reg_illegal(control_type control,
                                              instruction_type instr,
                                              logic [4:0] rd_id);
        logic reg_illegal;
        reg_illegal = 1'b0;
        if (((control.encoding == R_TYPE||control.encoding == I_TYPE||control.encoding == U_TYPE||control.encoding == J_TYPE)
             && rd_id == 0) || rd_id >= REGISTER_FILE_SIZE) begin
            if (instr.opcode != 7'b1100111 && instr != 32'h00000013)
                reg_illegal = 1'b1;
        end
        if ((control.encoding == R_TYPE||control.encoding == I_TYPE||control.encoding == S_TYPE
             ||control.encoding == B_TYPE) && instr.rs1 >= REGISTER_FILE_SIZE) begin
            reg_illegal = 1'b1;
        end
        if ((control.encoding == R_TYPE||control.encoding == S_TYPE||control.encoding == B_TYPE)
             && instr.rs2 >= REGISTER_FILE_SIZE) begin
            reg_illegal = 1'b1;
        end
        return reg_illegal;
    endfunction

    function automatic logic [31:0] ref_alu(alu_op_type op,
                                           logic [31:0] left_operand,
                                           logic [31:0] right_operand);
        case (op)
            ALU_AND:  ref_alu = left_operand & right_operand;
            ALU_OR:   ref_alu = left_operand | right_operand;
            ALU_XOR:  ref_alu = left_operand ^ right_operand;
            ALU_ADD:  ref_alu = left_operand + right_operand;
            ALU_SUB:  ref_alu = left_operand - right_operand;
            ALU_SLT:  ref_alu = ($signed(left_operand) < $signed(right_operand)) ? 32'd1 : 32'd0;
            ALU_SLTU: ref_alu = (left_operand < right_operand) ? 32'd1 : 32'd0;
            ALU_SLL:  ref_alu = left_operand << right_operand[4:0];
            ALU_SRL:  ref_alu = left_operand >> right_operand[4:0];
            ALU_SRA:  ref_alu = $signed(left_operand) >>> right_operand[4:0];
            ALU_LUI:  ref_alu = right_operand;
            B_BNE:    ref_alu = !(left_operand != right_operand);
            B_BLT:    ref_alu = !($signed(left_operand) < $signed(right_operand));
            B_BGE:    ref_alu = !($signed(left_operand) >= $signed(right_operand));
            B_LTU:    ref_alu = !(left_operand < right_operand);
            B_GEU:    ref_alu = !(left_operand >= right_operand);
            default:  ref_alu = left_operand + right_operand;
        endcase
    endfunction

    function automatic logic ref_overflow(alu_op_type op,
                                          logic [31:0] left_operand,
                                          logic [31:0] right_operand,
                                          logic [31:0] result);
        if (op == ALU_ADD)
            ref_overflow = (~(left_operand[31] ^ right_operand[31])) & (left_operand[31] ^ result[31]);
        else if (op == ALU_SUB)
            ref_overflow = (left_operand[31] ^ right_operand[31]) & (left_operand[31] ^ result[31]);
        else
            ref_overflow = 1'b0;
    endfunction
endpackage
