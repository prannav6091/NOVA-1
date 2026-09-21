`timescale 1ns/1ps

module sliding_window_handshake #(

    parameter IMAGE_WIDTH  = 8,
    parameter IMAGE_HEIGHT = 8,
    parameter ADDR_WIDTH   = 6

)(

    input  logic                  clk,
    input  logic                  rst,

    // Start processing complete image
    input  logic                  start,


    // =========================================================
    // IMAGE BUFFER INTERFACE
    // =========================================================

    output logic [ADDR_WIDTH-1:0] rd_addr,
    input  logic signed [7:0]     rd_data,


    // =========================================================
    // 3x3 WINDOW
    // =========================================================

    output logic signed [7:0] p0,
    output logic signed [7:0] p1,
    output logic signed [7:0] p2,

    output logic signed [7:0] p3,
    output logic signed [7:0] p4,
    output logic signed [7:0] p5,

    output logic signed [7:0] p6,
    output logic signed [7:0] p7,
    output logic signed [7:0] p8,


    // =========================================================
    // HANDSHAKE
    // =========================================================

    // 1 = p0-p8 contain a valid window
    output logic window_valid,

    // Accelerator asserts this after accepting the window
    input  logic window_ready,


    // Complete image finished
    output logic done

);


    localparam OUTPUT_WIDTH  = IMAGE_WIDTH  - 2;
    localparam OUTPUT_HEIGHT = IMAGE_HEIGHT - 2;


    localparam IDLE  = 3'd0;
    localparam READ  = 3'd1;
    localparam VALID = 3'd2;
    localparam DONE  = 3'd3;


    logic [2:0] state;

    logic [ADDR_WIDTH-1:0] pixel_index;

    logic [ADDR_WIDTH-1:0] window_row;
    logic [ADDR_WIDTH-1:0] window_col;


    // =========================================================
    // IMAGE BUFFER ADDRESS GENERATION
    // =========================================================

    always_comb begin

        case (pixel_index)

            0:
                rd_addr =
                    (window_row * IMAGE_WIDTH)
                    + window_col;

            1:
                rd_addr =
                    (window_row * IMAGE_WIDTH)
                    + window_col + 1;

            2:
                rd_addr =
                    (window_row * IMAGE_WIDTH)
                    + window_col + 2;


            3:
                rd_addr =
                    ((window_row + 1) * IMAGE_WIDTH)
                    + window_col;

            4:
                rd_addr =
                    ((window_row + 1) * IMAGE_WIDTH)
                    + window_col + 1;

            5:
                rd_addr =
                    ((window_row + 1) * IMAGE_WIDTH)
                    + window_col + 2;


            6:
                rd_addr =
                    ((window_row + 2) * IMAGE_WIDTH)
                    + window_col;

            7:
                rd_addr =
                    ((window_row + 2) * IMAGE_WIDTH)
                    + window_col + 1;

            8:
                rd_addr =
                    ((window_row + 2) * IMAGE_WIDTH)
                    + window_col + 2;


            default:
                rd_addr = '0;

        endcase

    end


    // =========================================================
    // CONTROLLER
    // =========================================================

    always_ff @(posedge clk) begin

        if (rst) begin

            state       <= IDLE;

            pixel_index <= 0;

            window_row  <= 0;
            window_col  <= 0;


            p0 <= 0;
            p1 <= 0;
            p2 <= 0;

            p3 <= 0;
            p4 <= 0;
            p5 <= 0;

            p6 <= 0;
            p7 <= 0;
            p8 <= 0;


            window_valid <= 1'b0;

            done <= 1'b0;

        end

        else begin

            done <= 1'b0;


            case (state)


                // =================================================
                // IDLE
                // =================================================

                IDLE: begin

                    window_valid <= 1'b0;

                    if (start) begin

                        window_row  <= 0;
                        window_col  <= 0;

                        pixel_index <= 0;

                        state <= READ;

                    end

                end


                // =================================================
                // READ 9 PIXELS
                // =================================================

                READ: begin

                    window_valid <= 1'b0;


                    case (pixel_index)

                        0: p0 <= rd_data;
                        1: p1 <= rd_data;
                        2: p2 <= rd_data;

                        3: p3 <= rd_data;
                        4: p4 <= rd_data;
                        5: p5 <= rd_data;

                        6: p6 <= rd_data;
                        7: p7 <= rd_data;
                        8: p8 <= rd_data;

                        default: begin
                        end

                    endcase


                    if (pixel_index == 8) begin

                        pixel_index <= 0;

                        state <= VALID;

                    end

                    else begin

                        pixel_index <= pixel_index + 1;

                    end

                end


                // =================================================
                // WINDOW READY
                //
                // IMPORTANT:
                //
                // Remain here until convolution controller
                // accepts this window.
                // =================================================

                VALID: begin

                    window_valid <= 1'b1;


                    if (window_ready) begin

                        window_valid <= 1'b0;


                        // -----------------------------------------
                        // NEXT COLUMN
                        // -----------------------------------------

                        if (window_col < OUTPUT_WIDTH - 1) begin

                            window_col <= window_col + 1;

                            state <= READ;

                        end


                        // -----------------------------------------
                        // NEXT ROW
                        // -----------------------------------------

                        else if (
                            window_row < OUTPUT_HEIGHT - 1
                        ) begin

                            window_col <= 0;

                            window_row <= window_row + 1;

                            state <= READ;

                        end


                        // -----------------------------------------
                        // LAST WINDOW
                        // -----------------------------------------

                        else begin

                            state <= DONE;

                        end

                    end

                end


                // =================================================
                // DONE
                // =================================================

                DONE: begin

                    window_valid <= 1'b0;

                    done <= 1'b1;

                    state <= IDLE;

                end


                default: begin

                    state <= IDLE;

                    window_valid <= 1'b0;

                end

            endcase

        end

    end

endmodule
