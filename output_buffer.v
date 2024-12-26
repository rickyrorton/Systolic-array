module output_buffer (
    input axi_clk,axi_rst_n,
    //AXI4-S Master
    output reg m_axis_valid,
    output reg [31:0] m_axis_data,
    input m_axis_ready,
    //Write interface
    input [127:0] write_data
);
    reg [127:0] buffer;
    reg [1:0] chunk_sent;
    reg write_enable;

    always @(posedge axi_clk or negedge axi_rst_n) begin
        if (!axi_rst_n) begin
            write_enable <= 0;
            buffer <= 128'd0;
        end else begin
            write_enable <= 1;
            buffer <= write_data;
        end
    end

    always @(posedge axi_clk or negedge axi_rst_n) begin
        if (!axi_rst_n) begin
            m_axis_valid <= 0;
            m_axis_data <= 32'd0;
            chunk_sent <= 2'd0;
        end else begin
            if(m_axis_valid && m_axis_ready) begin
                chunk_sent <= chunk_sent + 1;
                case (chunk_sent)
                    2'd0: m_axis_data <= buffer[31:0];
                    2'd1: m_axis_data <= buffer[63:32];
                    2'd2: m_axis_data <= buffer[95:64];
                    2'd3: m_axis_data <= buffer[127:96];
                    default: m_axis_data <= 32'd0;
                endcase
                if (chunk_sent == 2'd3) begin
                    m_axis_valid <= 0;
                end
            end else if (!m_axis_valid && write_enable) begin
                m_axis_valid <= 1;
                chunk_sent <= 2'd0;
                m_axis_data <= 32'd0;
            end
        end
    end
    
endmodule