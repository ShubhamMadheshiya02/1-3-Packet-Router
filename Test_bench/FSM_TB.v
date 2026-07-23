`timescale 1ns/1ps

module tb_FSM_CONTROLLER;

reg clk;
reg resetn;
reg pkt_valid;
reg fifo_full;
reg fifo_empty0;
reg fifo_empty1;
reg fifo_empty2;
reg soft_reset0;
reg soft_reset1;
reg soft_reset2;
reg parity_done;
reg low_packet_valid;
reg [1:0] data_in;

wire write_en;
wire detect_add;
wire ld_state;
wire laf_state;
wire lfd_state;
wire full_state;
wire parity_check_state;
wire busy;
wire load_parity_state;

integer cycles;

FSM_CONTROLLER dut(
    .clk(clk),
    .resetn(resetn),
    .pkt_valid(pkt_valid),
    .fifo_full(fifo_full),
    .fifo_empty0(fifo_empty0),
    .fifo_empty1(fifo_empty1),
    .fifo_empty2(fifo_empty2),
    .soft_reset0(soft_reset0),
    .soft_reset1(soft_reset1),
    .soft_reset2(soft_reset2),
    .parity_done(parity_done),
    .low_packet_valid(low_packet_valid),
    .fifo_add(data_in),
    .write_en(write_en),
    .detect_add(detect_add),
    .ld_state(ld_state),
    .laf_state(laf_state),
    .lfd_state(lfd_state),
    .full_state(full_state),
    .parity_check_state(parity_check_state),
    .busy(busy),
    .load_parity_state(load_parity_state)
);

always #10 clk = ~clk;

initial
begin
    $monitor("Time=%0t | State=%d | pkt_valid=%b data_in=%d fifo_full=%b empty0=%b empty1=%b empty2=%b write_en=%b busy=%b",
             $time,dut.ps,pkt_valid,data_in,fifo_full,
             fifo_empty0,fifo_empty1,fifo_empty2,
             write_en,busy);
end

initial
begin

    $display("---------------------------------------");
    $display("Starting FSM Testbench");
    $display("---------------------------------------");

    initialize_signals;

    apply_reset;

    wait_cycles(2);

    $display("\nSCENARIO-1");

    fifo_empty0 = 1;
    pkt_valid = 1;
    data_in = 2'b00;

    wait_cycles(1);

    pkt_valid = 1;
    wait_cycles(3);

    pkt_valid = 0;
    wait_cycles(1);

    wait_cycles(1);
    wait_cycles(1);

    wait_cycles(2);

    $display("\nSCENARIO-2");

    fifo_empty1 = 0;
    pkt_valid = 1;
    data_in = 2'b01;

    wait_cycles(1);

    $display("FSM Waiting");

    wait_cycles(3);

    fifo_empty1 = 1;

    wait_cycles(1);

    pkt_valid = 1;

    wait_cycles(2);

    pkt_valid = 0;

    wait_cycles(3);

    $display("\nSCENARIO-3");

    fifo_empty2 = 1;

    pkt_valid = 1;

    data_in = 2'b10;

    wait_cycles(2);

    fifo_full = 1;

    wait_cycles(1);

    wait_cycles(3);

    fifo_full = 0;

    wait_cycles(1);

    pkt_valid = 1;

    wait_cycles(1);

    pkt_valid = 0;

    wait_cycles(3);

    $display("---------------------------------------");
    $display("Simulation Finished");
    $display("---------------------------------------");

    $finish;

end

task initialize_signals;
begin
    clk = 0;
    resetn = 1;
    pkt_valid = 0;
    fifo_full = 0;
    fifo_empty0 = 0;
    fifo_empty1 = 0;
    fifo_empty2 = 0;
    soft_reset0 = 0;
    soft_reset1 = 0;
    soft_reset2 = 0;
    parity_done = 0;
    low_packet_valid = 0;
    data_in = 2'b00;
end
endtask

task apply_reset;
begin
    resetn = 0;
    #20;
    resetn = 1;
    $display("Reset Released at %0t",$time);
end
endtask

task wait_cycles;
input integer cycles;
integer i;
begin
    for(i=0;i<cycles;i=i+1)
        @(posedge clk);
end
endtask

endmodule










































`timescale 1ns/1ps

module tb_FSM_CONTROLLER;
    logic           clk;
    logic           resetn;
    logic           pkt_valid;
    logic           fifo_full;
    logic           fifo_empty0, fifo_empty1, fifo_empty2;
    logic           soft_reset0, soft_reset1, soft_reset2;
    logic           parity_done;
    logic           low_packet_valid;
    logic   [1:0]   data_in;

    // Wires to connect to DUT outputs
    wire            write_en;
    wire            detect_add;
    wire            ld_state;
    wire            laf_state;
    wire            lfd_state;
    wire            full_state;
    wire            rst_int_reg;
    wire            busy;

    // DUT Instantiation
    // Using .* connects ports by name
    FSM_CONTROLLER dut (.*);

    // Clock Generation
    always #10 clk = ~clk;

    initial begin
        $monitor("Time=%0t | State=%s | pkt_valid=%b, data_in=%d | fifo_full=%b, empty0=%b, empty1=%b, empty2=%b || write_en=%b, busy=%b",
                 $time, dut.state.name(), pkt_valid, data_in, fifo_full, fifo_empty0, fifo_empty1, fifo_empty2, write_en, busy);
    end

    // Main Test Sequence
    initial begin
        $display("----------------------------------------------------");
        $display("--- Starting FSM Controller Testbench ---");
        $display("----------------------------------------------------");
        initialize_signals();
        
        // 1. Apply Reset
        apply_reset();
        wait_cycles(2);

        // --- SCENARIO 1: Simple packet transfer to FIFO 0 ---
        $display("\n--- SCENARIO 1: Simple packet transfer to FIFO 0 (should succeed) ---");
        fifo_empty0 = 1; // FIFO 0 is ready
        pkt_valid = 1;
        data_in = 0;
        wait_cycles(1); // FSM should go to LOAD_ADDRESS

        pkt_valid = 1; // Packet data is still coming
        wait_cycles(3); // FSM should be in LOAD_DATA for 3 cycles

        pkt_valid = 0; // Packet data ends, now send parity
        wait_cycles(1); // FSM should go to LOAD_PARITY

        wait_cycles(1); // FSM should go to CHECK_PARITY_ERROR
        wait_cycles(1); // FSM should return to DETECT_ADD
        wait_cycles(2);

        // --- SCENARIO 2: Packet for busy FIFO 1, then it becomes free ---
        $display("\n--- SCENARIO 2: Packet for busy FIFO 1 (should wait) ---");
        fifo_empty1 = 0; // FIFO 1 is NOT ready
        pkt_valid = 1;
        data_in = 1;
        wait_cycles(1); // FSM should go to WAIT_TILL_EMPTY

        $display("Time=%0t | [TB] FSM is waiting. FIFO 1 is still busy.", $time);
        wait_cycles(3);

        $display("Time=%0t | [TB] FIFO 1 is now free.", $time);
        fifo_empty1 = 1; // FIFO 1 becomes free
        wait_cycles(1); // FSM should now proceed to LOAD_ADDRESS
        
        // Finish the transfer
        pkt_valid = 1;
        wait_cycles(2);
        pkt_valid = 0;
        wait_cycles(3); // Go through LOAD_PARITY, CHECK_PARITY, and back to idle
        
        // --- SCENARIO 3: FIFO 2 becomes full during transfer ---
        $display("\n--- SCENARIO 3: FIFO 2 becomes full during transfer (should pause) ---");
        fifo_empty2 = 1; // FIFO 2 is ready
        pkt_valid = 1;
        data_in = 2;
        wait_cycles(2); // Enter LOAD_DATA

        $display("Time=%0t | [TB] FIFO 2 is now FULL!", $time);
        fifo_full = 1; // FIFO becomes full!
        wait_cycles(1); // FSM should go to FIFO_FULL state

        $display("Time=%0t | [TB] FSM is paused. write_en should be 0.", $time);
        wait_cycles(3);

        $display("Time=%0t | [TB] FIFO 2 has space again.", $time);
        fifo_full = 0; // Space is available again
        wait_cycles(1); // FSM should go to LOAD_AFTER_FULL

        // Resume and finish transfer
        pkt_valid = 1;
        wait_cycles(1);
        pkt_valid = 0;
        wait_cycles(3);

        $display("\n----------------------------------------------------");
        $display("--- Simulation Finished ---");
        $display("----------------------------------------------------");
        $finish;
    end
    
    // Task to initialize all signals at time 0
    task initialize_signals;
        clk = 0;
        resetn = 1;
        pkt_valid = 0;
        fifo_full = 0;
        fifo_empty0 = 0; fifo_empty1 = 0; fifo_empty2 = 0;
        soft_reset0 = 0; soft_reset1 = 0; soft_reset2 = 0;
        parity_done = 0;
        low_packet_valid = 0;
        data_in = '0;
    endtask

    // Task to apply the reset pulse
    task apply_reset;
        resetn = 1'b0;
        #20;
        resetn = 1'b1;
        $display("Time=%0t | [TB] Reset Released.", $time);
    endtask

    // Task to wait for a number of clock cycles
    task wait_cycles(input int cycles);
        repeat(cycles) @(posedge clk);
    endtask

endmodule
