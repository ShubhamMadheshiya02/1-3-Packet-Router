


module SYNCHRONIZER(
    input clk,
    input resetn,
    input [1:0]fifo_add,
    input detect_add,
    input fifo_empty0,fifo_empty1,fifo_empty2,
    input fifo_full0,fifo_full1,fifo_full2,
    input read_en0,read_en1,read_en2,
    input write_en,
    
    output logic [2:0]write_en_reg,
    output logic fifo_full,
    output logic soft_reset0,soft_reset1,soft_reset2,
    output logic vld_out0,vld_out1,vld_out2

    );
    
    reg [5:0]counter0,counter1,counter2;
    reg [1:0]fifo_add_temp;
    
    always @(posedge clk)begin
        if(!resetn)begin  
            fifo_add_temp <= 0; 
        end
        else if(detect_add)begin
            fifo_add_temp <= fifo_add;
         end
    end
    
    always @(*)begin
            write_en_reg = 3'b000;   
            if(write_en)begin
            case(fifo_add_temp)
            2'b00 : write_en_reg = 3'b001;
            2'b01 : write_en_reg = 3'b010;
            2'b10 : write_en_reg = 3'b100;
            default : write_en_reg = 3'b000;
            endcase
        end
    end
    always@(*)begin
            fifo_full = 0;
         
            case(fifo_add_temp)
            2'b00 : fifo_full = fifo_full0; 
            2'b01 : fifo_full = fifo_full1;
            2'b10 : fifo_full = fifo_full2;
            default : fifo_full = 0;
            endcase
    end
    
    assign vld_out0 = ~fifo_empty0 ;
    assign vld_out1 = ~fifo_empty1 ;
    assign vld_out2 = ~fifo_empty2 ;
    
    always @(posedge clk)begin
        if(!resetn)begin
            counter0 <= 0;
            soft_reset0 <= 0;
        end  
        else if(vld_out0)begin
            if(!read_en0)begin
                if(counter0 == 30)begin
                    soft_reset0 <= 1;
                    counter0 <= 0;
                end
                else begin
                    soft_reset0 <= 0;
                    counter0 <= counter0 + 1;
                end
            end
            else begin
                counter0 <= 0;
            end
        end
    end
    
    always @(posedge clk)begin
        if(!resetn)begin
            counter1 <= 0;
            soft_reset1 <= 0;
        end  
        else if(vld_out1)begin
            if(!read_en1)begin
                if(counter1 == 30)begin
                    soft_reset1 <= 1;
                    counter1 <= 0;
                end
                else begin
                    soft_reset1 <= 0;
                    counter1 <= counter1 + 1;
                end
            end
            else begin
                counter1 <= 0;
            end
        end
    end
    always @(posedge clk)begin
        if(!resetn)begin
            counter2 <= 0;
            soft_reset2 <= 0;
        end  
        else if(vld_out2)begin
            if(!read_en2)begin
                if(counter2 == 30)begin
                    soft_reset2 <= 1;
                    counter2 <= 0;
                end
                else begin
                    soft_reset2 <= 0;
                    counter2 <= counter2 + 1;
                end
            end
            else begin
                counter2 <= 0;
            end
        end
    end 
    
endmodule
