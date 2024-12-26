module systolic_array(
    input clk,
    input reset,
    input [31:0] matrixA,
    input [31:0] matrixB,
    input valid_in,
    output [127:0] result,
    output reg valid_out
);
    wire [31:0] inA,inB;
    wire [7:0] inA0,inA1,inA2,inA3,inA4,inA5,inA6,inA7,inA8,inA9,inA10,inA11,inA12,inA13,inA14,inA15;
    wire [7:0] inB0,inB1,inB2,inB3,inB4,inB5,inB6,inB7,inB8,inB9,inB10,inB11,inB12,inB13,inB14,inB15;
    wire [7:0] out0,out1,out2,out3,out4,out5,out6,out7,out8,out9,out10,out11,out12,out13,out14,out15;

    //Valid input control
    assign inA = valid_in ? matrixA : 32'd0;
    assign inB = valid_in ? matrixB : 32'd0;

    //Valid output control
    reg [3:0]count;

    //Buffer register to stagger data in time
    reg [7:0] inA1_buf0,inA2_buf0,inA2_buf1,inA3_buf0,inA3_buf1,inA3_buf2;
    reg [7:0] inB4_buf0,inB8_buf0,inB8_buf1,inB12_buf0,inB12_buf1,inB12_buf2;

    //Wires to connect to the systolic array
    assign inA0 = inA[31:24];
    assign inA1 = inA[23:16];
    assign inA2 = inA[15:8];
    assign inA3 = inA[7:0];

    assign inB0 = inB[31:24];
    assign inB4 = inB[23:16];
    assign inB8 = inB[15:8];
    assign inB12 = inB[7:0];

    //Output
    assign result = {out0,out1,out2,out3,out4,out5,out6,out7,out8,out9,out10,out11,out12,out13,out14,out15};

    //First row
    int8mac mac0(inA0,inB0,clk,reset,inA4,inB1,out0);
    int8mac mac1(inA1_buf0,inB1,clk,reset,inA5,inB2,out1);
    int8mac mac2(inA2_buf1,inB2,clk,reset,inA6,inB3,out2);
    int8mac mac3(inA3_buf2,inB3,clk,reset,inA7,,out3);

    //Second row
    int8mac mac4(inA4,inB4_buf0,clk,reset,inA8,inB5,out4);
    int8mac mac5(inA5,inB5,clk,reset,inA9,inB6,out5);
    int8mac mac6(inA6,inB6,clk,reset,inA10,inB7,out6);
    int8mac mac7(inA7,inB7,clk,reset,inA11,,out7);

    //Third row
    int8mac mac8(inA8,inB8_buf1,clk,reset,inA12,inB9,out8);
    int8mac mac9(inA9,inB9,clk,reset,inA13,inB10,out9);
    int8mac mac10(inA10,inB10,clk,reset,inA14,inB11,out10);
    int8mac mac11(inA11,inB11,clk,reset,inA15,,out11);

    //Fourth row
    int8mac mac12(inA12,inB12_buf2,clk,reset,,inB13,out12);
    int8mac mac13(inA13,inB13,clk,reset,,inB14,out13);
    int8mac mac14(inA14,inB14,clk,reset,,inB15,out14);
    int8mac mac15(inA15,inB15,clk,reset,,,out15);

    //Data stagger
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            inA1_buf0 <= 8'd0;

            inA2_buf0 <= 8'd0;
            inA2_buf1 <= 8'd0;

            inA3_buf0 <= 8'd0;
            inA3_buf1 <= 8'd0;
            inA3_buf2 <= 8'd0;

            inB4_buf0 <= 8'd0;

            inB8_buf0 <= 8'd0;
            inB8_buf1 <= 8'd0;

            inB12_buf0 <= 8'd0;
            inB12_buf1 <= 8'd0;
            inB12_buf2 <= 8'd0;
        end else begin
            inA1_buf0 <= inA1;

            inA2_buf0 <= inA2;
            inA2_buf1 <= inA2_buf0;

            inA3_buf0 <= inA3;
            inA3_buf1 <= inA3_buf0;
            inA3_buf2 <= inA3_buf1;

            inB4_buf0 <= inB4;

            inB8_buf0 <= inB8;
            inB8_buf1 <= inB8_buf0;

            inB12_buf0 <= inB12;
            inB12_buf1 <= inB12_buf0;
            inB12_buf2 <= inB12_buf1;
        end
    end

    //Valid output countrol
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            valid_out <= 0;
            count <= 0;
        end else begin
            if (!valid_in) begin
                if (count < 6) begin
                    count <= count + 1;
                end else begin
                    valid_out <= 1;
                end
            end else begin
                count <= 0;
            end
        end
    end
            
endmodule