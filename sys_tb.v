`timescale 1ns / 1ps
`include "systolic_array.v"
`include "int8mac.v"
`include "normalizer.v"
module systolic_array_tb;

    // Inputs
    reg clk;
    reg reset;
    reg [31:0] matrixA;
    reg [31:0] matrixB;
    reg valid_in;

    // Outputs
    wire [127:0] result;
    wire valid_out;

    // Instantiate the Unit Under Test (UUT)
    systolic_array uut (
        .clk(clk),
        .reset(reset),
        .matrixA(matrixA),
        .matrixB(matrixB),
        .valid_in(valid_in),
        .result(result),
        .valid_out(valid_out)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 10 ns clock period

    // Task to apply input matrices
    task apply_matrices;
        input [31:0] matA;
        input [31:0] matB;
        begin
            matrixA = matA;
            matrixB = matB;
            valid_in = 1;
            @(posedge clk);
            valid_in = 0;
        end
    endtask

    // Testbench logic
    initial begin
        // Initialize inputs
        $dumpfile("systolic_array_tb.vcd");
        $dumpvars(0, systolic_array_tb);
        reset = 1;
        matrixA = 0;
        matrixB = 0;
        valid_in = 0;

        // Apply reset
        #10 reset = 0;
        #10 reset = 1;

        // Apply test inputs (4x4 matrices of all ones)
        apply_matrices(32'h02020202, 32'h02020202); // First row
        apply_matrices(32'h02020202, 32'h02020202); // Second row
        apply_matrices(32'h02020202, 32'h02020202); // Third row
        apply_matrices(32'h02020202, 32'h02020202); // Fourth row
        matrixA = 32'd0;
        matrixB = 32'd0;
        // Wait for the output to become valid
        wait (valid_out);
        #100;
        // Display the result matrix
        $display("Result Matrix:");
        $display("%d %d %d %d", result[127:120], result[119:112], result[111:104], result[103:96]);
        $display("%d %d %d %d", result[95:88], result[87:80], result[79:72], result[71:64]);
        $display("%d %d %d %d", result[63:56], result[55:48], result[47:40], result[39:32]);
        $display("%d %d %d %d", result[31:24], result[23:16], result[15:8], result[7:0]);

        // Finish simulation

        $finish;
    end

endmodule
