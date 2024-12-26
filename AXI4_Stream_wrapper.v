module top (
    input axi_clk,axi_rst_n,
    //AXI4-S Master
    output reg m_axis_valid,
    output reg [127:0] m_axis_data,
    input m_axis_ready,
    //AXI4-S Slave
    input s_axis_valid,
    input [63:0] s_axis_data,
    output reg s_axis_ready
);
    wire [127:0] result;
    wire valid_out;
    
    systolic_array uut (
        .clk(axi_clk),
        .reset(!axi_rst_n),
        .matrixA(s_axis_data[63:32]),
        .matrixB(s_axis_data[31:0]),
        .valid_in(s_axis_valid),
        .result(result),
        .valid_out(valid_out)
    );

    always @(posedge axi_clk or negedge axi_rst_n) begin
        if (!axi_rst_n) begin
            m_axis_valid <= 0;
            m_axis_data <= 128'd0;
            s_axis_ready <= 1;
        end else begin
            m_axis_valid <= valid_out;
            m_axis_data <= result;
            s_axis_ready <= 1;
        end
    end
endmodule