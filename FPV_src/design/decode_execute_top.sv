`timescale 1ns / 1ps

import common::*;

module decode_execute_top(
    input logic clk,
    input logic reset_n,
    input instruction_type instruction,
    input logic [31:0] pc_in,
    input logic write_en,
    input logic [4:0] write_id,
    input logic [31:0] write_data,
    input logic [31:0] wb_forward_data,
    input logic [31:0] mem_forward_data,
    input forward_type forward_rs1,
    input forward_type forward_rs2,
    output control_type control_out,
    output logic [31:0] alu_data,
    output logic [31:0] memory_data,
    output logic pc_src,
    output logic [31:0] jalr_target_offset,
    output logic jalr_flag,
    output logic [31:0] pc_out,
    output logic overflow,
    output logic instruction_illegal
);

    logic [4:0] reg_rd_id;
    logic [31:0] read_data1;
    logic [31:0] read_data2;
    logic [31:0] immediate_data;
    logic [31:0] decode_pc_out;
    control_type control_signals;
    control_type control_signals_sanitized;

    decode_stage u_decode_stage(
        .clk(clk),
        .reset_n(reset_n),
        .instruction(instruction),
        .pc_in(pc_in),
        .write_en(write_en),
        .write_id(write_id),
        .write_data(write_data),
        .reg_rd_id(reg_rd_id),
        .read_data1(read_data1),
        .read_data2(read_data2),
        .immediate_data(immediate_data),
        .pc_out(decode_pc_out),
        .instruction_illegal(instruction_illegal),
        .control_signals(control_signals)
    );

    assign control_signals_sanitized = instruction_illegal ? '0 : control_signals;

    execute_stage u_execute_stage(
        .data1(read_data1),
        .data2(read_data2),
        .immediate_data(immediate_data),
        .pc_in(decode_pc_out),
        .control_in(control_signals_sanitized),
        .wb_forward_data(wb_forward_data),
        .mem_forward_data(mem_forward_data),
        .forward_rs1(forward_rs1),
        .forward_rs2(forward_rs2),
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
