# Define the Verilog module 'fifo'
define_module -rtl -language Verilog -module fifo -ports {
    clk { clk input }
    rst { rst input }
    buf_in { buf_in input [7:0] }
    wr_en { wr_en input }
    rd_en { rd_en input }
    buf_out { buf_out output [7:0] }
    buf_empty { buf_empty output }
    buf_full { buf_full output }
    fifo_counter { fifo_counter output [7:0] }
}

# Declare internal registers and wires
add_register -rtl -reset 0 -bits 8 fifo_counter_next
add_register -rtl -reset 0 -bits 8 wr_ptr
add_register -rtl -reset 0 -bits 8 rd_ptr
add_register -rtl -reset 0 -bits 8 -array 64 buf_mem

# Define the always block
create_process -name fifo_logic -type VHDL -inputs { clk rst wr_en rd_en buf_in } -outputs { buf_out buf_empty buf_full fifo_counter } -wait_for buf_mem -sensitivity { clk rising_edge } {
    if { rst } {
        set fifo_counter 8'b0
        set wr_ptr 8'b0
        set rd_ptr 8'b0
        set buf_out 8'b0
        set buf_empty 1
        set buf_full 0
    } else {
        if { wr_en && !buf_full } {
            set buf_mem(wr_ptr) buf_in
            set wr_ptr (wr_ptr == 8'h3F) ? 8'h00 : wr_ptr + 1
        }

        if { rd_en && !buf_empty } {
            set buf_out buf_mem(rd_ptr)
            set rd_ptr (rd_ptr == 8'h3F) ? 8'h00 : rd_ptr + 1
        }

        set fifo_counter_next $fifo_counter

        if { !buf_full && wr_en } {
            set fifo_counter_next [expr $fifo_counter + 1]
        } elseif { !buf_empty && rd_en } {
            set fifo_counter_next [expr $fifo_counter - 1]
        }

        set buf_empty [expr $fifo_counter_next == 8'b0]
        set buf_full [expr $fifo_counter_next == 8'h40]

        set fifo_counter $fifo_counter_next
    }
}

exit
