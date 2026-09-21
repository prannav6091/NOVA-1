module channel_accumulator (

    input  logic clk,
    input  logic reset,

    // Number of input channels participating
    // in the current output accumulation.
    //
    // Examples:
    // RGB first layer = 3
    // later CNN layer = 16, 32, 64, ...
    input  logic [15:0] input_channels,

    // One 3x3 convolution result from one channel
    input  logic signed [31:0] channel_result,
    input  logic               channel_valid,

    // Final accumulated value across all channels
    output logic signed [31:0] accumulated_result,
    output logic               accumulated_valid
);

    logic signed [31:0] accumulator;

    logic [15:0] channel_count;

    logic signed [31:0] next_sum;


    always_comb begin

        next_sum =
            accumulator + channel_result;

    end


    always_ff @(posedge clk) begin

        if (reset) begin

            accumulator         <= 32'sd0;
            channel_count       <= 16'd0;

            accumulated_result  <= 32'sd0;
            accumulated_valid   <= 1'b0;

        end

        else begin

            // Default: output-valid is a one-cycle pulse
            accumulated_valid <= 1'b0;


            if (channel_valid) begin

                // ---------------------------------------------
                // Guard against invalid configuration
                // ---------------------------------------------

                if (input_channels == 16'd0) begin

                    accumulator   <= 32'sd0;
                    channel_count <= 16'd0;

                end


                // ---------------------------------------------
                // Last channel
                //
                // channel_count starts at 0.
                //
                // For input_channels = 3:
                //
                // channel 0
                // channel 1
                // channel 2 -> final output
                // ---------------------------------------------

                else if (
                    channel_count
                    ==
                    (input_channels - 16'd1)
                ) begin

                    accumulated_result <=
                        next_sum;

                    accumulated_valid <=
                        1'b1;


                    // Prepare for next spatial output/filter

                    accumulator <=
                        32'sd0;

                    channel_count <=
                        16'd0;

                end


                // ---------------------------------------------
                // More channels remain
                // ---------------------------------------------

                else begin

                    accumulator <=
                        next_sum;

                    channel_count <=
                        channel_count + 1'b1;

                end

            end

        end

    end

endmodule
