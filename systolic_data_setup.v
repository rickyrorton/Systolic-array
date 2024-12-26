//Try modfying some of this code to not use a FIFO instead directly stream from DDR

//Weight buffer which takes input from DMA through the AXI4-S interface and feeds data to the systolic array in a time staggered manner
module weight_buffer (
    input axi_clk,axi_rst_n,
    //AXI4-S Slave
    input s_axis_valid,
    input [31:0] s_axis_data,
    output reg s_axis_ready,
    //Read interface
    output [31:0] read_data //4 weight lines for a 4x4 systolic array
);
    reg [31:0] data;
    reg [31:0] data_delay1,data_delay2,data_delay3;

    always @(posedge axi_clk or negedge axi_rst_n) begin
        if (!axi_rst_n) begin
            s_axis_ready <= 1;
            data <= 32'd0;
            data_delay1 <= 32'd0;
            data_delay2 <= 32'd0;
            data_delay3 <= 32'd0;
        end else begin
            if (s_axis_valid & s_axis_ready) begin
                data <= s_axis_data;
                data_delay1 <= data;
                data_delay2 <= data_delay1;
                data_delay3 <= data_delay2;    
            end else begin
                data <= 32'd0;
                data_delay1 <= data;
                data_delay2 <= data_delay1;
                data_delay3 <= data_delay2;
            end
        end
    end

    assign read_data = {data[31:24],data_delay1[23:16],data_delay2[15:8],data_delay3[7:0]};

endmodule