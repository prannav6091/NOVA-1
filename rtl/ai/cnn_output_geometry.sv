module cnn_output_geometry (

    input logic [15:0] input_width,
    input logic [15:0] input_height,

    // Supported:
    // 1 = stride 1
    // 2 = stride 2
    input logic [1:0] stride,

    output logic [15:0] output_width,
    output logic [15:0] output_height,

    output logic valid
);


    always_comb begin

        output_width  = 16'd0;
        output_height = 16'd0;

        valid = 1'b0;


        // =============================================
        // Valid 3x3 convolution requires at least 3x3
        // =============================================

        if (
            (input_width  >= 16'd3) &&
            (input_height >= 16'd3)
        ) begin

            case (stride)

                // =====================================
                // STRIDE 1
                //
                // floor((W - 3)/1) + 1
                // = W - 2
                // =====================================

                2'd1: begin

                    output_width =
                        input_width - 16'd2;

                    output_height =
                        input_height - 16'd2;

                    valid =
                        1'b1;

                end


                // =====================================
                // STRIDE 2
                //
                // floor((W - 3)/2) + 1
                // =====================================

                2'd2: begin

                    output_width =
                        ((input_width - 16'd3) >> 1)
                        + 16'd1;

                    output_height =
                        ((input_height - 16'd3) >> 1)
                        + 16'd1;

                    valid =
                        1'b1;

                end


                // =====================================
                // Unsupported stride
                // =====================================

                default: begin

                    output_width =
                        16'd0;

                    output_height =
                        16'd0;

                    valid =
                        1'b0;

                end

            endcase

        end

    end


endmodule
