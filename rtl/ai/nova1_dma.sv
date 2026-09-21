module nova1_dma (

    input  logic clk,
    input  logic reset,

    // =========================================================
    // CHANNEL REQUEST
    // =========================================================

    input logic        channel_request,
    input logic [15:0] requested_channel,


    // =========================================================
    // TENSOR CONFIGURATION
    // =========================================================

    input logic [15:0] image_width,
    input logic [15:0] image_height,

    // Number of channels contained in input tensor
    input logic [15:0] tensor_channels,

    // 0 = planar INT8
    // 1 = C4 packed
    input logic input_layout_c4,

    input logic [31:0] input_base_address,


    // =========================================================
    // MEMORY READ INTERFACE
    // =========================================================

    output logic        mem_read_req,
    output logic [31:0] mem_read_address,

    input logic [31:0] mem_read_data,
    input logic        mem_read_valid,


    // =========================================================
    // PIXEL STREAM
    // =========================================================

    output logic signed [7:0] pixel_out,
    output logic              pixel_valid,

    output logic [15:0] channel_index,

    output logic channel_start,


    // =========================================================
    // STATUS
    // =========================================================

    output logic busy,

    output logic channel_done
);


    // =========================================================
    // GEOMETRY
    // =========================================================

    logic [31:0] pixels_per_channel;

    logic [31:0] planar_words_per_channel;

    logic [31:0] planar_channel_stride_bytes;


    always_comb begin

        pixels_per_channel =
            image_width * image_height;


        // Planar representation packs four INT8 pixels
        // into each 32-bit word.

        planar_words_per_channel =
            (pixels_per_channel + 32'd3)
            >> 2;


        planar_channel_stride_bytes =
            planar_words_per_channel << 2;

    end


    // =========================================================
    // ACTIVE REQUEST
    // =========================================================

    logic [15:0] active_channel;

    logic active_layout_c4;

    logic [1:0] active_lane;

    logic [31:0] active_group;

    logic [31:0] words_needed;


    // =========================================================
    // COUNTERS
    // =========================================================

    logic [31:0] pixel_count;

    logic [31:0] words_requested;


    // =========================================================
    // READ ADDRESS
    // =========================================================

    logic [31:0] first_read_address;

    logic [31:0] next_read_address;


    // =========================================================
    // TWO-WORD PREFETCH BUFFER
    // =========================================================

    logic [31:0] current_word;
    logic [31:0] next_word;

    logic current_valid;
    logic next_valid;

    logic [1:0] byte_index;

    logic read_pending;


    // =========================================================
    // REQUEST ADDRESS CALCULATION
    // =========================================================

    always_comb begin

        active_group =
            requested_channel >> 2;


        // -----------------------------------------------------
        // PLANAR
        //
        // BASE +
        // channel * planar_stride
        // -----------------------------------------------------

        if (!input_layout_c4) begin

            first_read_address =

                input_base_address

                +

                (
                    requested_channel
                    *
                    planar_channel_stride_bytes
                );


            words_needed =
                planar_words_per_channel;

        end


        // -----------------------------------------------------
        // C4 PACKED
        //
        // Layout is group-major:
        //
        // group0:
        // spatial0 [C3 C2 C1 C0]
        // spatial1 [C3 C2 C1 C0]
        // ...
        //
        // group1:
        // spatial0 [C7 C6 C5 C4]
        // ...
        //
        // Address of first word for requested channel group:
        //
        // BASE +
        // group * pixels_per_channel * 4
        // -----------------------------------------------------

        else begin

            first_read_address =

                input_base_address

                +

                (
                    active_group
                    *
                    pixels_per_channel
                    *
                    32'd4
                );


            // One 32-bit C4 word per spatial position.

            words_needed =
                pixels_per_channel;

        end

    end


    // =========================================================
    // DMA CONTROLLER
    // =========================================================

    always_ff @(posedge clk) begin

        if (reset) begin

            busy <=
                1'b0;

            channel_done <=
                1'b0;


            mem_read_req <=
                1'b0;

            mem_read_address <=
                32'd0;


            pixel_out <=
                8'sd0;

            pixel_valid <=
                1'b0;


            channel_index <=
                16'd0;

            channel_start <=
                1'b0;


            active_channel <=
                16'd0;

            active_layout_c4 <=
                1'b0;

            active_lane <=
                2'd0;


            pixel_count <=
                32'd0;

            words_requested <=
                32'd0;


            current_word <=
                32'd0;

            next_word <=
                32'd0;


            current_valid <=
                1'b0;

            next_valid <=
                1'b0;


            byte_index <=
                2'd0;


            read_pending <=
                1'b0;

            next_read_address <=
                32'd0;

        end

        else begin

            // =================================================
            // DEFAULT PULSES
            // =================================================

            mem_read_req <=
                1'b0;

            pixel_valid <=
                1'b0;

            channel_start <=
                1'b0;

            channel_done <=
                1'b0;


            // =================================================
            // ACCEPT CHANNEL REQUEST
            // =================================================

            if (
                channel_request &&
                !busy
            ) begin

                active_channel <=
                    requested_channel;

                active_layout_c4 <=
                    input_layout_c4;

                active_lane <=
                    requested_channel[1:0];


                channel_index <=
                    requested_channel;


                pixel_count <=
                    32'd0;

                byte_index <=
                    2'd0;


                current_valid <=
                    1'b0;

                next_valid <=
                    1'b0;


                // -------------------------------------------------
                // Reject invalid configuration.
                // -------------------------------------------------

                if (
                    (pixels_per_channel == 32'd0) ||
                    (requested_channel >= tensor_channels) ||
                    (tensor_channels == 16'd0)
                ) begin

                    busy <=
                        1'b0;

                    channel_done <=
                        1'b1;

                    read_pending <=
                        1'b0;

                    words_requested <=
                        32'd0;

                end

                else begin

                    busy <=
                        1'b1;


                    // =============================================
                    // REQUEST FIRST WORD
                    // =============================================

                    mem_read_req <=
                        1'b1;

                    mem_read_address <=
                        first_read_address;


                    read_pending <=
                        1'b1;

                    words_requested <=
                        32'd1;


                    next_read_address <=
                        first_read_address
                        +
                        32'd4;

                end

            end


            // =================================================
            // MEMORY RESPONSE
            // =================================================

            if (
                busy &&
                read_pending &&
                mem_read_valid
            ) begin

                if (!current_valid) begin

                    current_word <=
                        mem_read_data;

                    current_valid <=
                        1'b1;

                    byte_index <=
                        2'd0;

                end

                else if (!next_valid) begin

                    next_word <=
                        mem_read_data;

                    next_valid <=
                        1'b1;

                end


                read_pending <=
                    1'b0;

            end


            // =================================================
            // PREFETCH NEXT WORD
            // =================================================

            if (
                busy &&
                current_valid &&
                !next_valid &&
                !read_pending &&
                (words_requested < words_needed)
            ) begin

                mem_read_req <=
                    1'b1;


                mem_read_address <=
                    next_read_address;


                next_read_address <=
                    next_read_address
                    +
                    32'd4;


                words_requested <=
                    words_requested
                    +
                    1'b1;


                read_pending <=
                    1'b1;

            end


            // =================================================
            // PROMOTE NEXT WORD
            // =================================================

            if (
                busy &&
                !current_valid &&
                next_valid
            ) begin

                current_word <=
                    next_word;

                current_valid <=
                    1'b1;

                next_valid <=
                    1'b0;

                byte_index <=
                    2'd0;

            end


            // =================================================
            // STREAM PIXEL
            // =================================================

            if (
                busy &&
                current_valid &&
                (pixel_count < pixels_per_channel)
            ) begin

                channel_index <=
                    active_channel;


                // First pixel of requested channel

                if (pixel_count == 32'd0) begin

                    channel_start <=
                        1'b1;

                end


                // =================================================
                // PLANAR INPUT
                //
                // Each word contains:
                //
                // P0 P1 P2 P3
                // =================================================

                if (!active_layout_c4) begin

                    case (byte_index)

                        2'd0:
                            pixel_out <=
                                $signed(
                                    current_word[7:0]
                                );

                        2'd1:
                            pixel_out <=
                                $signed(
                                    current_word[15:8]
                                );

                        2'd2:
                            pixel_out <=
                                $signed(
                                    current_word[23:16]
                                );

                        2'd3:
                            pixel_out <=
                                $signed(
                                    current_word[31:24]
                                );

                    endcase

                end


                // =================================================
                // C4 INPUT
                //
                // Each word contains:
                //
                // byte0 = channel group + 0
                // byte1 = channel group + 1
                // byte2 = channel group + 2
                // byte3 = channel group + 3
                //
                // We select one requested channel lane.
                // =================================================

                else begin

                    case (active_lane)

                        2'd0:
                            pixel_out <=
                                $signed(
                                    current_word[7:0]
                                );

                        2'd1:
                            pixel_out <=
                                $signed(
                                    current_word[15:8]
                                );

                        2'd2:
                            pixel_out <=
                                $signed(
                                    current_word[23:16]
                                );

                        2'd3:
                            pixel_out <=
                                $signed(
                                    current_word[31:24]
                                );

                    endcase

                end


                pixel_valid <=
                    1'b1;


                // =================================================
                // FINAL PIXEL
                // =================================================

                if (
                    (pixel_count + 1)
                    >=
                    pixels_per_channel
                ) begin

                    pixel_count <=
                        pixel_count + 1'b1;


                    current_valid <=
                        1'b0;

                    next_valid <=
                        1'b0;

                    read_pending <=
                        1'b0;


                    byte_index <=
                        2'd0;


                    busy <=
                        1'b0;

                    channel_done <=
                        1'b1;

                end


                // =================================================
                // MORE PIXELS
                // =================================================

                else begin

                    pixel_count <=
                        pixel_count + 1'b1;


                    // =============================================
                    // PLANAR MODE
                    //
                    // Consume four bytes before changing word.
                    // =============================================

                    if (!active_layout_c4) begin

                        if (
                            byte_index == 2'd3
                        ) begin

                            byte_index <=
                                2'd0;


                            if (next_valid) begin

                                current_word <=
                                    next_word;

                                current_valid <=
                                    1'b1;

                                next_valid <=
                                    1'b0;

                            end

                            else begin

                                current_valid <=
                                    1'b0;

                            end

                        end

                        else begin

                            byte_index <=
                                byte_index + 1'b1;

                        end

                    end


                    // =============================================
                    // C4 MODE
                    //
                    // One requested-channel pixel per 32-bit word.
                    // Move to next word every pixel.
                    // =============================================

                    else begin

                        byte_index <=
                            2'd0;


                        if (next_valid) begin

                            current_word <=
                                next_word;

                            current_valid <=
                                1'b1;

                            next_valid <=
                                1'b0;

                        end

                        else begin

                            current_valid <=
                                1'b0;

                        end

                    end

                end

            end

        end

    end


endmodule
