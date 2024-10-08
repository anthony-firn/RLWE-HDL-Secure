`ifndef MOD_ADD_V
`define MOD_ADD_V

`include "parameters.v"

module ModAdd #(parameter Q = 12289, parameter DATA_WIDTH = 14)(
    input  wire [DATA_WIDTH-1:0] a,
    input  wire [DATA_WIDTH-1:0] b,
    output wire [DATA_WIDTH-1:0] result
);
    wire [DATA_WIDTH:0] sum;
    assign sum = a + b;
    assign result = (sum >= Q) ? (sum - Q) : sum;
endmodule

`endif