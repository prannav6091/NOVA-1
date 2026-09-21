module channel_sum_buffer #(
    parameter integer MAX_OUTPUTS = 8294400
)(
    input logic clk,
    input logic reset,

    // Number of input channels in this layer
    input logic [15:0] input_channels,

    // Which input channel is currently being processed
    input logic [15:0] channel_index,

    // Spatial output position:
    // 0, 1, 2, ... output_width*output_height-1
    input logic [31:0] output_index,

    // 3x3 convolution result for this channel
    input logic signed [31:0] channel_result,
    input logic               channel_valid,

    // Final result after all channels have accumulated
    output logic signed [31:0] accumulated_result,
    output logic               accumulated_valid
);

    // =========================================================
    // PARTIAL-SUM STORAGE
    //
    // One INT32 partial sum per output spatial position.
    //
    // In the final ASIC this should map to SRAM / scratchpad,
    // not millions of flip-flops.
    // =========================================================

    logic signed [31:0] partial_sum [0:MAX_OUTPUTS-1];

    logic signed [31:0] old_sum;
    logic signed [31:0] new_sum;


    always_comb begin

        old_sum =
            partial_sum[output_index];

        new_sum =
            old_sum + channel_result;

    end


    always_ff @(posedge clk) begin

        if (reset) begin

            accumulated_result <= 32'sd0;
            accumulated_valid  <= 1'b0;

        end

        else begin

            accumulated_valid <= 1'b0;


            if (channel_valid) begin

                // =================================================
                // FIRST INPUT CHANNEL
                //
                // Do not depend on stale partial-sum memory.
                // Start accumulation from this channel_result.
                // =================================================

                if (channel_index == 16'd0) begin

                    // If there is only one input channel,
                    // this is already the final answer.

                    if (input_channels == 16'd1) begin

                        accumulated_result <=
                            channel_result;

                        accumulated_valid <=
                            1'b1;

                        partial_sum[output_index] <=
                            32'sd0;

                    end

                    else begin

                        partial_sum[output_index] <=
                            channel_result;

                    end

                end


                // =================================================
                // LAST INPUT CHANNEL
                // =================================================

                else if (
                    channel_index
                    ==
                    (input_channels - 16'd1)
                ) begin

                    accumulated_result <=
                        new_sum;

                    accumulated_valid <=
                        1'b1;


                    // Clear entry after final consumption.
                    // Makes it ready for another layer/job.

                    partial_sum[output_index] <=
                        32'sd0;

                end


                // =================================================
                // INTERMEDIATE CHANNEL
                // =================================================

                else begin

                    partial_sum[output_index] <=
                        new_sum;

                end

            end

        end

    end

endmodule
