module pulse_gen (
    input   logic       clk,
    input   logic       reset_n,
    input   logic       trigger,
    output  logic       pulse_out
);

    logic prev_trigger;

    always_ff @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            pulse_out       <= 1'b0;
            prev_trigger    <= 1'b0;
        end else begin
            if (trigger) begin
                if (!prev_trigger) begin
                    pulse_out       <= 1'b1;
                    prev_trigger    <= 1'b1;
                end else begin
                    pulse_out       <= 1'b0;
                end
            end else begin
                pulse_out       <= 1'b0;
                prev_trigger    <= 1'b0;
            end
        end
    end

endmodule
