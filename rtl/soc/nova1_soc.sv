module nova1_soc (

    input logic clk,
    input logic reset

);

    // =========================================================
    // CPU DATA BUS
    // =========================================================

    logic        cpu_mem_read;
    logic        cpu_mem_write;

    logic [31:0] cpu_address;
    logic [31:0] cpu_write_data;
    logic [31:0] cpu_read_data;


    // =========================================================
    // ADDRESS DECODE
    // =========================================================

    logic accel_select;
    logic dmem_select;

    logic accel_read;
    logic accel_write;

    logic dmem_read;
    logic dmem_write;


    // =========================================================
    // DATA MEMORY CPU PORT
    // =========================================================

    logic [31:0] dmem_cpu_read_data;


    // =========================================================
    // AI MMIO
    // =========================================================

    logic [31:0] accel_read_data;

    logic ai_busy;
    logic ai_done;


    // =========================================================
    // DMA <-> MEMORY
    // =========================================================

    logic        dma_mem_read_req;
    logic [31:0] dma_mem_read_address;

    logic [31:0] dma_mem_read_data;
    logic        dma_mem_read_valid;


    logic        dma_mem_write_req;
    logic [31:0] dma_mem_write_address;
    logic [31:0] dma_mem_write_data;


    // =========================================================
    // RISC-V CPU
    // =========================================================

    riscv_cpu_bus CPU (

        .clk(clk),
        .reset(reset),

        .data_mem_read(cpu_mem_read),
        .data_mem_write(cpu_mem_write),

        .data_address(cpu_address),
        .data_write_data(cpu_write_data),

        .data_read_data(cpu_read_data)

    );


    // =========================================================
    // ADDRESS DECODER
    //
    // AI accelerator:
    //
    // 0x4000_0000 - 0x4000_00FF
    //
    // Everything else goes to normal data memory.
    // =========================================================

    always_comb begin

        if (
            (cpu_address >= 32'h4000_0000) &&
            (cpu_address <= 32'h4000_00FF)
        ) begin

            accel_select = 1'b1;
            dmem_select  = 1'b0;

        end

        else begin

            accel_select = 1'b0;
            dmem_select  = 1'b1;

        end

    end


    // =========================================================
    // CPU CONTROL SIGNAL ROUTING
    // =========================================================

    assign accel_read =
        cpu_mem_read &&
        accel_select;

    assign accel_write =
        cpu_mem_write &&
        accel_select;


    assign dmem_read =
        cpu_mem_read &&
        dmem_select;

    assign dmem_write =
        cpu_mem_write &&
        dmem_select;


    // =========================================================
    // CPU READ DATA MUX
    // =========================================================

    always_comb begin

        if (accel_select)

            cpu_read_data =
                accel_read_data;

        else

            cpu_read_data =
                dmem_cpu_read_data;

    end


    // =========================================================
// AI SUBSYSTEM
//
// Contains:
//
// MMIO register block
// programmable CNN network engine
// layer controller
// channel-request DMA
// stride support
// multi-channel convolution
// parallel filter lanes
// bias / ReLU / INT8 requantization
// ping-pong feature memory interface
// =========================================================

    nova1_ai_subsystem #(
        .MAX_WIDTH(4096)
    ) AI_SUBSYSTEM (

        .clk(clk),
        .reset(reset),

        // CPU MMIO

        .accel_read(accel_read),
        .accel_write(accel_write),

        .address(cpu_address),
        .write_data(cpu_write_data),

        .read_data(accel_read_data),


        // DMA memory READ

        .dma_mem_read_req(
            dma_mem_read_req
        ),

        .dma_mem_read_address(
            dma_mem_read_address
        ),

        .dma_mem_read_data(
            dma_mem_read_data
        ),

        .dma_mem_read_valid(
            dma_mem_read_valid
        ),


        // DMA memory WRITE

        .dma_mem_write_req(
            dma_mem_write_req
        ),

        .dma_mem_write_address(
            dma_mem_write_address
        ),

        .dma_mem_write_data(
            dma_mem_write_data
        ),


        // AI status

        .busy(ai_busy),
        .done(ai_done)

    );


    // =========================================================
    // SHARED DATA MEMORY
    //
    // CPU:
    //     LW / SW
    //
    // DMA:
    //     reads image
    //     writes CNN feature map
    // =========================================================

    data_memory #(
        .MEM_DEPTH(16384)
    ) DMEM (

        .clk(clk),


        // -----------------------------------------------------
        // CPU PORT
        // -----------------------------------------------------

        .cpu_mem_read(
            dmem_read
        ),

        .cpu_mem_write(
            dmem_write
        ),

        .cpu_address(
            cpu_address
        ),

        .cpu_write_data(
            cpu_write_data
        ),

        .cpu_read_data(
            dmem_cpu_read_data
        ),


        // -----------------------------------------------------
        // DMA READ PORT
        // -----------------------------------------------------

        .dma_mem_read_req(
            dma_mem_read_req
        ),

        .dma_mem_read_address(
            dma_mem_read_address
        ),

        .dma_mem_read_data(
            dma_mem_read_data
        ),

        .dma_mem_read_valid(
            dma_mem_read_valid
        ),


        // -----------------------------------------------------
        // DMA WRITE PORT
        // -----------------------------------------------------

        .dma_mem_write_req(
            dma_mem_write_req
        ),

        .dma_mem_write_address(
            dma_mem_write_address
        ),

        .dma_mem_write_data(
            dma_mem_write_data
        )

    );


endmodule
