`ifndef NTT_V
`define NTT_V

`include "parameters.v"
`include "constants/twiddle_factors.vh"
`include "mod_add.v"
`include "mod_mult.v"

module NTT #(parameter N = 256, parameter Q = 12289, parameter LOG_N = 8, parameter DATA_WIDTH = 14)(
    input  wire                   clk,
    input  wire                   reset,
    input  wire                   start,
    input  wire [DATA_WIDTH-1:0]  data_in [0:N-1],
    output reg  [DATA_WIDTH-1:0]  data_out [0:N-1],
    output reg                    done
);
    reg [DATA_WIDTH-1:0] data_reg [0:N-1];
    reg [DATA_WIDTH-1:0] twiddle_factors [0:N/2-1];
    integer i, j, m, k, stage;
    reg [LOG_N:0] current_stage;
    reg [LOG_N:0] total_stages;
    reg processing;

    // Initialize twiddle factors from constants
    initial begin
        for (i = 0; i < N/2; i = i + 1) begin
            case (i)
                0: twiddle_factors[i] = `TWIDDLE_0;
                1: twiddle_factors[i] = `TWIDDLE_1;
                // Continue for all twiddle factors
                // ...
                default: twiddle_factors[i] = 1;
            endcase
        end
    end

    // NTT algorithm implementation (simplified for illustration)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            done <= 0;
            processing <= 0;
            current_stage <= 0;
        end else if (start && !processing) begin
            // Load input data
            for (i = 0; i < N; i = i + 1) begin
                data_reg[i] <= data_in[i];
            end
            current_stage <= 1;
            processing <= 1;
            done <= 0;
        end else if (processing) begin
            if (current_stage <= LOG_N) begin
                m = 1 << current_stage;
                for (k = 0; k < m/2; k = k + 1) begin
                    for (j = k; j < N; j = j + m) begin
                        // Butterfly computations
                        wire [DATA_WIDTH-1:0] t, u;
                        wire [DATA_WIDTH-1:0] twiddle;
                        assign twiddle = twiddle_factors[(N/m)*k];
                        
                        // Compute t = data_reg[j + m/2] * twiddle
                        ModMult #(.Q(Q), .DATA_WIDTH(DATA_WIDTH)) mult_inst (
                            .a(data_reg[j + m/2]),
                            .b(twiddle),
                            .result(t)
                        );
                        
                        // Compute u = data_reg[j]
                        assign u = data_reg[j];
                        
                        // data_reg[j] = (u + t) mod Q
                        wire [DATA_WIDTH-1:0] add_result;
                        ModAdd #(.Q(Q), .DATA_WIDTH(DATA_WIDTH)) add_inst (
                            .a(u),
                            .b(t),
                            .result(add_result)
                        );
                        data_reg[j] <= add_result;
                        
                        // data_reg[j + m/2] = (u - t) mod Q
                        wire [DATA_WIDTH-1:0] sub_result;
                        ModSub #(.Q(Q), .DATA_WIDTH(DATA_WIDTH)) sub_inst (
                            .a(u),
                            .b(t),
                            .result(sub_result)
                        );
                        data_reg[j + m/2] <= sub_result;
                    end
                end
                current_stage <= current_stage + 1;
            end else begin
                // NTT complete
                for (i = 0; i < N; i = i + 1) begin
                    data_out[i] <= data_reg[i];
                end
                done <= 1;
                processing <= 0;
            end
        end
    end
endmodule

`endif