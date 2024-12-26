module int8mac (
    input signed [7:0] inA,
    input signed [7:0] inB,
    input clk, reset,
    //input valid_in,
    output reg signed [7:0] outA,
    output reg signed [7:0] outB,
    output signed [7:0] result//,
    //output reg valid_out
);

reg [15:0] product;
wire [7:0] norm_product;

normalize norm(.data_in(product), .data_out(norm_product));

always @(posedge clk or negedge reset) begin
    if (!reset) begin
        product <= 16'd0;
        outA <= 8'd0;
        outB <= 8'd0;
    end
    else begin
        product <= product + inA*inB;
        outA <= inA;
        outB <= inB;
    end
end

assign result = norm_product;
endmodule