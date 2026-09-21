module cnn_network_controller #(
    parameter integer MAX_LAYERS = 8
)(
    input logic clk,
    input logic reset,

    // =========================================================
    // NETWORK CONTROL
    // =========================================================

    input logic start,
    input logic [15:0] num_layers,

    // =========================================================
    // ORIGINAL INPUT CONFIGURATION
    // =========================================================

    input logic [15:0] original_width,
    input logic [15:0] original_height,
    input logic [15:0] original_channels,

    input logic [31:0] original_input_base,

    // =========================================================
    // PING-PONG FEATURE BUFFERS
    // =========================================================

    input logic [31:0] buffer_a_base,
    input logic [31:0] buffer_b_base,

    // =========================================================
    // CPU/MMIO LAYER DESCRIPTOR WRITE INTERFACE
    //
    // descriptor_wr_en is a one-cycle commit pulse.
    // =========================================================

    input logic        descriptor_wr_en,
    input logic [15:0] descriptor_wr_index,
    input logic [15:0] descriptor_wr_cout,
    input logic [1:0]  descriptor_wr_stride,

    // =========================================================
    // LAYER ENGINE HANDSHAKE
    // =========================================================

    input logic layer_done,

    output logic layer_start,

    // =========================================================
    // CURRENT LAYER CONFIGURATION
    // =========================================================

    output logic [15:0] current_layer,

    output logic [15:0] layer_width,
    output logic [15:0] layer_height,

    output logic [15:0] layer_input_channels,
    output logic [15:0] layer_output_channels,

    output logic layer_input_layout_c4,

    output logic [1:0] layer_stride,

    output logic [31:0] layer_input_base,
    output logic [31:0] layer_output_base,

    // =========================================================
    // CALCULATED OUTPUT GEOMETRY
    // =========================================================

    output logic [15:0] layer_output_width,
    output logic [15:0] layer_output_height,

    // =========================================================
    // STATUS
    // =========================================================

    output logic busy,
    output logic done
);


    // =========================================================
    // CPU-PROGRAMMABLE LAYER DESCRIPTOR MEMORY
    //
    // Geometry does NOT need to be programmed per layer.
    //
    // Cin automatically comes from the previous Cout.
    // Width/height automatically come from previous geometry.
    //
    // CPU only programs:
    //
    //   Cout
    //   stride
    // =========================================================

    logic [15:0] cout_mem
        [0:MAX_LAYERS-1];

    logic [1:0] stride_mem
        [0:MAX_LAYERS-1];


    integer i;


    // =========================================================
    // DYNAMIC GEOMETRY STATE
    // =========================================================

    logic [15:0] next_width;
    logic [15:0] next_height;
    logic [15:0] next_channels;


    // =========================================================
    // GEOMETRY CALCULATOR
    // =========================================================

    logic geometry_valid;


    cnn_output_geometry GEOMETRY (

        .input_width(
            layer_width
        ),

        .input_height(
            layer_height
        ),

        .stride(
            layer_stride
        ),

        .output_width(
            layer_output_width
        ),

        .output_height(
            layer_output_height
        ),

        .valid(
            geometry_valid
        )

    );


    // =========================================================
    // NETWORK FSM
    // =========================================================

    typedef enum logic [2:0] {

        IDLE,

        LOAD_LAYER,

        START_LAYER,

        WAIT_DONE_CLEAR,

        WAIT_LAYER,

        NEXT_LAYER,

        FINISHED

    } state_t;


    state_t state;


    // =========================================================
    // CONTROL
    // =========================================================

    always_ff @(posedge clk) begin

        if (reset) begin

            state <=
                IDLE;


            current_layer <=
                16'd0;


            layer_width <=
                16'd0;

            layer_height <=
                16'd0;


            layer_input_channels <=
                16'd0;

            layer_output_channels <=
                16'd0;


            layer_input_layout_c4 <=
                1'b0;

            layer_stride <=
                2'd1;


            layer_input_base <=
                32'd0;

            layer_output_base <=
                32'd0;


            next_width <=
                16'd0;

            next_height <=
                16'd0;

            next_channels <=
                16'd0;


            layer_start <=
                1'b0;


            busy <=
                1'b0;

            done <=
                1'b0;


            // =================================================
            // DEFAULT DESCRIPTOR TABLE
            //
            // These defaults preserve our existing tests.
            //
            // CPU may overwrite them through MMIO.
            // =================================================

            for (
                i = 0;
                i < MAX_LAYERS;
                i = i + 1
            ) begin

                cout_mem[i] <=
                    16'd0;

                stride_mem[i] <=
                    2'd1;

            end


            // Layer 0
            //
            // RGB input -> 4 output channels
            // stride 2

            cout_mem[0] <=
                16'd4;

            stride_mem[0] <=
                2'd2;


            // Layer 1

            if (MAX_LAYERS > 1) begin

                cout_mem[1] <=
                    16'd8;

                stride_mem[1] <=
                    2'd1;

            end


            // Layer 2

            if (MAX_LAYERS > 2) begin

                cout_mem[2] <=
                    16'd4;

                stride_mem[2] <=
                    2'd1;

            end

        end

        else begin

            // =================================================
            // DEFAULT ONE-CYCLE START PULSE
            // =================================================

            layer_start <=
                1'b0;


            // =================================================
            // CPU/MMIO DESCRIPTOR PROGRAMMING
            // =================================================

            if (
                descriptor_wr_en &&
                (descriptor_wr_index < MAX_LAYERS)
            ) begin

                cout_mem[
                    descriptor_wr_index
                ] <=
                    descriptor_wr_cout;


                // Only stride 1 or 2 is accepted.
                //
                // Invalid values fall back to stride 1.

                if (
                    descriptor_wr_stride == 2'd2
                ) begin

                    stride_mem[
                        descriptor_wr_index
                    ] <=
                        2'd2;

                end

                else begin

                    stride_mem[
                        descriptor_wr_index
                    ] <=
                        2'd1;

                end

            end


            // =================================================
            // FSM
            // =================================================

            case (state)


                // =============================================
                // IDLE
                // =============================================

                IDLE: begin

                    busy <=
                        1'b0;


                    if (
                        start &&
                        (num_layers != 16'd0)
                    ) begin

                        busy <=
                            1'b1;

                        done <=
                            1'b0;


                        current_layer <=
                            16'd0;


                        // Seed geometry from original image.

                        next_width <=
                            original_width;

                        next_height <=
                            original_height;

                        next_channels <=
                            original_channels;


                        state <=
                            LOAD_LAYER;

                    end

                end


                // =============================================
                // LOAD CURRENT LAYER
                // =============================================

                LOAD_LAYER: begin

                    // -----------------------------------------
                    // Dynamic input geometry
                    // -----------------------------------------

                    layer_width <=
                        next_width;

                    layer_height <=
                        next_height;

                    layer_input_channels <=
                        next_channels;


                    // -----------------------------------------
                    // CPU-programmed layer descriptor
                    // -----------------------------------------

                    layer_output_channels <=
                        cout_mem[
                            current_layer
                        ];

                    layer_stride <=
                        stride_mem[
                            current_layer
                        ];


                    // -----------------------------------------
                    // First input is planar.
                    //
                    // All intermediate CNN tensors use C4.
                    // -----------------------------------------

                    if (
                        current_layer == 16'd0
                    ) begin

                        layer_input_layout_c4 <=
                            1'b0;

                    end

                    else begin

                        layer_input_layout_c4 <=
                            1'b1;

                    end


                    // =========================================
                    // INPUT BUFFER
                    // =========================================

                    if (
                        current_layer == 16'd0
                    ) begin

                        layer_input_base <=
                            original_input_base;

                    end

                    else if (
                        current_layer[0]
                    ) begin

                        // Odd layer reads Buffer A.

                        layer_input_base <=
                            buffer_a_base;

                    end

                    else begin

                        // Even layer >= 2 reads Buffer B.

                        layer_input_base <=
                            buffer_b_base;

                    end


                    // =========================================
                    // OUTPUT BUFFER
                    // =========================================

                    if (
                        !current_layer[0]
                    ) begin

                        // Even layer writes Buffer A.

                        layer_output_base <=
                            buffer_a_base;

                    end

                    else begin

                        // Odd layer writes Buffer B.

                        layer_output_base <=
                            buffer_b_base;

                    end


                    state <=
                        START_LAYER;

                end


                // =============================================
                // START REAL CNN LAYER
                // =============================================

                START_LAYER: begin

                    if (
                        geometry_valid &&
                        (layer_output_channels != 16'd0)
                    ) begin

                        layer_start <=
                            1'b1;


                        state <=
                            WAIT_DONE_CLEAR;

                    end

                    else begin

                        // Invalid geometry or descriptor.

                        busy <=
                            1'b0;

                        done <=
                            1'b1;


                        state <=
                            FINISHED;

                    end

                end


                // =============================================
                // WAIT UNTIL PREVIOUS STICKY DONE CLEARS
                // =============================================

                WAIT_DONE_CLEAR: begin

                    if (!layer_done) begin

                        state <=
                            WAIT_LAYER;

                    end

                end


                // =============================================
                // WAIT FOR CURRENT LAYER COMPLETION
                // =============================================

                WAIT_LAYER: begin

                    if (layer_done) begin

                        // -------------------------------------
                        // Propagate geometry into next layer.
                        // -------------------------------------

                        next_width <=
                            layer_output_width;

                        next_height <=
                            layer_output_height;

                        next_channels <=
                            layer_output_channels;


                        // -------------------------------------
                        // Final layer?
                        // -------------------------------------

                        if (
                            (current_layer + 1'b1)
                            >=
                            num_layers
                        ) begin

                            state <=
                                FINISHED;

                        end

                        else begin

                            state <=
                                NEXT_LAYER;

                        end

                    end

                end


                // =============================================
                // ADVANCE NETWORK
                // =============================================

                NEXT_LAYER: begin

                    current_layer <=
                        current_layer + 1'b1;


                    state <=
                        LOAD_LAYER;

                end


                // =============================================
                // ENTIRE NETWORK COMPLETE
                // =============================================

                FINISHED: begin

                    busy <=
                        1'b0;

                    done <=
                        1'b1;


                    // Start another inference without reset.

                    if (
                        start &&
                        (num_layers != 16'd0)
                    ) begin

                        done <=
                            1'b0;

                        busy <=
                            1'b1;


                        current_layer <=
                            16'd0;


                        next_width <=
                            original_width;

                        next_height <=
                            original_height;

                        next_channels <=
                            original_channels;


                        state <=
                            LOAD_LAYER;

                    end

                end


                // =============================================
                // SAFETY
                // =============================================

                default: begin

                    state <=
                        IDLE;

                    busy <=
                        1'b0;

                end

            endcase

        end

    end


endmodule
