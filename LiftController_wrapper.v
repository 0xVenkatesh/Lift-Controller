`timescale 1us/1ns

module LiftController_wrapper #(
    parameter integer N = 3,
    parameter integer DELAY_CYCLES = 5_000_000
)(
    input  wire              clk,
    input  wire              rst_n,
    input  wire [2:0]        i_l,
    input  wire [1:0]        i_u,
    input  wire [1:0]        i_d,
    input  wire [2:0]        sf,
    input  wire [1:0]        si,
    output wire [2:0]        led,
    
    // Expose internal signals for synthesis
    output wire              STOP,
    output wire              UP,
    output wire              D,
    output wire              v
);

    wire [1:0] c;
    
    // Use intermediate wires instead of direct concatenation
    wire [2:0] i_u_internal;
    wire [2:0] i_d_internal;
    
    assign i_u_internal = {1'b0, i_u};
    assign i_d_internal = {i_d, 1'b0};
    
    LiftController #(
        .N(N), 
        .DELAY_CYCLES(DELAY_CYCLES)
    ) dutlc (
        .clk(clk), 
        .rst_n(rst_n), 
        .i_u(i_u_internal),
        .i_d(i_d_internal),
        .i_l(i_l),
        .sf(sf),
        .si(si),
        .c(c),
        .STOP(STOP),
        .UP(UP),
        .D(D),
        .v(v)
    );
    
    // LED decoder
    assign led[0] = (c == 2'b00) ? 1'b1 : 1'b0;  // Floor 0
    assign led[1] = (c == 2'b01) ? 1'b1 : 1'b0;  // Floor 1  
    assign led[2]= (c == 2'b10) ? 1'b1 : 1'b0;  // Floor 2
    
endmodule
