module ROUTER(
    input clk,
    input resetn,
    input read_en0,
    input read_en1,
    input read_en2,
    input pkt_valid,
    input [7:0] data_in,
    output busy,
    output err,
    output vld_out0,
    output vld_out1,
    output vld_out2,
    output [7:0] data_out0,
    output [7:0] data_out1,
    output [7:0] data_out2
);

wire soft_reset0_top;
wire soft_reset1_top;
wire soft_reset2_top;

wire lfd_state_top;
wire detect_add_top;
wire ld_state_top;
wire laf_state_top;
wire full_state_top;
wire parity_check_state_top;
wire load_parity_state_top;

wire fifo_full0_top;
wire fifo_full1_top;
wire fifo_full2_top;

wire fifo_empty0_top;
wire fifo_empty1_top;
wire fifo_empty2_top;

wire low_packet_valid_top;
wire parity_done_top;

wire fifo_full_top;

wire [2:0] write_en_reg_top;
wire [7:0] data_fifo_in_top;

wire write_en_top;

FIFO fifo_0(
    .clk(clk),
    .resetn(resetn),
    .data_in(data_fifo_in_top),
    .read_en(read_en0),
    .soft_reset(soft_reset0_top),
    .lfd_state(lfd_state_top),
    .write_en(write_en_reg_top[0]),
    .data_out(data_out0),
    .full(fifo_full0_top),
    .empty(fifo_empty0_top)
);

FIFO fifo_1(
    .clk(clk),
    .resetn(resetn),
    .data_in(data_fifo_in_top),
    .read_en(read_en1),
    .soft_reset(soft_reset1_top),
    .lfd_state(lfd_state_top),
    .write_en(write_en_reg_top[1]),
    .data_out(data_out1),
    .full(fifo_full1_top),
    .empty(fifo_empty1_top)
);

FIFO fifo_2(
    .clk(clk),
    .resetn(resetn),
    .data_in(data_fifo_in_top),
    .read_en(read_en2),
    .soft_reset(soft_reset2_top),
    .lfd_state(lfd_state_top),
    .write_en(write_en_reg_top[2]),
    .data_out(data_out2),
    .full(fifo_full2_top),
    .empty(fifo_empty2_top)
);

REGISTERs reg_(
    .clk(clk),
    .resetn(resetn),
    .data_in(data_in),
    .detect_add(detect_add_top),
    .fifo_full(fifo_full_top),
    .full_state(full_state_top),
    .laf_state(laf_state_top),
    .ld_state(ld_state_top),
    .lfd_state(lfd_state_top),
    .pkt_valid(pkt_valid),
    .parity_check_state(parity_check_state_top),
    .load_parity_state(load_parity_state_top),
    .data_out(data_fifo_in_top),
    .err(err),
    .low_packet_valid(low_packet_valid_top),
    .parity_done(parity_done_top)
);

FSM_CONTROLLER fsm(
    .clk(clk),
    .resetn(resetn),
    .pkt_valid(pkt_valid),
    .fifo_full(fifo_full_top),
    .fifo_empty0(fifo_empty0_top),
    .fifo_empty1(fifo_empty1_top),
    .fifo_empty2(fifo_empty2_top),
    .soft_reset0(soft_reset0_top),
    .soft_reset1(soft_reset1_top),
    .soft_reset2(soft_reset2_top),
    .parity_done(parity_done_top),
    .low_packet_valid(low_packet_valid_top),
    .fifo_add(data_in[1:0]),
    .write_en(write_en_top),
    .detect_add(detect_add_top),
    .ld_state(ld_state_top),
    .laf_state(laf_state_top),
    .lfd_state(lfd_state_top),
    .full_state(full_state_top),
    .parity_check_state(parity_check_state_top),
    .busy(busy),
    .load_parity_state(load_parity_state_top)
);

SYNCHRONIZER sync(
    .clk(clk),
    .resetn(resetn),
    .fifo_add(data_in[1:0]),
    .detect_add(detect_add_top),
    .fifo_empty0(fifo_empty0_top),
    .fifo_empty1(fifo_empty1_top),
    .fifo_empty2(fifo_empty2_top),
    .fifo_full0(fifo_full0_top),
    .fifo_full1(fifo_full1_top),
    .fifo_full2(fifo_full2_top),
    .read_en0(read_en0),
    .read_en1(read_en1),
    .read_en2(read_en2),
    .write_en(write_en_top),
    .write_en_reg(write_en_reg_top),
    .fifo_full(fifo_full_top),
    .soft_reset0(soft_reset0_top),
    .soft_reset1(soft_reset1_top),
    .soft_reset2(soft_reset2_top),
    .vld_out0(vld_out0),
    .vld_out1(vld_out1),
    .vld_out2(vld_out2)
);

endmodule




















































module ROUTER(
    input clk,
    input resetn,
    input read_en0,
    input read_en1,
    input read_en2,
    input pkt_valid,
    input [7:0]data_in, 
    output busy,
    output err,
    output vld_out0,
    output vld_out1,
    output vld_out2,
    output [7:0]data_out0,
    output [7:0]data_out1,
    output [7:0]data_out2
    );
    
    wire soft_reset0_top,soft_reset1_top,soft_reset2_top;
    wire lfd_state_top,detect_add_top,ld_state_top,laf_state_top,full_state_top,parity_check_state_top,load_parity_state_top;
    wire fifo_full0_top,fifo_full1_top,fifo_full2_top;
    wire fifo_empty0_top,fifo_empty1_top,fifo_empty2_top;
    wire low_packet_valid_top,parity_done_top;
    wire fifo_full_top;
    wire [2:0]write_en_reg_top;
    wire [7:0]data_fifo_in_top;
    wire write_en_top;
    
    FIFO fifo_0(
     .clk(clk),
     .resetn(resetn), 
     .data_in(data_fifo_in_top),
     .read_en(read_en0),
     .soft_reset(soft_reset0_top),
     .lfd_state(lfd_state_top),
     .write_en(write_en_reg_top[0]),
     .data_out(data_out0),
     .full(fifo_full0_top),
     .empty(fifo_empty0_top)
    );
    
    FIFO fifo_1(
     .clk(clk),
     .resetn(resetn), 
     .data_in(data_fifo_in_top),
     .read_en(read_en1),
     .soft_reset(soft_reset1_top),
     .lfd_state(lfd_state_top),
     .write_en(write_en_reg_top[1]),
     .data_out(data_out1),
     .full(fifo_full1_top),
     .empty(fifo_empty1_top)
    );
    
    FIFO fifo_2(
     .clk(clk),
     .resetn(resetn), 
     .data_in(data_fifo_in_top),
     .read_en(read_en2),
     .soft_reset(soft_reset2_top),
     .lfd_state(lfd_state_top),
     .write_en(write_en_reg_top[2]),
     .data_out(data_out2),
     .full(fifo_full2_top),
     .empty(fifo_empty2_top)
    );
    
    REGISTERs reg_(
     .clk(clk),
     .resetn(resetn),
     .data_in(data_in),
     .detect_add(detect_add_top),
     .fifo_full(fifo_full_top),
     .full_state(full_state_top),
     .laf_state(laf_state_top),
     .ld_state(ld_state_top),
     .lfd_state(lfd_state_top),
     .pkt_valid(pkt_valid),
     .parity_check_state(parity_check_state_top),
     .load_parity_state(load_parity_state_top),
     .data_out(data_fifo_in_top),
     .err(err),
     .low_packet_valid(low_packet_valid_top),
     .parity_done(parity_done_top)
    );
    
    FSM_CONTROLLER fsm(
     .clk(clk),
     .resetn(resetn),
     .pkt_valid(pkt_valid),
     .fifo_full(fifo_full_top),
     .fifo_empty0(fifo_empty0_top),
     .fifo_empty1(fifo_empty1_top),
     .fifo_empty2(fifo_empty2_top),
     .soft_reset0(soft_reset0_top),
     .soft_reset1(soft_reset1_top),
     .soft_reset2(soft_reset2_top),
     .parity_done(parity_done_top),
     .low_packet_valid(low_packet_valid_top),
     .fifo_add(data_in[1:0]),
     .write_en(write_en_top),
     .detect_add(detect_add_top),
     .ld_state(ld_state_top),
     .laf_state(laf_state_top),
     .lfd_state(lfd_state_top),
     .full_state(full_state_top),
     .parity_check_state(parity_check_state_top),
     .busy(busy),
     .load_parity_state(load_parity_state_top)
    );
    
    SYNCHRONIZER sync(
     .clk(clk),
     .resetn(resetn),
     .fifo_add(data_in[1:0]),
     .detect_add(detect_add_top),
     .fifo_empty0(fifo_empty0_top),
     .fifo_empty1(fifo_empty1_top),
     .fifo_empty2(fifo_empty2_top),
     .fifo_full0(fifo_full0_top),
     .fifo_full1(fifo_full1_top),
     .fifo_full2(fifo_full2_top),
     .read_en0(read_en0),
     .read_en1(read_en1),
     .read_en2(read_en2),
     .write_en(write_en_top), 
     .write_en_reg(write_en_reg_top),
     .fifo_full(fifo_full_top),
     .soft_reset0(soft_reset0_top),
     .soft_reset1(soft_reset1_top),
     .soft_reset2(soft_reset2_top),
     .vld_out0(vld_out0),
     .vld_out1(vld_out1),
     .vld_out2(vld_out2)
    );
    
   
endmodule

interface router_if;
    logic clk;
    logic resetn;
    logic       read_en0;
    logic       read_en1;
    logic       read_en2;
    logic       pkt_valid;
    logic [7:0] data_in;
    logic       busy;
    logic       err;
    logic       vld_out0;
    logic       vld_out1;
    logic       vld_out2;
    logic [7:0] data_out0;
    logic [7:0] data_out1;
    logic [7:0] data_out2;


endinterface
