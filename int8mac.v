module int8mac (
    input [7:0] inA,
    input [7:0] inB,
    input clk, reset,
    output reg[7:0] outA,
    output reg[7:0] outB,
    output reg[15:0] result
);

wire [15:0] product;

always @(posedge clk or negedge reset) begin
    if (!reset) begin
        result <= 16'd0;
        outA <= 8'd0;
        outB <= 8'd0;
    end
    else begin
        result <= result + product;
        outA <= inA;
        outB <= inB;
    end
end

assign product = inA * inB;
endmodule