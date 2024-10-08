`ifndef PARAMETERS_V
`define PARAMETERS_V

`timescale 1ns / 1ps

module parameters;
    // Parameters for RLWE
    parameter N = 256;           // Degree of the ring (must be a power of 2)
    parameter Q = 12289;         // Modulus (a prime such that Q ≡ 1 mod 2N)
    parameter LOG_N = 8;         // log2(N)
    parameter DATA_WIDTH = 14;   // Bit-width to represent numbers up to Q
endmodule

`endif