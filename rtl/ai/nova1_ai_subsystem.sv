module nova1_ai_subsystem #(
    parameter integer MAX_WIDTH             = 4096,
    parameter integer MAX_OUTPUTS           = 8294400,
    parameter integer MAX_INPUT_CHANNELS    = 64,
    parameter integer MAX_OUTPUT_CHANNELS   = 64,
    parameter integer FILTER_LANES          = 4,
    parameter integer MAX_LAYERS            = 8,
    parameter integer PIPELINE_DRAIN_CYCLES = 4
)(
    input logic clk,
    input logic reset,

    // =========================================================
    // CPU / MMIO INTERFACE
    // =========================================================

    input  logic        accel_read,
    input  logic        accel_write,

    input  logic [31:0] address,
    input  logic [31:0] write_data,

    output logic [31:0] read_data,


    // =========================================================
    // SHARED MEMORY INTERFACE
    // =========================================================

    output logic        dma_mem_read_req,
    output logic [31:0] dma_mem_read_address,

    input logic [31:0] dma_mem_read_data,
    input logic        dma_mem_read_valid,

    output logic        dma_mem_write_req,
    output logic [31:0] dma_mem_write_address,
    output logic [31:0] dma_mem_write_data,


    // =========================================================
    // AI STATUS
    // =========================================================

    output logic busy,
    output logic done
);


    // =========================================================
    // COMMON IMAGE CONFIGURATION FROM MMIO
    // =========================================================

    logic [15:0] image_width;
    logic [15:0] image_height;

    logic [31:0] input_base_address;
    logic [31:0] legacy_output_base_address;


    // =========================================================
    // LEGACY MMIO PATH
    // =========================================================

    logic legacy_dma_start;

    logic legacy_busy;
    logic legacy_done;

    logic signed [31:0] legacy_feature_out;
    logic               legacy_feature_valid;


    // =========================================================
    // NETWORK CONFIGURATION
    // =========================================================

    logic [15:0] network_num_layers;
    logic [15:0] network_input_channels;

    logic [31:0] network_buffer_a_base;
    logic [31:0] network_buffer_b_base;

    logic network_start;


    // =========================================================
    // NETWORK STATUS
    // =========================================================

    logic network_busy;
    logic network_done;


    // =========================================================
    // LAYER DESCRIPTOR PROGRAMMING
    // =========================================================

    logic        layer_descriptor_wr_en;
    logic [15:0] layer_descriptor_wr_index;
    logic [15:0] layer_descriptor_wr_cout;
    logic [1:0]  layer_descriptor_wr_stride;


    // =========================================================
    // MODEL PROGRAMMING LAYER
    // =========================================================

    logic [15:0] network_weight_wr_layer;


    // =========================================================
    // NETWORK WEIGHT PROGRAMMING
    // =========================================================

    logic network_weight_wr_en;

    logic [15:0] network_weight_wr_filter;
    logic [15:0] network_weight_wr_channel;

    logic [3:0] network_weight_wr_tap;

    logic signed [7:0] network_weight_wr_data;


    // =========================================================
    // NETWORK BIAS PROGRAMMING
    // =========================================================

    logic network_bias_wr_en;

    logic [15:0] network_bias_wr_filter;

    logic signed [31:0] network_bias_wr_data;


    // =========================================================
    // NETWORK QUANTIZATION PROGRAMMING
    // =========================================================

    logic network_quant_wr_en;

    logic [15:0] network_quant_wr_filter;

    logic [4:0] network_quant_wr_data;


    // =========================================================
    // NETWORK DEBUG
    // =========================================================

    logic [15:0] current_layer;

    logic [15:0] active_width;
    logic [15:0] active_height;

    logic [15:0] active_cin;
    logic [15:0] active_cout;

    logic active_layout_c4;

    logic [1:0] active_stride;

    logic [15:0] active_output_width;
    logic [15:0] active_output_height;

    logic [31:0] active_input_base;
    logic [31:0] active_output_base;


    // =========================================================
    // MMIO
    // =========================================================

    nova1_ai_mmio #(
        .MAX_WIDTH(
            MAX_WIDTH
        )
    ) MMIO_ACCEL (

        .clk(
            clk
        ),

        .reset(
            reset
        ),


        // =====================================================
        // CPU BUS
        // =====================================================

        .accel_read(
            accel_read
        ),

        .accel_write(
            accel_write
        ),

        .address(
            address
        ),

        .write_data(
            write_data
        ),

        .read_data(
            read_data
        ),


        // =====================================================
        // LEGACY STREAMING ACCELERATOR INPUT
        // =====================================================

        .pixel_in(
            8'sd0
        ),

        .pixel_valid(
            1'b0
        ),

        .feature_out(
            legacy_feature_out
        ),

        .feature_valid(
            legacy_feature_valid
        ),


        // =====================================================
        // COMMON IMAGE CONFIG
        // =====================================================

        .input_base_address(
            input_base_address
        ),

        .output_base_address(
            legacy_output_base_address
        ),

        .image_width(
            image_width
        ),

        .image_height(
            image_height
        ),

        .dma_start(
            legacy_dma_start
        ),


        // =====================================================
        // LEGACY STATUS
        // =====================================================

        .busy(
            legacy_busy
        ),

        .done(
            legacy_done
        ),


        // =====================================================
        // NETWORK CONFIGURATION
        // =====================================================

        .network_num_layers(
            network_num_layers
        ),

        .network_input_channels(
            network_input_channels
        ),

        .network_buffer_a_base(
            network_buffer_a_base
        ),

        .network_buffer_b_base(
            network_buffer_b_base
        ),

        .network_start(
            network_start
        ),


        // =====================================================
        // LAYER DESCRIPTORS
        // =====================================================

        .layer_descriptor_wr_en(
            layer_descriptor_wr_en
        ),

        .layer_descriptor_wr_index(
            layer_descriptor_wr_index
        ),

        .layer_descriptor_wr_cout(
            layer_descriptor_wr_cout
        ),

        .layer_descriptor_wr_stride(
            layer_descriptor_wr_stride
        ),


        // =====================================================
        // MODEL PROGRAMMING LAYER
        // =====================================================

        .network_weight_wr_layer(
            network_weight_wr_layer
        ),


        // =====================================================
        // WEIGHTS
        // =====================================================

        .network_weight_wr_en(
            network_weight_wr_en
        ),

        .network_weight_wr_filter(
            network_weight_wr_filter
        ),

        .network_weight_wr_channel(
            network_weight_wr_channel
        ),

        .network_weight_wr_tap(
            network_weight_wr_tap
        ),

        .network_weight_wr_data(
            network_weight_wr_data
        ),


        // =====================================================
        // BIAS
        // =====================================================

        .network_bias_wr_en(
            network_bias_wr_en
        ),

        .network_bias_wr_filter(
            network_bias_wr_filter
        ),

        .network_bias_wr_data(
            network_bias_wr_data
        ),


        // =====================================================
        // QUANTIZATION
        // =====================================================

        .network_quant_wr_en(
            network_quant_wr_en
        ),

        .network_quant_wr_filter(
            network_quant_wr_filter
        ),

        .network_quant_wr_data(
            network_quant_wr_data
        ),


        // =====================================================
        // REAL NETWORK STATUS
        // =====================================================

        .network_busy(
            network_busy
        ),

        .network_done(
            network_done
        )

    );


    // =========================================================
    // REAL PROGRAMMABLE CNN NETWORK ENGINE
    // =========================================================

    cnn_network_engine #(

        .MAX_WIDTH(
            MAX_WIDTH
        ),

        .MAX_OUTPUTS(
            MAX_OUTPUTS
        ),

        .MAX_INPUT_CHANNELS(
            MAX_INPUT_CHANNELS
        ),

        .MAX_OUTPUT_CHANNELS(
            MAX_OUTPUT_CHANNELS
        ),

        .FILTER_LANES(
            FILTER_LANES
        ),

        .MAX_LAYERS(
            MAX_LAYERS
        ),

        .PIPELINE_DRAIN_CYCLES(
            PIPELINE_DRAIN_CYCLES
        )

    ) NETWORK_ENGINE (

        .clk(
            clk
        ),

        .reset(
            reset
        ),


        // =====================================================
        // NETWORK CONTROL
        // =====================================================

        .start(
            network_start
        ),

        .num_layers(
            network_num_layers
        ),


        // =====================================================
        // ORIGINAL INPUT TENSOR
        // =====================================================

        .original_width(
            image_width
        ),

        .original_height(
            image_height
        ),

        .original_channels(
            network_input_channels
        ),

        .original_input_base(
            input_base_address
        ),


        // =====================================================
        // PING-PONG FEATURE BUFFERS
        // =====================================================

        .buffer_a_base(
            network_buffer_a_base
        ),

        .buffer_b_base(
            network_buffer_b_base
        ),


        // =====================================================
        // NETWORK STATUS
        // =====================================================

        .busy(
            network_busy
        ),

        .done(
            network_done
        ),


        // =====================================================
        // SHARED MEMORY
        // =====================================================

        .mem_read_req(
            dma_mem_read_req
        ),

        .mem_read_address(
            dma_mem_read_address
        ),

        .mem_read_data(
            dma_mem_read_data
        ),

        .mem_read_valid(
            dma_mem_read_valid
        ),

        .mem_write_req(
            dma_mem_write_req
        ),

        .mem_write_address(
            dma_mem_write_address
        ),

        .mem_write_data(
            dma_mem_write_data
        ),


        // =====================================================
        // MODEL PROGRAMMING LAYER
        // =====================================================

        .weight_wr_layer(
            network_weight_wr_layer
        ),


        // =====================================================
        // MODEL WEIGHTS FROM CPU/MMIO
        // =====================================================

        .weight_wr_en(
            network_weight_wr_en
        ),

        .weight_wr_filter(
            network_weight_wr_filter
        ),

        .weight_wr_channel(
            network_weight_wr_channel
        ),

        .weight_wr_tap(
            network_weight_wr_tap
        ),

        .weight_wr_data(
            network_weight_wr_data
        ),


        // =====================================================
        // MODEL BIAS FROM CPU/MMIO
        // =====================================================

        .bias_wr_en(
            network_bias_wr_en
        ),

        .bias_wr_filter(
            network_bias_wr_filter
        ),

        .bias_wr_data(
            network_bias_wr_data
        ),


        // =====================================================
        // MODEL QUANTIZATION FROM CPU/MMIO
        // =====================================================

        .quant_wr_en(
            network_quant_wr_en
        ),

        .quant_wr_filter(
            network_quant_wr_filter
        ),

        .quant_wr_data(
            network_quant_wr_data
        ),


        // =====================================================
        // CPU-PROGRAMMABLE LAYER DESCRIPTORS
        // =====================================================

        .descriptor_wr_en(
            layer_descriptor_wr_en
        ),

        .descriptor_wr_index(
            layer_descriptor_wr_index
        ),

        .descriptor_wr_cout(
            layer_descriptor_wr_cout
        ),

        .descriptor_wr_stride(
            layer_descriptor_wr_stride
        ),


        // =====================================================
        // DEBUG
        // =====================================================

        .current_layer(
            current_layer
        ),

        .active_width(
            active_width
        ),

        .active_height(
            active_height
        ),

        .active_cin(
            active_cin
        ),

        .active_cout(
            active_cout
        ),

        .active_layout_c4(
            active_layout_c4
        ),

        .active_stride(
            active_stride
        ),

        .active_output_width(
            active_output_width
        ),

        .active_output_height(
            active_output_height
        ),

        .active_input_base(
            active_input_base
        ),

        .active_output_base(
            active_output_base
        )

    );


    // =========================================================
    // TOP-LEVEL STATUS
    // =========================================================

    always_comb begin

        busy =
            network_busy;

        done =
            network_done;

    end


endmodule
