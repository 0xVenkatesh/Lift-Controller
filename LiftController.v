`timescale 1us/1ns

module LiftController #(
    parameter integer N = 3,
    parameter integer DELAY_CYCLES = 5_000_000
)(
    input  wire              clk,
    input  wire              rst_n,
    input  wire [N-1:0]      i_l,
    input  wire [N-1:0]      i_u,
    input  wire [N-1:0]      i_d,
    input  wire [N-1:0]      sf,
    input  wire [N-2:0]      si,

    output reg               D,
    output reg               UP,
    output wire              STOP,
    output wire              v,
    output wire [$clog2(N)-1:0] c      
);


    reg [$clog2(N)-1:0] c_reg;
    assign c = c_reg;  
    integer j;
    
    assign v = ~|si; // valid bit
    
    // one-hot input-to-binary encoder    
    always @(*) begin
        if (!rst_n) 
            c_reg = 0;
        else if (v) begin
            c_reg = 0;
            for (j = 0; j < N; j = j + 1) begin
                if (sf[j])
                    c_reg = j;
            end
        end
    end

    // Requests stored in latches
    reg [N-1:0] Ru, Rd;
    reg [N-1:0] rst_latch;
    reg [N-1:0] setu, setd;

    // No Request Exists
    wire NRE = ~|({Ru, Rd});
    
    always @(*) begin
        setu[0] = i_u[0] | (~v & NRE);
        setd[0] = 0;
        for (j = 1; j < N; j = j + 1) begin
            setu[j] = i_u[j] | (i_l[j] & (j > c_reg));
            setd[j] = i_d[j] | (i_l[j] & (j < c_reg));
        end
    end

    always @(*) begin
        if (!rst_n) begin
            Ru = 0; 
            Rd = 0;
        end else begin
            for (j = 0; j < N; j = j + 1) begin
                if (rst_latch[j]) begin
                    Ru[j] = 0;
                    Rd[j] = 0;
                end else begin
                    if (setu[j]) Ru[j] = 1;
                    if (setd[j]) Rd[j] = 1;
                end
            end
        end
    end

    // Bit-Split OR logic
    reg BSO1, BSO2, BSO3, BSO4;
    always @(*) begin
        BSO1 = 0; BSO2 = 0; BSO3 = 0; BSO4 = 0;
        for (j = 0; j < N; j = j + 1) begin
            if (j > c_reg) begin
                BSO1 = BSO1 | Ru[j];  // any up-request above
                BSO3 = BSO3 | Rd[j];  // any down-request above
            end
            if (j < c_reg) begin
                BSO2 = BSO2 | Ru[j];  // any up-request below
                BSO4 = BSO4 | Rd[j];  // any down-request below
            end
        end
    end
   
    
    // Door logic - only hardware availing the clk signal
    reg [22:0] counter;
    reg STOP_prev, D_prev; 
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            D <= 0;
            STOP_prev <= 0;
            D_prev <= 0;      
        end else begin
            STOP_prev <= STOP;
            D_prev <= D;
            
            if ((STOP && !STOP_prev) || (STOP && (Ru[c_reg] || Rd[c_reg]) && counter == 0 && D == 0)) begin
                D <= 1;
                counter <= DELAY_CYCLES;
            end else if (counter > 0) begin
                counter <= counter - 1;
                if (counter == 1)
                    D <= 0;
            end
        end
    end
    
    // Reset latch and set Q1 high if needed on door closing
    reg Q1;
    always @(*) begin
        if (!rst_n) begin
            rst_latch = 0;
            Q1 = 0;
        end else begin
            if (D_prev && !D) begin
                rst_latch[c_reg] = 1;
                if (UP) Q1 = BSO1 | BSO3;
                else Q1 = (~(BSO4 | BSO2)) & BSO1;
            end else begin
                rst_latch[c_reg] = 0;
            end
        end
    end
    
    // STOP logic (need to add rst_n)
    assign STOP = ((UP ? (Ru[c_reg] | (Rd[c_reg] & ~(BSO1 | BSO2))) : (Rd[c_reg] | (Ru[c_reg] & ~(BSO3 | BSO4)))) | NRE) & v;
    
    // UP logic
    reg Q2;
    
    always @(negedge NRE) begin
        if (!rst_n) begin
            Q2 <= 0;
        end 
        
        else 
            Q2 <= BSO1 | BSO3;
    end
        
    always @(*) begin
        UP = Q1 | Q2;
    end

endmodule
