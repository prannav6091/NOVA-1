module conv3x3_engine (

    input  logic clk,
    input  logic reset,

    input  logic window_valid,

    input  logic signed [7:0] w00,
    input  logic signed [7:0] w01,
    input  logic signed [7:0] w02,

    input  logic signed [7:0] w10,
    input  logic signed [7:0] w11,
    input  logic signed [7:0] w12,

    input  logic signed [7:0] w20,
    input  logic signed [7:0] w21,
    input  logic signed [7:0] w22,

    input  logic signed [7:0] k00,
    input  logic signed [7:0] k01,
    input  logic signed [7:0] k02,

    input  logic signed [7:0] k10,
    input  logic signed [7:0] k11,
    input  logic signed [7:0] k12,

    input  logic signed [7:0] k20,
    input  logic signed [7:0] k21,
    input  logic signed [7:0] k22,

    output logic signed [31:0] result,
    output logic               result_valid

);

    // 8-bit x 8-bit = 16-bit signed products
    logic signed [15:0] p0, p1, p2;
    logic signed [15:0] p3, p4, p5;
    logic signed [15:0] p6, p7, p8;

    // Explicit 32-bit sign-extended products
    logic signed [31:0] p0_ext, p1_ext, p2_ext;
    logic signed [31:0] p3_ext, p4_ext, p5_ext;
    logic signed [31:0] p6_ext, p7_ext, p8_ext;

    logic signed [31:0] sum_comb;


    always_comb begin

        p0 = w00 * k00;
        p1 = w01 * k01;
        p2 = w02 * k02;

        p3 = w10 * k10;
        p4 = w11 * k11;
        p5 = w12 * k12;

        p6 = w20 * k20;
        p7 = w21 * k21;
        p8 = w22 * k22;


        // Explicit sign extension prevents accidental
        // truncation during chained additions.

        p0_ext = {{16{p0[15]}}, p0};
        p1_ext = {{16{p1[15]}}, p1};
        p2_ext = {{16{p2[15]}}, p2};

        p3_ext = {{16{p3[15]}}, p3};
        p4_ext = {{16{p4[15]}}, p4};
        p5_ext = {{16{p5[15]}}, p5};

        p6_ext = {{16{p6[15]}}, p6};
        p7_ext = {{16{p7[15]}}, p7};
        p8_ext = {{16{p8[15]}}, p8};


        sum_comb =
            p0_ext +
            p1_ext +
            p2_ext +
            p3_ext +
            p4_ext +
            p5_ext +
            p6_ext +
            p7_ext +
            p8_ext;

    end


    always_ff @(posedge clk) begin

        if (reset) begin

            result       <= 32'sd0;
            result_valid <= 1'b0;

        end

        else begin

            result_valid <= window_valid;

            if (window_valid)
                result <= sum_comb;

        end

    end

endmodule
