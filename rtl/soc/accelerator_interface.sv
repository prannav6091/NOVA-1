`timescale 1ns/1ps

module accelerator_interface (

    input  logic        clk,
    input  logic        reset,

    // =========================================================
    // SIMPLE MEMORY-MAPPED BUS
    // =========================================================

    input  logic        bus_write,
    input  logic        bus_read,

    input  logic [31:0] bus_addr,
    input  logic [31:0] bus_wdata,

    output logic [31:0] bus_rdata,


    // =========================================================
    // CONVOLUTION ENGINE CONNECTION
    // =========================================================

    output logic        accel_start,

    output logic signed [7:0] pixel0,
    output logic signed [7:0] pixel1,
    output logic signed [7:0] pixel2,
    output logic signed [7:0] pixel3,
    output logic signed [7:0] pixel4,
    output logic signed [7:0] pixel5,
    output logic signed [7:0] pixel6,
    output logic signed [7:0] pixel7,
    output logic signed [7:0] pixel8,

    output logic signed [7:0] weight0,
    output logic signed [7:0] weight1,
    output logic signed [7:0] weight2,
    output logic signed [7:0] weight3,
    output logic signed [7:0] weight4,
    output logic signed [7:0] weight5,
    output logic signed [7:0] weight6,
    output logic signed [7:0] weight7,
    output logic signed [7:0] weight8,

    input  logic        accel_busy,
    input  logic        accel_done,

    input  logic signed [31:0] accel_result

);


    // =========================================================
    // REGISTER ADDRESSES
    // =========================================================

    localparam logic [7:0] ADDR_CONTROL   = 8'h00;
    localparam logic [7:0] ADDR_STATUS    = 8'h04;

    localparam logic [7:0] ADDR_PIXEL03   = 8'h08;
    localparam logic [7:0] ADDR_PIXEL47   = 8'h0C;
    localparam logic [7:0] ADDR_PIXEL8    = 8'h10;

    localparam logic [7:0] ADDR_WEIGHT03  = 8'h14;
    localparam logic [7:0] ADDR_WEIGHT47  = 8'h18;
    localparam logic [7:0] ADDR_WEIGHT8   = 8'h1C;

    localparam logic [7:0] ADDR_RESULT    = 8'h20;


    // =========================================================
    // WRITE LOGIC
    // =========================================================

    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin

            accel_start <= 1'b0;

            pixel0 <= 8'sd0;
            pixel1 <= 8'sd0;
            pixel2 <= 8'sd0;
            pixel3 <= 8'sd0;
            pixel4 <= 8'sd0;
            pixel5 <= 8'sd0;
            pixel6 <= 8'sd0;
            pixel7 <= 8'sd0;
            pixel8 <= 8'sd0;

            weight0 <= 8'sd0;
            weight1 <= 8'sd0;
            weight2 <= 8'sd0;
            weight3 <= 8'sd0;
            weight4 <= 8'sd0;
            weight5 <= 8'sd0;
            weight6 <= 8'sd0;
            weight7 <= 8'sd0;
            weight8 <= 8'sd0;

        end

        else begin

            // start is a one-clock pulse
            accel_start <= 1'b0;

            if (bus_write) begin

                case (bus_addr[7:0])

                    // -----------------------------------------
                    // CONTROL
                    // bit 0 = start
                    // -----------------------------------------

                    ADDR_CONTROL: begin

                        if (bus_wdata[0])
                            accel_start <= 1'b1;

                    end


                    // -----------------------------------------
                    // PIXELS 0..3
                    // -----------------------------------------

                    ADDR_PIXEL03: begin

                        pixel0 <= bus_wdata[7:0];
                        pixel1 <= bus_wdata[15:8];
                        pixel2 <= bus_wdata[23:16];
                        pixel3 <= bus_wdata[31:24];

                    end


                    // -----------------------------------------
                    // PIXELS 4..7
                    // -----------------------------------------

                    ADDR_PIXEL47: begin

                        pixel4 <= bus_wdata[7:0];
                        pixel5 <= bus_wdata[15:8];
                        pixel6 <= bus_wdata[23:16];
                        pixel7 <= bus_wdata[31:24];

                    end


                    // -----------------------------------------
                    // PIXEL 8
                    // -----------------------------------------

                    ADDR_PIXEL8: begin

                        pixel8 <= bus_wdata[7:0];

                    end


                    // -----------------------------------------
                    // WEIGHTS 0..3
                    // -----------------------------------------

                    ADDR_WEIGHT03: begin

                        weight0 <= bus_wdata[7:0];
                        weight1 <= bus_wdata[15:8];
                        weight2 <= bus_wdata[23:16];
                        weight3 <= bus_wdata[31:24];

                    end


                    // -----------------------------------------
                    // WEIGHTS 4..7
                    // -----------------------------------------

                    ADDR_WEIGHT47: begin

                        weight4 <= bus_wdata[7:0];
                        weight5 <= bus_wdata[15:8];
                        weight6 <= bus_wdata[23:16];
                        weight7 <= bus_wdata[31:24];

                    end


                    // -----------------------------------------
                    // WEIGHT 8
                    // -----------------------------------------

                    ADDR_WEIGHT8: begin

                        weight8 <= bus_wdata[7:0];

                    end


                    default: begin
                    end

                endcase

            end

        end

    end


    // =========================================================
    // READ LOGIC
    // =========================================================

    always_comb begin

        bus_rdata = 32'b0;

        if (bus_read) begin

            case (bus_addr[7:0])

                ADDR_CONTROL: begin

                    bus_rdata = 32'b0;

                end


                ADDR_STATUS: begin

                    bus_rdata = {
                        30'b0,
                        accel_done,
                        accel_busy
                    };

                end


                ADDR_PIXEL03: begin

                    bus_rdata = {
                        pixel3,
                        pixel2,
                        pixel1,
                        pixel0
                    };

                end


                ADDR_PIXEL47: begin

                    bus_rdata = {
                        pixel7,
                        pixel6,
                        pixel5,
                        pixel4
                    };

                end


                ADDR_PIXEL8: begin

                    bus_rdata = {
                        24'b0,
                        pixel8
                    };

                end


                ADDR_WEIGHT03: begin

                    bus_rdata = {
                        weight3,
                        weight2,
                        weight1,
                        weight0
                    };

                end


                ADDR_WEIGHT47: begin

                    bus_rdata = {
                        weight7,
                        weight6,
                        weight5,
                        weight4
                    };

                end


                ADDR_WEIGHT8: begin

                    bus_rdata = {
                        24'b0,
                        weight8
                    };

                end


                ADDR_RESULT: begin

                    bus_rdata = accel_result;

                end


                default: begin

                    bus_rdata = 32'b0;

                end

            endcase

        end

    end

endmodule
