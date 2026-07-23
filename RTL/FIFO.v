verilog

module FIFO(
    input clk,
    input resetn,
    input [7:0] data_in,
    input read_en,
    input soft_reset,
    input lfd_state,
    input write_en,

    output reg [7:0] data_out,
    output full,
    output empty
);

reg [8:0] mem [15:0];

reg [4:0] counter;
reg [4:0] rd_pointer;
reg [4:0] wr_pointer;
reg first_data;

integer i;

always @(posedge clk)
begin
    if(lfd_state)
        first_data <= 1'b1;
    else
        first_data <= 1'b0;
end

always @(posedge clk)
begin
    if(!resetn)
    begin
        data_out   <= 8'd0;
        counter    <= 5'd0;
        rd_pointer <= 5'd0;
        wr_pointer <= 5'd0;

        for(i=0;i<16;i=i+1)
            mem[i] <= 9'bzzzzzzzzz;
    end
    else
    begin
        if(write_en && !full)
        begin
            if(first_data)
                mem[wr_pointer[3:0]] <= {1'b1,data_in};
            else
                mem[wr_pointer[3:0]] <= {1'b0,data_in};

            wr_pointer <= wr_pointer + 1'b1;
        end
        else if(read_en && !empty)
        begin
            data_out <= mem[rd_pointer[3:0]][7:0];
        end
    end
end

always @(posedge clk)
begin
    if(read_en && !empty)
        rd_pointer <= rd_pointer + 1'b1;
end

assign full  = (wr_pointer == {~rd_pointer[4],rd_pointer[3:0]});
assign empty = (wr_pointer == rd_pointer);

endmodule




































-systemverilog


module FIFO(
    input clk,
    input resetn, 
    input [7:0] data_in,
    input read_en,
    input soft_reset,
    input lfd_state,
    input write_en,
    
    output logic [7:0] data_out,
    output logic full,
    output logic empty

    );
    
    reg [8:0]mem[15:0];
    reg [4:0] counter;
    reg [4:0]rd_pointer;
    reg [4:0]wr_pointer;
    reg first_data;
   // assign first_data = (write_en && !full && lfd_state)? 1'b1 : 1'b0;
   always@(posedge clk)begin
       if(lfd_state)
           first_data <= 1;
       else
           first_data <= 0;    
    
   end
//    
    always@(posedge clk)
    begin
        if(!resetn) begin
            data_out <= 8'd0;
            empty <= 1;
            full <= 0;
            counter <= 0;
            rd_pointer <= 5'd0;
            wr_pointer <= 5'd0;
            for(int i = 0 ; i< 16 ; i++) begin
                mem[i] <= 9'bzzzzzzzzz;
            end
        end
        else begin
            if(write_en && !full)begin
                if(first_data)begin //storing the address 
                    mem[wr_pointer[3:0]] <= {1'b1,data_in[7:0]}; 
                    //counter <= counter + 1;
                end
                else begin
                    mem[wr_pointer[3:0]] <= {1'b0,data_in[7:0]};
                    //counter <= counter + 1;
                end
                wr_pointer <= wr_pointer + 1;
            end
            else if(read_en && ~empty)begin
                data_out <= mem[rd_pointer[3:0]][7:0];  
                //counter <= counter - 1;  
            end
        end
    end
    
    /*always @(posedge clk)begin
        if(write_en && !full) begin
             wr_pointer <= wr_pointer + 1;
        end
    end*/
    
    always @(posedge clk)begin
        if(read_en && !empty) begin
              rd_pointer <= rd_pointer + 1;    
        end
    end
    
    /*assign full = (counter == 5'b10000);
    assign empty = (counter == 0);*/
    
    assign full = (wr_pointer == {~rd_pointer[4],rd_pointer[3:0]});
    assign empty = wr_pointer == rd_pointer;
    
endmodule
