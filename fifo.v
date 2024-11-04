// Code your design here
module router_fifo(
	input clk,resetn,write_enb,read_enb,
	input [7:0]data_in,
	output reg empty,full,
	output reg [7:0]data_out
	);

  reg [4:0]count;
  reg [3:0] rd_ptr,wr_ptr;

  reg [7:0]mem[15:0];
  
  always@(count)
    begin
      empty=(count==0);
      full=(count==16);
    end
	
//counter block
  always@(posedge clk) 
    begin
      if(!resetn)
		count<=0;
      else if((!full&&write_enb)&&(!empty&&read_enb))
        count<=count;
      else if(write_enb&&!full)
        count<=count+1;
      else if(read_enb&&!empty)
        count<=count-1;
      else 
        count<=count;
    end
	
	//read block
	always@(posedge clk)
	if(!resetn)
		data_out<=8'hzz;
	else if(empty)
			data_out<=8'hzz;
	else 
		begin
          if(read_enb&&!empty)
            data_out<=mem[rd_ptr];
          else
            data_out<=data_out;
        end

					
	//write block
  always@(posedge clk)
    begin
      if(write_enb&&!full)
        mem[wr_ptr]<=data_in;
      else
        mem[wr_ptr]<=mem[wr_ptr];
    end
	
	//pointer update
always@(posedge clk )
  begin
    if(!resetn)
      begin 
        wr_ptr<=0;
        rd_ptr<=0;
      end
    else 
      begin
        if(!full&&write_enb)
          wr_ptr<=wr_ptr+1;
        else
          wr_ptr<=wr_ptr;
			if(!empty&&read_enb)
			rd_ptr<=rd_ptr+1;
			else
			rd_ptr<=rd_ptr;
		end
	end
endmodule
