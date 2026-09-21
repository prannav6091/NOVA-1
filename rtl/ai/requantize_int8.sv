module requantize_int8 (

    input  logic signed [31:0] data_in,

    // Scaling:
    // output ? data_in / (2^shift_amount)
    input  logic [4:0] shift_amount,

    output logic signed [7:0] data_out

);

    logic signed [31:0] scaled_value;


    always_comb begin

        // =====================================================
        // FIXED-POINT SCALING
        // =====================================================

        // Arithmetic right shift preserves the sign.
        //
        // Example:
        // data_in = 400
        // shift_amount = 2
        //
        // 400 / 4 = 100

        scaled_value = data_in >>> shift_amount;


        // =====================================================
        // INT8 SATURATION
        // =====================================================

        if (scaled_value > 32'sd127) begin

            data_out = 8'sd127;

        end

        else if (scaled_value < -32'sd128) begin

            data_out = -8'sd128;

        end

        else begin

            data_out = scaled_value[7:0];

        end

    end

endmodule