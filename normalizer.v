module normalize (
    input signed [15:0] data_in,
    output reg signed [7:0] data_out
);
    always @(*) begin
        if (data_in >= 128) begin
            data_out = 8'd127;
        end else if (data_in <= -128) begin
            data_out = -8'd128;
        end else begin
            data_out = $signed(data_in[7:0]);
        end
    end
endmodule