`timescale 1us/1ns

module tb_LiftController();

parameter N = 3;
parameter DELAY_CYCLES = 50;

reg clk, rst_n;
reg [N-1:0] i_l, i_u, i_d, sf;
reg [N-2:0] si;

wire STOP, UP, D, v;
wire [1:0] c;

LiftController #(
    .N(N),
    .DELAY_CYCLES(DELAY_CYCLES)
) dut (
    .clk(clk), .rst_n(rst_n),
    .i_l(i_l), .i_u(i_u), .i_d(i_d),
    .sf(sf), .si(si),
    .STOP(STOP), .UP(UP), .D(D), .v(v), .c(c)
);

initial begin
    clk = 0;
    forever #0.5 clk = ~clk;
end

initial begin
    rst_n = 0;
    #50 rst_n = 1;
end

// Simulates a button press
task press;
    input integer floor;
    input integer button_type; // 0: inside, 1: up, 2: down
    begin
        case (button_type)
            0: i_l[floor] = 1;
            1: i_u[floor] = 1;
            2: i_d[floor] = 1;
        endcase
        #2; i_l = 0; i_u = 0; i_d = 0; #2;
    end
endtask

// Lift physics model
integer current_pos = 0;
integer target_pos = 0;
reg moving = 0;
wire has_requests = |dut.Ru | |dut.Rd;

always @(posedge clk) begin
    // Track current floor
    if (|sf)
        for (integer i = 0; i < N; i = i + 1)
            if (sf[i]) current_pos = i;
    
    // Determine target floor when idle but requests exist
    if (!moving && has_requests && !D && v) begin
        target_pos = current_pos;
        if (UP) begin
            for (integer i = N-1; i > current_pos; i = i - 1)
                if (dut.Ru[i] || dut.Rd[i]) target_pos = i;
            if (target_pos == current_pos)
                for (integer i = N-1; i >= 0; i = i - 1)
                    if (dut.Ru[i] || dut.Rd[i]) target_pos = i;
        end else begin
            for (integer i = 0; i < current_pos; i = i + 1)
                if (dut.Ru[i] || dut.Rd[i]) target_pos = i;
            if (target_pos == current_pos)
                for (integer i = N-1; i >= 0; i = i - 1)
                    if (dut.Ru[i] || dut.Rd[i]) target_pos = i;
        end
        if (target_pos != current_pos) moving = 1;
    end

    // Stop if door opens or no requests remain
    if (D || !has_requests) moving = 0;
end

// Simulate motion: floor transitions + midway sensors
always @(posedge clk) begin
    if (moving) begin
        sf = 0;
        if (target_pos > current_pos) begin
            si = 1 << current_pos; #20; current_pos++;
        end else if (target_pos < current_pos) begin
            si = 1 << (current_pos - 1); #20; current_pos--;
        end
        si = 0;
        sf = 1 << current_pos; #10;
    end else begin
        sf = 1 << current_pos; si = 0;
    end
end

// Test sequence
initial begin
    $monitor("Time=%0t | c=%0d | UP=%b | STOP=%b | D=%b | Ru=%b | Rd=%b | moving=%b | target=%0d", 
             $time, c, UP, STOP, D, dut.Ru, dut.Rd, moving, target_pos);

    wait(rst_n == 1);
    #20; sf = 1 << 0; si = 0; #10;
    
    press(2, 2);  // Down request at floor 2
    #200;
    press(1, 0);  // Lift request at floor 1
    #200;
    press(0, 1); // Up request at floor 0
    #200;
    
    $finish;
end

initial begin
    #10000 $finish;
end

endmodule
