module REGISTERs(
    input clk,
    input resetn,
    input [7:0] data_in,
    input detect_add,
    input fifo_full,
    input full_state,
    input laf_state,
    input ld_state,
    input lfd_state,
    input pkt_valid,
    input parity_check_state,
    input load_parity_state,

    output reg [7:0] data_out,
    output reg err,
    output reg low_packet_valid,
    output reg parity_done
);

reg [7:0] header;
reg [7:0] int_reg;
reg [7:0] int_parity;
reg [7:0] ext_parity;
reg [7:0] data_in_temp;

always @(posedge clk)
begin
    if(!resetn)
    begin
        header <= 8'hzz;
        int_reg <= 8'd0;
        data_out <= 8'd0;
        data_in_temp <= 8'hzz;
    end
    else
    begin
        if(detect_add && pkt_valid && data_in[1:0] != 2'b11)
        begin
            header <= data_in;
        end

        if(lfd_state)
        begin
            data_out <= header;
        end
        else if(ld_state && !fifo_full)
        begin
            data_out <= data_in;
        end
        else if(full_state)
        begin
            int_reg <= data_in;
        end
        else if(laf_state)
        begin
            data_out <= int_reg;
        end
    end
end

always @(posedge clk)
begin
    if(!resetn)
    begin
        int_parity <= 8'd0;
    end
    else if(detect_add)
    begin
        int_parity <= 8'd0;
    end
    else if(lfd_state)
    begin
        int_parity <= int_parity ^ data_in;
    end
    else if(ld_state && !full_state && pkt_valid)
    begin
        int_parity <= int_parity ^ data_in;
    end
    else
    begin
        int_parity <= int_parity;
    end
end

always @(posedge clk)
begin
    if(!resetn)
    begin
        low_packet_valid <= 1'b0;
        ext_parity <= 8'd0;
    end
    else if(load_parity_state)
    begin
        ext_parity <= data_in;
    end
end

always @(posedge clk)
begin
    if(!resetn)
    begin
        err <= 1'b0;
        parity_done <= 1'b0;
    end
    else if(parity_check_state)
    begin
        parity_done <= 1'b1;

        if(int_parity == ext_parity)
            err <= 1'b0;
        else
            err <= 1'b1;
    end
    else
    begin
        err <= 1'b0;
        parity_done <= 1'b0;
    end
end

always @(posedge clk)
begin
    if(!resetn)
    begin
        low_packet_valid <= 1'b0;
    end
    else if(ld_state && !pkt_valid)
    begin
        low_packet_valid <= 1'b1;
    end
    else
    begin
        low_packet_valid <= 1'b0;
    end
end

endmodule





























module REGISTERs(
    input clk,
    input resetn,
    input [7:0]data_in,
    input detect_add,
    input fifo_full,
    input full_state,
    input laf_state,
    input ld_state,
    input lfd_state,
    input pkt_valid,
    input parity_check_state,
    input load_parity_state,
    output logic [7:0]data_out,
    output logic err,
    output logic low_packet_valid,
    output logic parity_done
    );
    
    reg [7:0]header;
    reg [7:0]int_reg;
    reg [7:0]int_parity,ext_parity;
    reg [7:0] data_in_temp;
 
    
    always @(posedge clk) begin
        if(!resetn)begin
             header <= 8'hzz;
             int_reg <= 0;
             data_out <= 0;
             data_in_temp <= 8'hzz;
        end
        else begin 
            if(detect_add && pkt_valid && data_in[1:0]!= 2'b11)begin
                header <= data_in;
                //data_in_temp <= data_in;
            end
             if(lfd_state)begin
                data_out <= header;
                //data_in_temp = data_in;
                end
            else if(ld_state && !fifo_full)begin
               // data_in_temp <= data_in;
                data_out <= data_in;end
            else if(full_state)
                int_reg <= data_in;
            else if(laf_state)
                data_out <= int_reg;
        end
    end
    
    always @(posedge clk)begin
        if(!resetn)begin
            int_parity <= 0;
        end
        else if(detect_add)begin
            int_parity <= 0;
        end
        else if(lfd_state) begin
            int_parity <= int_parity^data_in;
        end
        else if(ld_state && !full_state && pkt_valid) begin
            int_parity <= int_parity^data_in;
        end 
        else 
            int_parity <= int_parity;    
    end
    
    always @(posedge clk)begin
        if(!resetn)begin
            low_packet_valid <= 0;
            ext_parity <= 0;   
        end
        else if(load_parity_state)begin
            ext_parity <= data_in;
        end
    end
    
    always @(posedge clk)begin
        if(!resetn)begin
            err <= 0;
            parity_done <= 0;
        end
        else if(parity_check_state)
        begin
            parity_done <= 1;
            if(int_parity == ext_parity)
                err <= 0;
            else
                err <= 1;
         end
         else begin
            err <= 0;
            parity_done <= 0;
         end
                 
    end
    
    always @(posedge clk)begin
        if(!resetn)begin
            low_packet_valid <= 0;    
        end
        else if(ld_state  && !pkt_valid)
            low_packet_valid <= 1;
        else
            low_packet_valid <= 0;    
    end
       
endmodule
/**/
