module cnn_layer_controller #(
    parameter integer FILTER_LANES = 4
)(
    input logic clk,
    input logic reset,

    input logic start,

    input logic [15:0] input_channels,
    input logic [15:0] output_channels,

    // =========================================================
    // HANDSHAKES
    // =========================================================

    input logic channel_done,
    input logic group_compute_done,

    // =========================================================
    // CONTROLLER OUTPUTS
    // =========================================================

    output logic [15:0] current_channel,
    output logic [15:0] filter_base,

    output logic channel_request,
    output logic filter_group_start,

    output logic [FILTER_LANES-1:0] lane_active,

    output logic busy,
    output logic done
);


    typedef enum logic [2:0] {

        IDLE,

        START_GROUP,

        REQUEST_CHANNEL,

        WAIT_CHANNEL,

        WAIT_GROUP_DONE,

        NEXT_GROUP,

        FINISHED

    } state_t;


    state_t state;

    integer lane;


    // =========================================================
    // ACTIVE FILTER LANES
    //
    // Example:
    //
    // Cout = 10
    // FILTER_LANES = 4
    //
    // base 0 -> 1111
    // base 4 -> 1111
    // base 8 -> 0011
    // =========================================================

    always_comb begin

        lane_active = '0;


        for (
            lane = 0;
            lane < FILTER_LANES;
            lane = lane + 1
        ) begin

            if (
                (filter_base + lane)
                <
                output_channels
            ) begin

                lane_active[lane] =
                    1'b1;

            end

        end

    end


    // =========================================================
    // CONTROLLER FSM
    // =========================================================

    always_ff @(posedge clk) begin

        if (reset) begin

            state <=
                IDLE;


            current_channel <=
                16'd0;

            filter_base <=
                16'd0;


            channel_request <=
                1'b0;

            filter_group_start <=
                1'b0;


            busy <=
                1'b0;

            done <=
                1'b0;

        end

        else begin

            // =================================================
            // DEFAULT ONE-CYCLE PULSES
            // =================================================

            channel_request <=
                1'b0;

            filter_group_start <=
                1'b0;


            case (state)


                // =============================================
                // IDLE
                // =============================================

                IDLE: begin

                    busy <=
                        1'b0;


                    // -----------------------------------------
                    // IMPORTANT:
                    //
                    // DONE is NOT automatically cleared here.
                    //
                    // It remains sticky until a new START.
                    // -----------------------------------------


                    if (
                        start &&
                        (input_channels != 16'd0) &&
                        (output_channels != 16'd0)
                    ) begin

                        // New job clears previous DONE.

                        done <=
                            1'b0;


                        busy <=
                            1'b1;


                        current_channel <=
                            16'd0;

                        filter_base <=
                            16'd0;


                        state <=
                            START_GROUP;

                    end

                end


                // =============================================
                // START NEW FILTER GROUP
                // =============================================

                START_GROUP: begin

                    filter_group_start <=
                        1'b1;


                    current_channel <=
                        16'd0;


                    state <=
                        REQUEST_CHANNEL;

                end


                // =============================================
                // REQUEST CURRENT INPUT CHANNEL
                // =============================================

                REQUEST_CHANNEL: begin

                    channel_request <=
                        1'b1;


                    state <=
                        WAIT_CHANNEL;

                end


                // =============================================
                // WAIT FOR DMA / STREAMING ENGINE
                // =============================================

                WAIT_CHANNEL: begin

                    if (channel_done) begin


                        // -------------------------------------
                        // LAST INPUT CHANNEL?
                        // -------------------------------------

                        if (
                            (current_channel + 1'b1)
                            >=
                            input_channels
                        ) begin

                            state <=
                                WAIT_GROUP_DONE;

                        end


                        // -------------------------------------
                        // REQUEST NEXT INPUT CHANNEL
                        // -------------------------------------

                        else begin

                            current_channel <=
                                current_channel + 1'b1;


                            state <=
                                REQUEST_CHANNEL;

                        end

                    end

                end


                // =============================================
                // WAIT FOR FINAL RESULTS OF THIS FILTER GROUP
                // =============================================

                WAIT_GROUP_DONE: begin

                    if (group_compute_done) begin


                        // -------------------------------------
                        // FINAL FILTER GROUP?
                        // -------------------------------------

                        if (
                            (filter_base + FILTER_LANES)
                            >=
                            output_channels
                        ) begin

                            state <=
                                FINISHED;

                        end


                        // -------------------------------------
                        // MORE FILTER GROUPS REMAIN
                        // -------------------------------------

                        else begin

                            state <=
                                NEXT_GROUP;

                        end

                    end

                end


                // =============================================
                // ADVANCE TO NEXT FILTER GROUP
                // =============================================

                NEXT_GROUP: begin

                    filter_base <=
                        filter_base +
                        FILTER_LANES;


                    current_channel <=
                        16'd0;


                    state <=
                        START_GROUP;

                end


                // =============================================
                // FINISHED
                //
                // DONE remains HIGH until the CPU/controller
                // begins another layer.
                // =============================================

                FINISHED: begin

                    busy <=
                        1'b0;

                    done <=
                        1'b1;


                    // -----------------------------------------
                    // Allow another START directly from the
                    // finished state.
                    // -----------------------------------------

                    if (
                        start &&
                        (input_channels != 16'd0) &&
                        (output_channels != 16'd0)
                    ) begin

                        done <=
                            1'b0;

                        busy <=
                            1'b1;


                        current_channel <=
                            16'd0;

                        filter_base <=
                            16'd0;


                        state <=
                            START_GROUP;

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
