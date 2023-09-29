module FIFO(
  input clk,
  input rst,
  input [7:0] buf_in,
  input wr_en,
  input rd_en,
  output reg [7:0] buf_out,
  output reg buf_empty,
  output reg buf_full,
  output reg [7:0] fifo_counter
);

  reg [7:0] fifo_counter_next;
  reg [7:0] wr_ptr;
  reg [7:0] rd_ptr;
  reg [7:0] buf_mem [63:0];

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      fifo_counter <= 0;
      wr_ptr <= 0;
      rd_ptr <= 0;
      buf_out <= 0;
      buf_empty <= 1;
      buf_full <= 0;
    end else begin
      //  wr_ptr and buf_mem on rising edge of clk
      if (wr_en && !buf_full) begin
        buf_mem[wr_ptr] <= buf_in;
        wr_ptr <= (wr_ptr == 63) ? 0 : wr_ptr + 1;
      end

      //  rd_ptr and buf_out on rising edge of clk
      if (rd_en && !buf_empty) begin
        buf_out <= buf_mem[rd_ptr];
        rd_ptr <= (rd_ptr == 63) ? 0 : rd_ptr + 1;
      end

      // fifo_counter
      fifo_counter_next <= fifo_counter;

      if (!buf_full && wr_en) begin
        fifo_counter_next <= fifo_counter + 1;
      end else if (!buf_empty && rd_en) begin
        fifo_counter_next <= fifo_counter - 1;
      end

      // buf_empty and buf_full
      buf_empty <= (fifo_counter_next == 0);
      buf_full <= (fifo_counter_next == 64);

      fifo_counter <= fifo_counter_next;
    end
  end
endmodule
