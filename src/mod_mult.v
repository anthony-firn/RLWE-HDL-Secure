`ifndef MOD_MULT_V
`define MOD_MULT_V

`include "parameters.v"

module ModMult #(parameter Q = 12289, parameter DATA_WIDTH = 14)(
    input  wire [DATA_WIDTH-1:0] a,
    input  wire [DATA_WIDTH-1:0] b,
    output wire [DATA_WIDTH-1:0] result
);
    wire [2*DATA_WIDTH-1:0] mult;
    assign mult = a * b;
    
    // Simple modulo operation (can be optimized)
    wire [2*DATA_WIDTH-1:0] div;
    assign div = mult / Q;
    
    assign result = mult - (div * Q);
endmodule

`endif