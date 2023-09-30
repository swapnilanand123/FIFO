class transaction;
  
  rand bit rd_en ,wr_en;
  rand bit [7:0] buf_in;
  bit buf_full, buf_empty;
  bit [7:0] buf_out;
  bit [7:0] fifo_counter;
  
  constraint wr_rd {  
    rd_en != wr_en;
    wr_en dist {0 :/ 50 , 1:/ 50};
    rd_en dist {0 :/ 50 , 1:/ 50};
    
  }
 
  
   constraint data_con {
  buf_in > 1; buf_in < 5;  
  }
  
  
   function void display(input string tag);
     $display("[%0s] : WR : %0b\t RD:%0b\t DATAWR : %0d\t DATARD : %0d\t FULL : %0b\t EMPTY : %0b @ %0t", tag, wr_en, rd_en, buf_in, buf_out, buf_full, buf_empty,$time);   
  endfunction
  
  function transaction copy();
    copy = new();
    copy.rd_en = this.rd_en;
    copy.wr_en = this.wr_en;
    copy.buf_in = this.buf_in;
    copy.buf_out= this.buf_out;
    copy.buf_full = this.buf_full;
    copy.buf_empty = this.buf_empty;
  endfunction
  
endclass

class generator;
  
   transaction tr;
   mailbox #(transaction) mbx;
  
   int count = 0;
  
   event next;  ///know when to send next transaction
   event done;  ////conveys completion of requested no. of transaction
   
   
  function new(mailbox #(transaction) mbx);
      this.mbx = mbx;
      tr=new();
   endfunction; 
  
 
   task run(); 
    
     repeat(count)	 
	     begin    
           assert(tr.randomize) else $error("Randomization failed");	
           mbx.put(tr.copy);
           tr.display("GEN");
           @(next);
         end 
     
     
     ->done;
   endtask
  
  
endclass
 

  
class driver;
  
   virtual fifo_if fif;
  
   mailbox #(transaction) mbx;
  
   transaction datac;
  
   event next;
  
   
 
    function new(mailbox #(transaction) mbx);
      this.mbx = mbx;
   endfunction; 
  
  ////reset DUT
  task reset();
    fif.rst <= 1'b1;
    fif.rd_en <= 1'b0;
    fif.wr_en <= 1'b0;
    fif.buf_in <= 0;
    repeat(5) @(posedge fif.clk);
    fif.rst <= 1'b0;
    $display("[DRV] : DUT Reset Done");
  endtask
   
  //////Applying RANDOM STIMULUS TO DUT
  task run();
    forever begin
      mbx.get(datac);
      
      datac.display("DRV");
      
      fif.rd_en <= datac.rd_en;
      fif.wr_en <= datac.wr_en;
      fif.buf_in <= datac.buf_in;
      repeat(2) @(posedge fif.clk);
      ->next;
    end
  endtask
  
  
endclass
 
 
 
class monitor;
 
   virtual fifo_if fif;
  
   mailbox #(transaction) mbx;
  
   transaction tr;
 
  
    function new(mailbox #(transaction) mbx);
      this.mbx = mbx;     
   endfunction;
  
  
  task run();
    tr = new();
    
    forever begin
      repeat(2) @(posedge fif.clk);
      tr.wr_en = fif.wr_en;
      tr.rd_en = fif.rd_en;
      tr.buf_in = fif.buf_in;
      tr.buf_out = fif.buf_out;
      tr.buf_full = fif.buf_full;
      tr.buf_empty = fif.buf_empty;
      
      
      mbx.put(tr);
      
      tr.display("MON");
 
    end
    
  endtask
  
 
  
endclass
 
/////////////////////////////////////////////////////
 
 
class scoreboard;
  
   mailbox #(transaction) mbx;
  
   transaction tr;
  
   event next;
  
  bit [7:0] din[$];
  bit[7:0] temp;
  
   function new(mailbox #(transaction) mbx);
      this.mbx = mbx;     
    endfunction;
  
  
  task run();
    
  forever begin
    
    mbx.get(tr);
    
    tr.display("SCO");
    
    if(tr.wr_en == 1'b1)
      begin 
        din.push_front(tr.buf_in);
        $display("[SCO] : DATA STORED IN QUEUE :%0d", tr.buf_in);
      end
    
    if(tr.rd_en == 1'b1)
      begin
        if(tr.buf_empty == 1'b0) begin 
          
          temp = din.pop_back();
          
          if(tr.buf_out == temp)
            $display("[SCO] : DATA MATCH");
           else
             $error("[SCO] : DATA MISMATCH");
        end
        else 
          begin
            $display("[SCO] : FIFO IS EMPTY");
          end
        
        
     end
    
    ->next;
  end
  endtask
 
  
endclass
//////////////////////////////////////
  
class environment;
 
    generator gen;
    driver drv;
  
    monitor mon;
    scoreboard sco;
  
  mailbox #(transaction) gdmbx; ///generator + Driver
    
  mailbox #(transaction) msmbx; ///Monitor + Scoreboard
 
  event nextgs;
 
 
  virtual fifo_if fif;
  
  
  function new(virtual fifo_if fif);
 
    
    
    gdmbx = new();
    gen = new(gdmbx);
    drv = new(gdmbx);
    
    
    
    
    msmbx = new();
    mon = new(msmbx);
    sco = new(msmbx);
    
    
    this.fif = fif;
    
    drv.fif = this.fif;
    mon.fif = this.fif;
    
    
    gen.next = nextgs;
    sco.next = nextgs;
 
  endfunction
  
  
  
  task pre_test();
    drv.reset();
  endtask
  
  task test();
  fork
    gen.run();
    drv.run();
    mon.run();
    sco.run();
  join_any
    
  endtask
  
  task post_test();
    wait(gen.done.triggered);  
    $finish();
  endtask
  
  task run();
    pre_test();
    test();
    post_test();
  endtask
  
  
  
endclass
 
 
 
 
 
 
  module tb;
    
   
    
    fifo_if fif();
    fifo dut (fif.clk, fif.rd_en, fif.wr_en,fif.buf_full, fif.buf_empty, fif.buf_in, fif.buf_out, fif.rst);
    
    initial begin
      fif.clk <= 0;
    end
    
    always #10 fif.clk <= ~fif.clk;
    
    environment env;
    
    
    
    initial begin
      env = new(fif);
      env.gen.count = 20;
      env.run();
    end
      
    
    initial begin
      $dumpfile("dump.vcd");
      $dumpvars;
    end
  endmodule
