`timescale 1ns / 1ps

import common::*;

module decode_top_formal(
    input logic clk,
    input logic reset_n,
    input instruction_type instruction,
    input logic [31:0] pc_in,
    input logic write_en,
    input logic [4:0] write_id,
    input logic [31:0] write_data,
    output logic [4:0] reg_rd_id,
    output logic [31:0] read_data1,
    output logic [31:0] read_data2,
    output logic [31:0] immediate_data,
    output logic [31:0] pc_out,
    output logic instruction_illegal,
    output control_type control_signals
);

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
        .pc_out(pc_out),
        .instruction_illegal(instruction_illegal),
        .control_signals(control_signals)
    );
endmodule
