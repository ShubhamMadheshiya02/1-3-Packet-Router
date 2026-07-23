module tb_FIFO;

reg clk;
reg resetn;
reg [7:0] data_in;
reg read_en;
reg soft_reset;
reg lfd_state;
reg write_en;

wire [7:0] data_out;
wire full;
wire empty;

integer i;

FIFO dut(
    .clk(clk),
    .resetn(resetn),
    .data_in(data_in),
    .read_en(read_en),
    .soft_reset(soft_reset),
    .lfd_state(lfd_state),
    .write_en(write_en),
    .data_out(data_out),
    .full(full),
    .empty(empty)
);

initial
begin
    clk = 1'b0;
    forever #10 clk = ~clk;
end

initial
begin
    resetn = 1'b0;
    write_en = 1'b0;
    read_en = 1'b0;
    data_in = 8'd0;
    lfd_state = 1'b0;
    soft_reset = 1'b0;
end

initial
begin
    #20;
    resetn = 1'b1;

    for(i=0;i<16;i=i+1)
    begin
        @(posedge clk);
        write_en = 1'b1;
        data_in = i;

        $display("Time=%0t | Write Enabled | data_in=%d | full=%b empty=%b counter=%d",
                  $time,data_in,full,empty,dut.counter);
    end

    @(posedge clk);
    write_en = 1'b0;

    for(i=0;i<16;i=i+1)
    begin
        @(posedge clk);
        read_en = 1'b1;

        $display("Time=%0t | Read Enabled | data_out=%d Expected=%d | full=%b empty=%b counter=%d",
                  $time,data_out,i,full,empty,dut.counter);
    end

    @(posedge clk);
    read_en = 1'b0;

    $finish;
end

endmodule













































module tb_FIFO;


    // Testbench signals
    logic           clk;
    logic           resetn;
    logic   [7:0]   data_in;
    logic           read_en;
    logic           soft_reset;
    logic           lfd_state;
    logic           write_en;

   
    wire    [7:0]   data_out;
    wire            full;
    wire            empty;
    
    
    FIFO dut (
        .clk(clk),
        .resetn(resetn),
        .data_in(data_in),
        .read_en(read_en),
        .soft_reset(soft_reset),
        .lfd_state(lfd_state),
        .write_en(write_en),
        .data_out(data_out),
        .full(full),
        .empty(empty)
    );
    
    initial begin
     clk = 0 ;
     forever #10 clk = ~clk;
    
    end
    initial begin
        resetn = 1'b0; 
        write_en = 0;
        read_en = 0;
        data_in = 8'd0;
        lfd_state = 0;
    end
    
    initial begin
        #20;
        resetn = 1'b1;
        for (int i = 0; i < 16; i++) begin
            @(posedge clk);
            write_en = 1;
            data_in = i;
            $display("Time=%0t | Write Enabled | data_in=%d | full=%b, empty=%b, counter=%d", $time, data_in, full, empty, dut.counter);
        end
        @(posedge clk);
        write_en = 0; 
        for (int i = 0; i < 16; i++) begin
            @(posedge clk);
            read_en = 1;
            $display("Time=%0t | Read Enabled  | data_out=%d (Expected %d) | full=%b, empty=%b, counter=%d", $time, data_out, i, full, empty, dut.counter);
        end
        @(posedge clk);
        read_en = 0; // Stop reading

        $finish;
    end
    
endmodule
