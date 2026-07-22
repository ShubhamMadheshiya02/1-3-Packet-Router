`include "uvm_macros.svh"
import uvm_pkg :: *;

class transaction extends uvm_sequence_item;

    function new(string path = "transaction");
        super.new(path);
    endfunction


        logic resetn;
   rand logic       read_en0;
   rand logic       read_en1;
   rand logic       read_en2;
        logic       pkt_valid;
   //rand logic [7:0] data_in;
   
   
        logic       busy;
        logic       err;
        logic       vld_out0;
        logic       vld_out1;
        logic       vld_out2;
        logic [7:0] data_out0;
        logic [7:0] data_out1;
        logic [7:0] data_out2;
        
        typedef enum {WRITE,READ}operation;
        rand operation  op;
        randc logic [1:0]address;
        randc logic [5:0]payload_size;
        randc logic [7:0]payload[$];
             logic [7:0]payload_out[$];
            bit [7:0] parity;
        
        `uvm_object_utils_begin(transaction)
        `uvm_field_int(resetn,UVM_DEFAULT);
        `uvm_field_int(read_en0,UVM_DEFAULT);
        `uvm_field_int(read_en1,UVM_DEFAULT);
        `uvm_field_int(read_en2,UVM_DEFAULT);
        `uvm_field_int(pkt_valid,UVM_DEFAULT);
     //   `uvm_field_int(data_in,UVM_DEFAULT);
        `uvm_field_int(busy,UVM_DEFAULT);
        `uvm_field_int(err,UVM_DEFAULT);
        `uvm_field_int(vld_out0,UVM_DEFAULT);
        `uvm_field_int(vld_out1,UVM_DEFAULT);
        `uvm_field_int(vld_out2,UVM_DEFAULT);
        `uvm_field_int(data_out0,UVM_DEFAULT);
        `uvm_field_int(data_out1,UVM_DEFAULT);
        `uvm_field_int(data_out2,UVM_DEFAULT);
        
        `uvm_field_int(address,UVM_DEFAULT);
        `uvm_field_int(payload_size,UVM_DEFAULT);
        `uvm_field_queue_int(payload,UVM_DEFAULT);
        `uvm_field_int(parity,UVM_DEFAULT);
        `uvm_object_utils_end
     
                         
         constraint write_read_op {
            if(op == WRITE)
                {
                    address inside {2'b00,2'b01,2'b10};
                    payload_size inside {[1:13]};
                    payload.size() == payload_size;
                    {read_en2, read_en1, read_en0} == 3'b000;
                }
           else if(op == READ)
             {
                address inside {2'b00,2'b01,2'b10};
                payload_size inside {[1:13]};
                payload.size() == 0;  
                
                (address == 2'b00) -> ({read_en2, read_en1, read_en0} == 3'b001);
                (address == 2'b01) -> ({read_en2, read_en1, read_en0} == 3'b010);
                (address == 2'b10) -> ({read_en2, read_en1, read_en0} == 3'b100);           
             }
                                }
                            
         
        function void post_randomize();
            if(op == WRITE)begin
                logic [7:0] header = {payload_size, address};
                this.parity = 8'b0;
                this.parity = this.parity ^ header;
                foreach (payload[i]) begin
                    this.parity = this.parity ^ payload[i];
                end
           end
    endfunction
        
        
endclass

class write_no_error extends uvm_sequence#(transaction);
    `uvm_object_utils(write_no_error);
    
    transaction tr;
    function new(string path = "write_no_error");
        super.new(path);
    endfunction
    
    virtual task body();
             tr = transaction::type_id::create("tr_write");
             start_item(tr);
             tr.op = transaction :: WRITE;
             tr.randomize();
             finish_item(tr);
             `uvm_info("write_no_error", "only wirte no err DONE", UVM_MEDIUM) 
      endtask
endclass

class read extends uvm_sequence#(transaction);
    `uvm_object_utils(read);
    
    transaction tr;
    function new(string path = "read");
        super.new(path);
    endfunction
    
    virtual task body();
             tr = transaction::type_id::create("tr_read");
             start_item(tr);
             tr.op = transaction ::READ;
             tr.randomize();
             finish_item(tr);
             `uvm_info("read", "only read DONE", UVM_MEDIUM) 
      endtask
endclass

class write_read extends uvm_sequence #(transaction);
    `uvm_object_utils(write_read);
    logic [1:0] wr_addr;
    transaction tr;
    function new(string path = "write_read");
        super.new(path);
    endfunction
    
    virtual task body();  
             tr = transaction::type_id::create("tr_write");
             start_item(tr);
             tr.randomize()with {
                    op == transaction::WRITE;
                            };
             wr_addr = tr.address;
             finish_item(tr);
             `uvm_info("WR_RD", "write DONE", UVM_MEDIUM) ;
             
             #(tr.payload_size *10);
             tr = transaction::type_id::create("tr_read");
             start_item(tr);
             tr.randomize()with {
                    op == transaction::READ;
                    address == wr_addr;
                                };
             finish_item(tr);
             `uvm_info("WR_RD", "read DONE", UVM_MEDIUM)        
      endtask
      
endclass

class multiple_write extends uvm_sequence #(transaction);

    `uvm_object_utils(multiple_write);
    
    transaction tr;
    function new(string path = "multiple_write");
        super.new(path);
    endfunction
    
    virtual task body();
            repeat(5)begin
                 tr = transaction::type_id::create("tr_write");
                 start_item(tr);
                 tr.op = transaction::WRITE;
                 tr.randomize();
                 finish_item(tr);
                 `uvm_info("multiple_write", "DONE", UVM_MEDIUM)
             end 
      endtask
endclass

class write_error extends uvm_sequence#(transaction);
    `uvm_object_utils(write_error);
    
    transaction tr;
    function new(string path = "write_error");
        super.new(path);
    endfunction
    
    virtual task body();
             tr = transaction::type_id::create("tr_write");
             start_item(tr);
             tr.op = transaction::WRITE;
             tr.randomize();
             tr.parity = $urandom_range(255,0);
             finish_item(tr);
             `uvm_info("write_error", "DONE", UVM_MEDIUM) 
      endtask

endclass

class driver extends uvm_driver #(transaction);
    `uvm_component_utils(driver);
    
    transaction tr;
    virtual router_if vif;
    function new(string path = "driver",uvm_component parent = null);
        super.new(path,parent);
    endfunction 
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //tr = transaction :: type_id :: create("tr");
        if (!uvm_config_db#(virtual router_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Could not get virtual interface handle for the driver")
    endfunction  
    
    task reset();
        `uvm_info("DRV", "Resetting DUT", UVM_MEDIUM)
        repeat(5)begin
            vif.resetn <= 1'b0;
            vif.read_en0 <= 1'b0;
            vif.read_en1 <= 1'b0;
            vif.read_en2 <= 1'b0;
            vif.pkt_valid <= 1'b0;
            vif.data_in <= 8'd0;
            @(posedge vif.clk);
        end
        `uvm_info("DRV", "Reset complete", UVM_MEDIUM)
    endtask
    
    task drive_write();
                vif.resetn <= 1'b1;
                wait(!vif.busy);
                @(negedge vif.clk);
                vif.pkt_valid <= 1'b1;
                vif.data_in <= {tr.payload_size,tr.address};
                @(negedge vif.clk);
                for(int i = 0 ; i < tr.payload_size ; i++)begin
                    vif.data_in <= tr.payload[i];
                    @(negedge vif.clk);  
                end
                @(negedge vif.clk)
                vif.pkt_valid <= 1'b0;
                vif.data_in <= tr.parity;
      `uvm_info("DRV","WRITE DONE",UVM_NONE);  
    endtask
    
    task drive_read();
              vif.read_en0 <= tr.read_en0;
              vif.read_en1 <= tr.read_en1;
              vif.read_en2 <= tr.read_en2;
              repeat(tr.payload_size)@(negedge vif.clk);
              `uvm_info("DRV","READ DONE",UVM_NONE);  
              vif.read_en0 <= 1'b0;
              vif.read_en1 <= 1'b0;
              vif.read_en2 <= 1'b0;
    endtask
    
    virtual task run_phase(uvm_phase phase);
        reset();
        forever begin
            seq_item_port.get_next_item(tr);
            case (tr.op)
                transaction ::WRITE: drive_write();
                transaction ::READ:  drive_read();
            endcase
            seq_item_port.item_done();
        end
    endtask
   
endclass
class monitor extends uvm_monitor;
    `uvm_component_utils(monitor);
    
    transaction tr;
    virtual router_if vif;
    uvm_analysis_port#(transaction) send;
    
    function new(string path = "monitor",uvm_component parent = null);
        super.new(path,parent);
    endfunction 
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        send = new("send",this);
        if (!uvm_config_db#(virtual router_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Could not get virtual interface handle for the driver")
    endfunction
    
   task monitor_write();
       logic [7:0] header;
       @(posedge vif.pkt_valid);
        `uvm_info("MON", "Detected start of WRITE transaction", UVM_HIGH)
        tr = transaction::type_id::create("tr_mon_write");
        tr.op = transaction :: WRITE;
        @(posedge vif.clk);
        
        header = vif.data_in;
        tr.payload_size = header[7:2];
        tr.address      = header[1:0];
        
        for (int i = 0; i < tr.payload_size; i++) begin
            @(posedge vif.clk);
            tr.payload.push_back(vif.data_in); 
        end
        @(posedge vif.clk);
        tr.parity = vif.data_in;
        tr.err = vif.err;
        
        `uvm_info("MON", $sformatf("WRITE transaction captured:\n%s", tr.sprint()), UVM_NONE)
        send.write(tr);
   endtask
   
   task monitor_read();
        @(posedge vif.read_en0 or posedge vif.read_en1 or posedge vif.read_en2);
        `uvm_info("MON", "Detected start of READ transaction", UVM_NONE)
        tr = transaction::type_id::create("tr_mon_read");
        tr.op = transaction :: READ;
        if (vif.read_en0) begin
            tr.address = 2'b00;
            tr.payload_size = vif.data_in[7:2];
            repeat(tr.payload_size) begin
                @(posedge vif.clk);
                tr.payload_out.push_back(vif.data_out0);
            end
        end
        else if (vif.read_en1) begin
            tr.address = 2'b01;
            tr.payload_size = vif.data_in[7:2];
            repeat(tr.payload_size) begin
                @(posedge vif.clk);
                tr.payload_out.push_back(vif.data_out1);
            end
        end
        else if (vif.read_en2) begin
            tr.address = 2'b10;
            tr.payload_size = vif.data_in[7:2];
            repeat(tr.payload_size) begin
                @(posedge vif.clk);
                tr.payload_out.push_back(vif.data_out2);
            end
        end
        `uvm_info("MON", $sformatf("READ transaction captured:\n%s", tr.sprint()), UVM_NONE)
        send.write(tr);

    endtask
    
   
    virtual task run_phase(uvm_phase phase);
        forever begin
            fork
                monitor_write();
                monitor_read();
            join_any
        end    
    endtask

endclass


class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard);

    uvm_analysis_imp #(transaction, scoreboard) rcvd;
    transaction expected_q[logic [1:0]][$];

    function new(string name = "scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        rcvd = new("rcvd", this);
    endfunction
    
    virtual function void write(transaction tr);
        transaction tr_clone;
        transaction expected_tr;
       
        case (tr.op)
            transaction :: WRITE: begin
            
                if (tr.err == 0) begin
                    `uvm_info("SCB", $sformatf("Storing expected WRITE for address %h", tr.address), UVM_HIGH);
                    $cast(tr_clone, tr.clone());
                    expected_q[tr.address].push_back(tr_clone);
                end else begin
                    `uvm_info("SCB", "Ignoring erroneous WRITE transaction.", UVM_HIGH);
                end
            end

            transaction :: READ: begin
                `uvm_info("SCB", $sformatf("Checking READ from address %h", tr.address), UVM_HIGH);
                
                if (expected_q[tr.address].size() == 0) begin
                    `uvm_error("SCB", $sformatf("Received unexpected READ from address %h. No writes were pending.", tr.address));
                    return;
                end

                expected_tr = expected_q[tr.address].pop_front();
                
                if (tr.payload_out.size() != expected_tr.payload.size()) begin
                    `uvm_error("SCB", $sformatf("FAIL: Address %h payload size mismatch. Expected: %0d, Got: %0d",
                                      tr.address, expected_tr.payload.size(), tr.payload_out.size()));
                end else if (!compare_payloads(tr.payload_out, expected_tr.payload)) begin
                     `uvm_error("SCB", $sformatf("FAIL: Address %h payload content mismatch.", tr.address));
                     `uvm_info("SCB", $sformatf("Expected TR:\n%s\nActual TR:\n%s", expected_tr.sprint(), tr.sprint()), UVM_NONE)
                end else begin
                    `uvm_info("SCB", $sformatf("PASS: Read data matches for address %h.", tr.address), UVM_MEDIUM);
                end
            end
        endcase
    endfunction
    
    function bit compare_payloads(logic [7:0] q1[$], logic [7:0] q2[$]);
        if (q1.size() != q2.size()) return 0;
        foreach(q1[i]) begin
            if (q1[i] != q2[i]) return 0;
        end
        return 1;
    endfunction
    
    function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        foreach(expected_q[i]) begin
            if (expected_q[i].size() > 0) begin
                `uvm_error("SCB", $sformatf("DUT dropped %0d packets for address %h", expected_q[i].size(), i));
            end
        end
    endfunction

endclass


class agent extends uvm_agent;
    `uvm_component_utils(agent);
    
    function new(string path = "agent",uvm_component parent = null);
        super.new(path,parent);
    endfunction
    
    driver d;
    uvm_sequencer#(transaction) seqr;
    monitor m;
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        d = driver :: type_id :: create("d",this);
        m = monitor :: type_id :: create("m",this);
        seqr = uvm_sequencer#(transaction) :: type_id :: create("seqr",this);
    endfunction
    
    virtual function void connect_phase(uvm_phase phase);
       super.connect_phase(phase);
       d.seq_item_port.connect(seqr.seq_item_export);
    endfunction
    
endclass

class env extends uvm_env;
    `uvm_component_utils(env);
    
    function new(string path = "env",uvm_component parent = null);
        super.new(path,parent);
    endfunction
    
    agent a;
    scoreboard sco;
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        a = agent :: type_id :: create("a",this);
        sco = scoreboard :: type_id :: create("sco",this);
    endfunction
    
    virtual function void connect_phase(uvm_phase phase);
       super.connect_phase(phase);
       a.m.send.connect(sco.rcvd);
    endfunction


endclass

class seq_lib extends uvm_sequence_library #(transaction);
    `uvm_sequence_library_utils(seq_lib);
    
    function new(string path = "seq_lib");
        super.new(path);
        add_typewide_sequence(write_no_error :: get_type());
        add_typewide_sequence(read :: get_type());
        add_typewide_sequence(write_read :: get_type());
        add_typewide_sequence(multiple_write :: get_type());
        add_typewide_sequence(write_error :: get_type());
    endfunction  
    



endclass

class test extends uvm_test;
    `uvm_component_utils(test);
    
    function new(string path = "test",uvm_component parent = null);
        super.new(path,parent);
    endfunction   
    
    env e;
    write_no_error w_nerr;
    read rd;
    write_read wr_rd;
    multiple_write m_wr;
    write_error w_err;
    
    
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        e = env :: type_id :: create("e",this);
        w_nerr = write_no_error :: type_id :: create("w_nerr");
        wr_rd = write_read :: type_id :: create("wr_rd");
        rd = read :: type_id :: create("rd");
        m_wr = multiple_write :: type_id :: create("m_wr");
        w_err = write_error :: type_id :: create("w_err");
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
            m_wr.start(e.a.seqr);
            #2000;
         phase.drop_objection(this);
    endtask

endclass

module tb;

router_if vif();

    initial begin
        vif.clk = 0;
        forever #5 vif.clk = ~vif.clk;
    end

ROUTER dut(
      .clk(vif.clk),
      .resetn(vif.resetn),
      .read_en0(vif.read_en0),
      .read_en1(vif.read_en1),
      .read_en2(vif.read_en2),
      .pkt_valid(vif.pkt_valid),
      .data_in(vif.data_in),
      .busy(vif.busy),
      .err(vif.err),
      .vld_out0(vif.vld_out0),
      .vld_out1(vif.vld_out1),
      .vld_out2(vif.vld_out2),
      .data_out0(vif.data_out0),
      .data_out1(vif.data_out1),
      .data_out2(vif.data_out2)
    );
    
    initial begin
        uvm_config_db#(virtual router_if)::set(null, "uvm_test_top.*", "vif", vif);
        run_test("test");
    end


endmodule
