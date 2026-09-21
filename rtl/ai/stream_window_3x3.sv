module stream_window_3x3 #(
    parameter integer MAX_WIDTH = 4096
)(
    input  logic clk,
    input  logic reset,

    // Pulse aligned with the first pixel of a new channel plane
    input  logic channel_start,

    input  logic [15:0] image_width,
    input  logic [15:0] image_height,

    input  logic signed [7:0] pixel_in,
    input  logic              pixel_valid,

    output logic signed [7:0] w00,
    output logic signed [7:0] w01,
    output logic signed [7:0] w02,

    output logic signed [7:0] w10,
    output logic signed [7:0] w11,
    output logic signed [7:0] w12,

    output logic signed [7:0] w20,
    output logic signed [7:0] w21,
    output logic signed [7:0] w22,

    output logic window_valid
);

    // =========================================================
    // TWO LINE BUFFERS
    // =========================================================

    logic signed [7:0] line1 [0:MAX_WIDTH-1];
    logic signed [7:0] line2 [0:MAX_WIDTH-1];


    // =========================================================
    // CURRENT POSITION
    // =========================================================

    logic [15:0] row;
    logic [15:0] col;


    // =========================================================
    // HORIZONTAL HISTORY
    // =========================================================

    logic signed [7:0] top_left;
    logic signed [7:0] top_mid;

    logic signed [7:0] mid_left;
    logic signed [7:0] mid_mid;

    logic signed [7:0] bot_left;
    logic signed [7:0] bot_mid;


    logic signed [7:0] prev_row_pixel;
    logic signed [7:0] prev2_row_pixel;


    // =========================================================
    // MAIN WINDOW GENERATOR
    // =========================================================

    always_ff @(posedge clk) begin

        if (reset) begin

            row <= 16'd0;
            col <= 16'd0;

            top_left <= 8'sd0;
            top_mid  <= 8'sd0;

            mid_left <= 8'sd0;
            mid_mid  <= 8'sd0;

            bot_left <= 8'sd0;
            bot_mid  <= 8'sd0;

            w00 <= 8'sd0;
            w01 <= 8'sd0;
            w02 <= 8'sd0;

            w10 <= 8'sd0;
            w11 <= 8'sd0;
            w12 <= 8'sd0;

            w20 <= 8'sd0;
            w21 <= 8'sd0;
            w22 <= 8'sd0;

            window_valid <= 1'b0;

        end

        else begin

            // Default: window-valid is a pulse
            window_valid <= 1'b0;


            // =================================================
            // NEW CHANNEL + FIRST PIXEL
            //
            // IMPORTANT:
            // channel_start arrives together with the first
            // valid pixel, so we must NOT throw that pixel away.
            // =================================================

            if (channel_start && pixel_valid) begin

                row <= 16'd0;

                // First pixel belongs to column 0.
                // Next incoming pixel will be column 1.
                if (image_width > 16'd1)
                    col <= 16'd1;
                else
                    col <= 16'd0;


                // Clear horizontal history from previous channel.
                top_left <= 8'sd0;
                top_mid  <= 8'sd0;

                mid_left <= 8'sd0;
                mid_mid  <= 8'sd0;

                bot_left <= 8'sd0;
                bot_mid  <= pixel_in;


                // Start new channel's line-buffer history.
                //
                // No need to clear all 4096 entries:
                // by the time row 2 becomes valid, rows 0 and 1
                // of the new channel have overwritten the stale
                // entries from the previous channel.

                line2[0] <= line1[0];
                line1[0] <= pixel_in;


                // No valid window on first pixel.
                window_valid <= 1'b0;

            end


            // =================================================
            // NORMAL PIXEL PROCESSING
            // =================================================

            else if (pixel_valid) begin

                // Existing contents represent previous rows.

                prev_row_pixel  = line1[col];
                prev2_row_pixel = line2[col];


                // Shift vertical line-buffer history.

                line2[col] <= prev_row_pixel;
                line1[col] <= pixel_in;


                // Shift horizontal history.

                top_left <= top_mid;
                top_mid  <= prev2_row_pixel;

                mid_left <= mid_mid;
                mid_mid  <= prev_row_pixel;

                bot_left <= bot_mid;
                bot_mid  <= pixel_in;


                // Construct current 3x3 window.

                w00 <= top_left;
                w01 <= top_mid;
                w02 <= prev2_row_pixel;

                w10 <= mid_left;
                w11 <= mid_mid;
                w12 <= prev_row_pixel;

                w20 <= bot_left;
                w21 <= bot_mid;
                w22 <= pixel_in;


                // Valid after at least 3 rows and 3 columns.

                if (
                    (row >= 16'd2) &&
                    (col >= 16'd2)
                )
                    window_valid <= 1'b1;


                // =================================================
                // ADVANCE POSITION
                // =================================================

                if (col == image_width - 1'b1) begin

                    col <= 16'd0;


                    // New row:
                    // horizontal history must restart.

                    top_left <= 8'sd0;
                    top_mid  <= 8'sd0;

                    mid_left <= 8'sd0;
                    mid_mid  <= 8'sd0;

                    bot_left <= 8'sd0;
                    bot_mid  <= 8'sd0;


                    if (row == image_height - 1'b1)
                        row <= 16'd0;
                    else
                        row <= row + 1'b1;

                end

                else begin

                    col <= col + 1'b1;

                end

            end

        end

    end

endmodule
