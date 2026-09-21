module relu (

    input  logic signed [31:0] data_in,
    input  logic               valid_in,

    output logic signed [31:0] data_out,
    output logic               valid_out

);

    always_comb begin

        valid_out = valid_in;

        if (data_in < 0)
            data_out = 32'sd0;
        else
            data_out = data_in;

    end

endmodule
