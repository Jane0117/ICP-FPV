`timescale 1ns / 1ps

import common::*;

module execute_top_formal(
    input logic clk,
    input logic reset_n,
    input logic [31:0] data1,
    input logic [31:0] data2,
    input logic [31:0] immediate_data,
    input logic [31:0] pc_in,
    input control_type control_in,
    output control_type control_out,
    output logic [31:0] alu_data,
    output logic [31:0] memory_data,
    output logic pc_src,
    output logic [31:0] jalr_target_offset,
    output logic jalr_flag,
    output logic [31:0] pc_out,
    output logic overflow
);
    logic [31:0] wb_forward_data_tieoff;
    logic [31:0] mem_forward_data_tieoff;
    forward_type forward_rs1_tieoff;
    forward_type forward_rs2_tieoff;

    assign wb_forward_data_tieoff = '0;
    assign mem_forward_data_tieoff = '0;
    assign forward_rs1_tieoff = FORWARD_NONE;
    assign forward_rs2_tieoff = FORWARD_NONE;

    execute_stage u_execute_stage(
        .data1(data1),
        .data2(data2),
        .immediate_data(immediate_data),
        .pc_in(pc_in),
        .control_in(control_in),
        .wb_forward_data(wb_forward_data_tieoff),
        .mem_forward_data(mem_forward_data_tieoff),
        .forward_rs1(forward_rs1_tieoff),
        .forward_rs2(forward_rs2_tieoff),
        .control_out(control_out),
        .alu_data(alu_data),
        .memory_data(memory_data),
        .pc_src(pc_src),
        .jalr_target_offset(jalr_target_offset),
        .jalr_flag(jalr_flag),
        .pc_out(pc_out),
        .overflow(overflow)
    );
endmodule
