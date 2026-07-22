module FSM_CONTROLLER(
    input clk,
    input resetn,
    input pkt_valid,
    input fifo_full,
    input fifo_empty0,fifo_empty1,fifo_empty2,
    input soft_reset0,soft_reset1,soft_reset2,
    input parity_done,
    input low_packet_valid,
    input [1:0]fifo_add,
    output write_en,
    output detect_add,
    output ld_state,
    output laf_state,
    output lfd_state,
    output full_state,
    output parity_check_state,
    output busy,
    output load_parity_state
    

    );
    
    typedef enum bit[2:0]{DETECT_ADD,LOAD_ADDRESS,LOAD_DATA,FIFO_FULL,WAIT_TILL_EMPTY,
                            LOAD_AFTER_FULL,CHECK_PARITY_ERROR,LOAD_PARITY} fsm_states;
     fsm_states ps,ns;
     logic [1:0] stored_addr;
     
     always @(posedge clk)begin
        if(!resetn)begin
            ps <= DETECT_ADD;
        end
        else
            ps <= ns;
     
     end
     
     always @(*)begin
        ns = ps; 
        case(ps)
        DETECT_ADD : begin
                        if((pkt_valid && (fifo_add==0) && fifo_empty0)||
                           (pkt_valid && (fifo_add==1) && fifo_empty1)||
                           (pkt_valid && (fifo_add==2) && fifo_empty2))begin
                            ns = LOAD_ADDRESS;
                            stored_addr = fifo_add; 
                           end
                        else if((pkt_valid && (fifo_add==0) && (~fifo_empty0))||
                                (pkt_valid && (fifo_add==1) && (~fifo_empty1))||
                                (pkt_valid && (fifo_add==2) && (~fifo_empty2)))
                            ns = WAIT_TILL_EMPTY;
                        else
                            ns = DETECT_ADD;     
                     end
         LOAD_ADDRESS : begin
                            if(pkt_valid)
                                ns = LOAD_DATA;
                            else
                                ns = DETECT_ADD;    
                        end
         LOAD_DATA : begin
                        if(fifo_full)begin
                            ns = FIFO_FULL;
                        end
                        else if(!pkt_valid)
                            ns = LOAD_PARITY;    
                        else
                            ns = LOAD_DATA;
                    end 
         LOAD_PARITY : begin
                            ns = CHECK_PARITY_ERROR;            
                       end
         CHECK_PARITY_ERROR : begin
                                if(fifo_full)
			      	 			ns =FIFO_FULL;
			    			else if(parity_done)
			         			ns = DETECT_ADD;     
                              end 
         WAIT_TILL_EMPTY : begin
                                if((stored_addr == 0 && fifo_empty0) || (stored_addr == 1 && fifo_empty1) || (stored_addr == 2 && fifo_empty2)) begin
                                    ns = LOAD_ADDRESS;
                                end
                                else
                                    ns = WAIT_TILL_EMPTY;
                           end
         FIFO_FULL : begin
                            if(!fifo_full)
                                ns = LOAD_AFTER_FULL;
                            else
                                ns = FIFO_FULL;     
                     end
         LOAD_AFTER_FULL : begin
                                if(parity_done)
                                    ns = DETECT_ADD;
                                else if(!low_packet_valid)
                                    ns = LOAD_DATA;
                                else if(low_packet_valid)
                                    ns = LOAD_PARITY;
                                
                            end
         endcase
     end
  
    assign detect_add  = (ps == DETECT_ADD);
    assign lfd_state   = (ps == LOAD_ADDRESS);
    assign ld_state    = (ps == LOAD_DATA);
    assign full_state  = (ps == FIFO_FULL);
    assign laf_state   = (ps == LOAD_AFTER_FULL);
    assign parity_check_state = (ps == CHECK_PARITY_ERROR);
    assign load_parity_state = (ps == LOAD_PARITY);

    assign write_en    = /*(ps == LOAD_ADDRESS) ||*/ (ps == LOAD_DATA) || (ps == LOAD_PARITY) || (ps == LOAD_AFTER_FULL);
    assign busy        = (ps != DETECT_ADD);
     
endmodule
