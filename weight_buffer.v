//Weight buffer which takes input from DMA through the AXI4-S interface and feeds data to the systolic array in a time staggered manner
module weight_buffer (
    input axi_clk,axi_rst_n,
    //AXI4-S Slave
    input s_axis_valid,
    input [31:0] s_axis_data,
    output reg s_axis_ready,
    //Read interface
    input read_clk,read_rst_n,
    output reg [31:0] read_data, //4 weight lines for a 4x4 systolic array
    output reg buffer_full
);
    reg [31:0] data [0:1023];
    reg [9:0] write_ptr,read_ptr;

    reg [31:0] data_delay1,data_delay2,data_delay3;

    always @(posedge axi_clk or negedge axi_rst_n) begin
        if (!axi_rst_n) begin
            s_axis_ready <= 1;
            buffer_full <= 0;
            write_ptr <= 0;
        end else begin
            if (s_axis_valid & s_axis_ready & !buffer_full) begin
                if (write_ptr < 1023) begin
                    data[write_ptr] <= s_axis_data;
                    write_ptr <= write_ptr + 1;
                end else begin
                    buffer_full <= 1;
                    s_axis_ready <= 0;
                end
            end
        end
    end

    always @(posedge read_clk or negedge read_rst_n) begin
        if (!read_rst_n) begin
            read_ptr <= 0;
            read_data <= 0;
            data_delay1 <= 0;
            data_delay2 <= 0;
            data_delay3 <= 0;
        end else begin
            if (read_ptr < write_ptr) begin
                read_data <= {data[read_ptr][31:24],data_delay1[23:16],data_delay2[15:8],data_delay3[7:0]};
                data_delay1 <= data[read_ptr];
                data_delay2 <= data_delay1;
                data_delay3 <= data_delay2;
                read_ptr <= read_ptr + 1;
            end else begin
                read_data <= {8'd0,data_delay1[23:16],data_delay2[15:8],data_delay3[7:0]};
                data_delay1 <= 32'd0;
                data_delay2 <= data_delay1;
                data_delay3 <= data_delay2;
            end
        end
    end
endmodule