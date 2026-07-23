`timescale 1ns/1ps

module router_top_tb;

reg clk;
reg resetn;
reg read_en0;
reg read_en1;
reg read_en2;
reg pkt_valid;
reg [7:0] data_in;

wire [7:0] data_out0;
wire [7:0] data_out1;
wire [7:0] data_out2;

wire vld_out0;
wire vld_out1;
wire vld_out2;
wire err;
wire busy;

integer i;

ROUTER DUT(
    .clk(clk),
    .resetn(resetn),
    .read_en0(read_en0),
    .read_en1(read_en1),
    .read_en2(read_en2),
    .pkt_valid(pkt_valid),
    .data_in(data_in),
    .busy(busy),
    .err(err),
    .vld_out0(vld_out0),
    .vld_out1(vld_out1),
    .vld_out2(vld_out2),
    .data_out0(data_out0),
    .data_out1(data_out1),
    .data_out2(data_out2)
);

initial
begin
    clk = 1'b1;
    forever #5 clk = ~clk;
end

task reset;
begin
    @(negedge clk);
    resetn = 1'b0;

    @(negedge clk);
    resetn = 1'b1;
end
endtask

task initialize;
begin
    resetn = 1'b1;
    read_en0 = 0;
    read_en1 = 0;
    read_en2 = 0;
    pkt_valid = 0;
    data_in = 8'd0;
end
endtask

task pktm_gen_5;

reg [7:0] header;
reg [7:0] payload_data;
reg [7:0] parity;
reg [8:0] payloadlen;

begin

    parity = 0;

    wait(!busy);

    @(negedge clk);
    payloadlen = 5;
    pkt_valid = 1'b1;
    header = {payloadlen,2'b10};
    data_in = header;
    parity = parity ^ data_in;

    @(negedge clk);

    for(i=0;i<payloadlen;i=i+1)
    begin
        @(negedge clk);
        payload_data = $random % 256;
        data_in = payload_data;
        parity = parity ^ data_in;
    end

    @(negedge clk);
    pkt_valid = 0;
    data_in = parity;

    repeat(2)
        @(negedge clk);

    read_en2 = 1'b1;

    wait(DUT.fifo_2.empty);

    @(negedge clk);
    read_en2 = 0;

end
endtask

task pktm_gen_14;

reg [7:0] header;
reg [7:0] payload_data;
reg [7:0] parity;
reg [8:0] payloadlen;

begin

    parity = 0;

    wait(!busy);

    @(negedge clk);
    payloadlen = 14;
    pkt_valid = 1'b1;
    header = {payloadlen,2'b01};
    data_in = header;
    parity = parity ^ data_in + 1;

    @(negedge clk);

    for(i=0;i<payloadlen;i=i+1)
    begin
        @(negedge clk);
        payload_data = $random % 256;
        data_in = payload_data;
        parity = parity ^ data_in;
    end

    @(negedge clk);
    pkt_valid = 0;
    data_in = parity;

    repeat(2)
        @(negedge clk);

    read_en1 = 1'b1;

    wait(DUT.fifo_1.empty);

    @(negedge clk);
    read_en1 = 0;

end
endtask

task pktm_gen_16;

reg [7:0] header;
reg [7:0] payload_data;
reg [7:0] parity;
reg [8:0] payloadlen;

begin

    parity = 0;

    wait(!busy);

    @(negedge clk);
    payloadlen = 16;
    pkt_valid = 1'b1;
    header = {payloadlen,2'b00};
    data_in = header;
    parity = parity ^ data_in;

    @(negedge clk);

    for(i=0;i<payloadlen;i=i+1)
    begin

        if(DUT.fifo_0.full)
        begin
            @(negedge clk);
            read_en0 = 1'b1;
        end
        else
        begin
            @(negedge clk);
            payload_data = $random % 256;
            data_in = payload_data;
            parity = parity ^ data_in;
        end

    end

    @(negedge clk);
    pkt_valid = 0;
    data_in = parity;

    repeat(2)
        @(negedge clk);

    read_en0 = 1'b1;

    wait(DUT.fifo_0.empty);

    @(negedge clk);
    read_en0 = 0;

end
endtask

initial
begin

    initialize;

    reset;

    #10;

    pktm_gen_5;

    #100;

    // pktm_gen_14;

    // #100;

    pktm_gen_16;

    #700;

    $finish;

end

endmodule





















































module router_top_tb;
  

reg clk, resetn, read_en0, read_en1, read_en2, pkt_valid;
reg [7:0]data_in;
wire [7:0]data_out0, data_out1, data_out2;
wire vld_out0, vld_out1, vld_out2, err, busy;
integer i;

      ROUTER DUT (
        .clk(clk),
        .resetn(resetn),
        .read_en0(read_en0),
        .read_en1(read_en1),
        .read_en2(read_en2),
        .pkt_valid(pkt_valid),
        .data_in(data_in),
        .busy(busy),
        .err(err),
        .vld_out0(vld_out0),
        .vld_out1(vld_out1),
        .vld_out2(vld_out2),
        .data_out0(data_out0),
        .data_out1(data_out1),
        .data_out2(data_out2)
    );
    
		   
			   
//clock generation

initial 
	begin
	clk = 1;
	forever 
	#5 clk=~clk;
	end
	
	
	task reset;
		begin
		    @(negedge clk)
			resetn=1'b0;
			@(negedge clk)
			resetn=1'b1;
		end
	endtask
	
	task initialize;
	    begin
		   resetn = 1'b1;
		   {read_en0, read_en1, read_en2, pkt_valid}=0;
		end
    endtask
		
	
	task pktm_gen_5;	// packet generation payload 5
			reg [7:0]header, payload_data, parity;
			reg [8:0]payloadlen;
			
			begin
				parity=0;
				wait(!busy)
				begin
				@(negedge clk);
				payloadlen=5;
				pkt_valid=1'b1;
				header={payloadlen,2'b10};
				data_in=header;
				parity=parity^data_in;
				end
				@(negedge clk);
							
				for(i=0;i<payloadlen;i=i+1)
					begin  
                        @(negedge clk);
                        payload_data={$random}%256;
                        data_in=payload_data;
                        parity=parity^data_in;  
					end
                    begin
                        @(negedge clk);
                        pkt_valid=0;				
                        data_in=parity;
                    end  
              repeat(2)
			@(negedge clk);
			read_en2=1'b1;
              
              wait(DUT.fifo_2.empty)
           @(negedge clk)
           read_en2=0;  
			end
      
endtask
	
	task pktm_gen_14;	// packet generation payload 14
			reg [7:0]header, payload_data, parity;
			reg [8:0]payloadlen;
			
			begin
				parity=0;
				wait(!busy)
				begin
				@(negedge clk);
				payloadlen=14;
				pkt_valid=1'b1;
				header={payloadlen,2'b01};
				data_in=header;
				parity=parity^data_in+1;
				end
				@(negedge clk);
							
				for(i=0;i<payloadlen;i=i+1)
					begin
                    begin  
					@(negedge clk);
					payload_data={$random}%256;
					data_in=payload_data;
					parity=parity^data_in;
                    end  
					end	
                    begin
					@(negedge clk);
					pkt_valid=0;				
					data_in=parity;
                    end  
              repeat(2)
			@(negedge clk);
			read_en1=1'b1;
              
              wait(DUT.fifo_1.empty)
           @(negedge clk)
           read_en1=0;  
			end
endtask

	task pktm_gen_16;	// packet generation payload 16
			reg [7:0]header, payload_data, parity;
			reg [8:0]payloadlen;
			
			begin
				parity=0;
				wait(!busy)
				begin
                    @(negedge clk);
                    payloadlen=16;
                    pkt_valid=1'b1;
                    header={payloadlen,2'b00};
                    data_in=header;
                    parity=parity^data_in;
				end
				@(negedge clk);
							
				for(i=0;i<payloadlen;i=i+1)
				begin  
                        if(DUT.fifo_0.full)begin
                            @(negedge clk);
			                 read_en0=1'b1;   
                        end 
                        else 
                        begin
                            @(negedge clk);
                            payload_data={$random}%256;
                            data_in=payload_data;
                            parity=parity^data_in;
                        end 
				end
                begin
                    @(negedge clk);
                     pkt_valid=0;				
                     data_in=parity;
                    end  
              repeat(2)
			@(negedge clk);
			read_en0=1'b1;
              
              wait(DUT.fifo_0.empty)
               @(negedge clk)
               read_en0=0;  
			end
endtask


	
	initial
		begin
		    initialize;
			reset;
			#10;
			pktm_gen_5;
            #100;
            //reset;
			/*pktm_gen_14;
			#100;*/
			pktm_gen_16;
			#700;

			$finish;
		end
		
		
endmodule
