module tb_router_fifo;

  // Testbench Signals
  reg clk;
  reg resetn;
  reg write_enb;
  reg read_enb;
  reg [7:0] data_in;
  wire empty;
  wire full;
  wire [7:0] data_out;
  
  // Instantiate the FIFO module
  router_fifo uut (
    .clk(clk),
    .resetn(resetn),
    .write_enb(write_enb),
    .read_enb(read_enb),
    .data_in(data_in),
    .empty(empty),
    .full(full),
    .data_out(data_out)
  );

  // Generate Clock
  always #5 clk = ~clk; // Clock period = 10 time units

  // Test Procedure
  initial begin
    // Initialize signals
    clk = 0;
    resetn = 0;
    write_enb = 0;
    read_enb = 0;
    data_in = 8'h00;

    // Apply Reset
    #10 resetn = 1;

    // Test 1: Write data into FIFO until it's full
    #10 write_enb = 1;
    for (int i = 0; i < 16; i = i + 1) begin
      data_in = $urandom%100;
      #10;
      if (full) begin
        $display("FIFO is full at count %d", i);
        write_enb = 0;
        #10;
        break;
      end
    end

    // Test 2: Read data from FIFO until it's empty
    write_enb = 0;
    read_enb = 1;
    #10;
    for (int i = 0; i < 16; i = i + 1) begin
      #10;
      if (empty) begin
        $display("FIFO is empty at count %d", i);
        read_enb = 0;
        #10;
        break;
      end
    end

    // Test 3: Write and Read simultaneously
    write_enb = 1;
    read_enb = 1;
    data_in = 8'hAA;
    #10;
    data_in = 8'hBB;
    #10;
    data_in = 8'hCC;
    #10;
    write_enb = 0;
    read_enb = 0;

    // End of simulation
    #50 $stop;
  end

  // Monitor signals
  initial begin
    $monitor("Time=%0d | Reset=%b | Write Enb=%b | Read Enb=%b | Data In=%h | Data Out=%h | Full=%b | Empty=%b",
             $time, resetn, write_enb, read_enb, data_in, data_out, full, empty);
  end
  initial begin $dumpfile("dump.vcd"); $dumpvars; end
endmodule
