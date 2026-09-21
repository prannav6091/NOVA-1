import numpy as np

# ============================================================
# NOVA-1 TRAINED CNN -> RISC-V PROGRAM EXPORTER
#
# Reads:
#   nova1_tinycnn_int8.npz
#
# Generates:
#   instruction_memory.sv
#   nova1_trained_program_listing.txt
#   nova1_rtl_vectors.npz
#
# Network:
#
#   Layer 0:
#       8x8x1
#       Conv3x3
#       Cout = 4
#       stride = 2
#       shift = trained SHIFT1
#              ↓
#       3x3x4
#
#   Layer 1:
#       3x3x4
#       Conv3x3
#       Cout = 8
#       stride = 1
#       shift = trained SHIFT2
#              ↓
#       1x1x8
#
# ============================================================


ROM_WORDS = 4096


# ============================================================
# MMIO MAP
# ============================================================

MMIO_BASE = 0x40000000

WIDTH          = 0x08
HEIGHT         = 0x0C
INPUT_BASE     = 0x10

NET_NUM_LAYERS = 0x40
NET_CIN        = 0x44
NET_BUFFER_A   = 0x48
NET_BUFFER_B   = 0x4C

LAYER_INDEX    = 0x50
LAYER_COUT     = 0x54
LAYER_STRIDE   = 0x58
LAYER_COMMIT   = 0x5C

NET_CONTROL    = 0x60
NET_STATUS     = 0x64

MODEL_LAYER    = 0x68

WEIGHT_FILTER  = 0x70
WEIGHT_CHANNEL = 0x74
WEIGHT_TAP     = 0x78
WEIGHT_DATA    = 0x7C
WEIGHT_COMMIT  = 0x80

BIAS_FILTER    = 0x84
BIAS_DATA      = 0x88
BIAS_COMMIT    = 0x8C

QUANT_FILTER   = 0x90
QUANT_DATA     = 0x94
QUANT_COMMIT   = 0x98


# ============================================================
# LOAD QUANTIZED TRAINED MODEL
# ============================================================

model = np.load(
    "nova1_tinycnn_int8.npz"
)

W1 = model["W1"].astype(np.int32)
b1 = model["b1"].astype(np.int32)

W2 = model["W2"].astype(np.int32)
b2 = model["b2"].astype(np.int32)

SHIFT1 = int(model["shift1"])
SHIFT2 = int(model["shift2"])

test_input = model[
    "test_input"
].astype(np.uint8)

expected_layer1 = model[
    "expected_layer1"
].astype(np.uint8)

expected_scores = model[
    "expected_scores"
].astype(np.uint8)

expected_class = int(
    model["expected_class"]
)

test_index = int(
    model["test_index"]
)


# ============================================================
# VALIDATE MODEL DIMENSIONS
# ============================================================

assert W1.shape == (4, 1, 3, 3), (
    f"Unexpected W1 shape: {W1.shape}"
)

assert b1.shape == (4,), (
    f"Unexpected b1 shape: {b1.shape}"
)

assert W2.shape == (8, 4, 3, 3), (
    f"Unexpected W2 shape: {W2.shape}"
)

assert b2.shape == (8,), (
    f"Unexpected b2 shape: {b2.shape}"
)

assert test_input.shape == (8, 8, 1), (
    f"Unexpected test input shape: {test_input.shape}"
)

assert expected_layer1.shape == (3, 3, 4), (
    "Unexpected Layer-1 expected shape: "
    f"{expected_layer1.shape}"
)

assert expected_scores.shape == (8,), (
    "Unexpected final score shape: "
    f"{expected_scores.shape}"
)


# ============================================================
# BASIC HELPERS
# ============================================================

def u32(value):
    return value & 0xFFFFFFFF


def signed12_fits(value):
    return -2048 <= value <= 2047


# ============================================================
# RV32I ENCODERS
# ============================================================

def encode_lui(rd, imm20):

    return u32(
        ((imm20 & 0xFFFFF) << 12)
        |
        ((rd & 0x1F) << 7)
        |
        0x37
    )


def encode_addi(rd, rs1, imm):

    if not signed12_fits(imm):
        raise ValueError(
            f"ADDI immediate does not fit: {imm}"
        )

    imm12 = imm & 0xFFF

    return u32(
        (imm12 << 20)
        |
        ((rs1 & 0x1F) << 15)
        |
        (0 << 12)
        |
        ((rd & 0x1F) << 7)
        |
        0x13
    )


def encode_sw(rs2, rs1, imm):

    if not signed12_fits(imm):
        raise ValueError(
            f"SW immediate does not fit: {imm}"
        )

    imm12 = imm & 0xFFF

    imm11_5 = (
        imm12 >> 5
    ) & 0x7F

    imm4_0 = (
        imm12
    ) & 0x1F

    return u32(
        (imm11_5 << 25)
        |
        ((rs2 & 0x1F) << 20)
        |
        ((rs1 & 0x1F) << 15)
        |
        (2 << 12)
        |
        (imm4_0 << 7)
        |
        0x23
    )


def encode_lw(rd, rs1, imm):

    if not signed12_fits(imm):
        raise ValueError(
            f"LW immediate does not fit: {imm}"
        )

    imm12 = imm & 0xFFF

    return u32(
        (imm12 << 20)
        |
        ((rs1 & 0x1F) << 15)
        |
        (2 << 12)
        |
        ((rd & 0x1F) << 7)
        |
        0x03
    )


def encode_bne(rs1, rs2, offset):

    if offset % 2 != 0:
        raise ValueError(
            "BNE offset must be even."
        )

    if not (-4096 <= offset <= 4094):
        raise ValueError(
            f"BNE offset out of range: {offset}"
        )

    imm = offset & 0x1FFF

    bit12 = (
        imm >> 12
    ) & 1

    bit11 = (
        imm >> 11
    ) & 1

    bits10_5 = (
        imm >> 5
    ) & 0x3F

    bits4_1 = (
        imm >> 1
    ) & 0xF

    return u32(
        (bit12 << 31)
        |
        (bits10_5 << 25)
        |
        ((rs2 & 0x1F) << 20)
        |
        ((rs1 & 0x1F) << 15)
        |
        (1 << 12)
        |
        (bits4_1 << 8)
        |
        (bit11 << 7)
        |
        0x63
    )


def encode_jal(rd, offset):

    if offset % 2 != 0:
        raise ValueError(
            "JAL offset must be even."
        )

    imm = offset & 0x1FFFFF

    bit20 = (
        imm >> 20
    ) & 1

    bits10_1 = (
        imm >> 1
    ) & 0x3FF

    bit11 = (
        imm >> 11
    ) & 1

    bits19_12 = (
        imm >> 12
    ) & 0xFF

    return u32(
        (bit20 << 31)
        |
        (bits10_1 << 21)
        |
        (bit11 << 20)
        |
        (bits19_12 << 12)
        |
        ((rd & 0x1F) << 7)
        |
        0x6F
    )


# ============================================================
# PROGRAM STORAGE
# ============================================================

program = []
comments = []


def emit(instruction, comment):

    program.append(
        u32(instruction)
    )

    comments.append(
        comment
    )


# ============================================================
# REGISTER USE
#
# x10 = MMIO base 0x40000000
# x11 = temporary value
# x12 = temporary large value/base
# x13 = expected DONE value
# ============================================================


# ============================================================
# LOAD ARBITRARY 32-BIT CONSTANT
#
# Uses:
#
#   LUI  rd, upper
#   ADDI rd, rd, lower
#
# RISC-V lower immediate is signed, so we use the standard
# +0x800 rounding before selecting the upper 20 bits.
# ============================================================

def load_imm32(rd, value, comment=""):

    value = u32(value)

    signed_value = (
        value
        if value < 0x80000000
        else value - 0x100000000
    )

    if signed12_fits(
        signed_value
    ):

        emit(
            encode_addi(
                rd,
                0,
                signed_value
            ),
            comment or (
                f"x{rd} = {signed_value}"
            )
        )

        return


    upper = (
        value + 0x800
    ) >> 12

    upper &= 0xFFFFF

    lower = (
        value
        -
        (upper << 12)
    )

    lower &= 0xFFFFFFFF

    if lower >= 0x80000000:
        lower -= 0x100000000


    emit(
        encode_lui(
            rd,
            upper
        ),
        (
            comment
            +
            f" [upper 0x{upper:05X}]"
        ).strip()
    )


    if lower != 0:

        if not signed12_fits(lower):
            raise RuntimeError(
                "Internal immediate generation error: "
                f"{lower}"
            )

        emit(
            encode_addi(
                rd,
                rd,
                lower
            ),
            f"x{rd} lower immediate {lower}"
        )


# ============================================================
# MMIO WRITE
# ============================================================

def mmio_write(
    offset,
    value,
    description
):

    load_imm32(
        11,
        int(value),
        f"x11 = {int(value)}"
    )

    emit(
        encode_sw(
            11,
            10,
            offset
        ),
        description
    )


# ============================================================
# PROGRAM ONE WEIGHT
# ============================================================

weight_write_count = 0
zero_weight_count = 0


def program_weight(
    layer,
    filt,
    channel,
    tap,
    value
):

    global weight_write_count
    global zero_weight_count

    value = int(value)

    # Model memories are expected to reset to zero.
    # Skip zero weights to keep the program compact.

    if value == 0:

        zero_weight_count += 1
        return


    mmio_write(
        WEIGHT_FILTER,
        filt,
        f"L{layer} weight filter = {filt}"
    )

    mmio_write(
        WEIGHT_CHANNEL,
        channel,
        f"L{layer} weight channel = {channel}"
    )

    mmio_write(
        WEIGHT_TAP,
        tap,
        f"L{layer} weight tap = {tap}"
    )

    mmio_write(
        WEIGHT_DATA,
        value,
        (
            f"L{layer} weight data = {value}"
        )
    )

    mmio_write(
        WEIGHT_COMMIT,
        1,
        (
            f"COMMIT L{layer} "
            f"F{filt} C{channel} "
            f"T{tap} = {value}"
        )
    )

    weight_write_count += 1


# ============================================================
# PROGRAM ONE BIAS
# ============================================================

def program_bias(
    layer,
    filt,
    value
):

    mmio_write(
        BIAS_FILTER,
        filt,
        f"L{layer} bias filter = {filt}"
    )

    mmio_write(
        BIAS_DATA,
        int(value),
        (
            f"L{layer} bias data = "
            f"{int(value)}"
        )
    )

    mmio_write(
        BIAS_COMMIT,
        1,
        (
            f"COMMIT L{layer} "
            f"bias F{filt} = {int(value)}"
        )
    )


# ============================================================
# PROGRAM ONE QUANTIZATION SHIFT
# ============================================================

def program_quant(
    layer,
    filt,
    shift
):

    mmio_write(
        QUANT_FILTER,
        filt,
        (
            f"L{layer} quant filter = "
            f"{filt}"
        )
    )

    mmio_write(
        QUANT_DATA,
        int(shift),
        (
            f"L{layer} quant shift = "
            f"{int(shift)}"
        )
    )

    mmio_write(
        QUANT_COMMIT,
        1,
        (
            f"COMMIT L{layer} "
            f"quant F{filt} shift={int(shift)}"
        )
    )


# ============================================================
# BEGIN CPU PROGRAM
# ============================================================

# x10 = 0x40000000

emit(
    encode_lui(
        10,
        0x40000
    ),
    "x10 = NOVA-1 AI MMIO base"
)


# ============================================================
# GLOBAL NETWORK CONFIGURATION
# ============================================================

mmio_write(
    WIDTH,
    8,
    "IMAGE WIDTH = 8"
)

mmio_write(
    HEIGHT,
    8,
    "IMAGE HEIGHT = 8"
)

load_imm32(
    12,
    0x00001000,
    "x12 = input base 0x1000"
)

emit(
    encode_sw(
        12,
        10,
        INPUT_BASE
    ),
    "INPUT_BASE = 0x00001000"
)


mmio_write(
    NET_CIN,
    1,
    "NETWORK Cin = 1"
)

mmio_write(
    NET_NUM_LAYERS,
    2,
    "NETWORK NUM_LAYERS = 2"
)


load_imm32(
    12,
    0x00004000,
    "x12 = buffer A 0x4000"
)

emit(
    encode_sw(
        12,
        10,
        NET_BUFFER_A
    ),
    "BUFFER_A = 0x00004000"
)


load_imm32(
    12,
    0x00008000,
    "x12 = buffer B 0x8000"
)

emit(
    encode_sw(
        12,
        10,
        NET_BUFFER_B
    ),
    "BUFFER_B = 0x00008000"
)


# ============================================================
# LAYER 0 DESCRIPTOR
#
# 8x8x1 -> 3x3x4
# ============================================================

mmio_write(
    LAYER_INDEX,
    0,
    "Descriptor layer = 0"
)

mmio_write(
    LAYER_COUT,
    4,
    "Layer 0 Cout = 4"
)

mmio_write(
    LAYER_STRIDE,
    2,
    "Layer 0 stride = 2"
)

mmio_write(
    LAYER_COMMIT,
    1,
    "COMMIT layer 0 descriptor"
)


# ============================================================
# LAYER 1 DESCRIPTOR
#
# 3x3x4 -> 1x1x8
# ============================================================

mmio_write(
    LAYER_INDEX,
    1,
    "Descriptor layer = 1"
)

mmio_write(
    LAYER_COUT,
    8,
    "Layer 1 Cout = 8"
)

mmio_write(
    LAYER_STRIDE,
    1,
    "Layer 1 stride = 1"
)

mmio_write(
    LAYER_COMMIT,
    1,
    "COMMIT layer 1 descriptor"
)


# ============================================================
# PROGRAM LAYER 0 MODEL
# ============================================================

mmio_write(
    MODEL_LAYER,
    0,
    "MODEL_LAYER = 0"
)


for f in range(4):

    for c in range(1):

        for ky in range(3):

            for kx in range(3):

                tap = (
                    ky * 3
                    +
                    kx
                )

                program_weight(
                    0,
                    f,
                    c,
                    tap,
                    W1[
                        f,
                        c,
                        ky,
                        kx
                    ]
                )


for f in range(4):

    program_bias(
        0,
        f,
        b1[f]
    )


for f in range(4):

    program_quant(
        0,
        f,
        SHIFT1
    )


# ============================================================
# PROGRAM LAYER 1 MODEL
# ============================================================

mmio_write(
    MODEL_LAYER,
    1,
    "MODEL_LAYER = 1"
)


for f in range(8):

    for c in range(4):

        for ky in range(3):

            for kx in range(3):

                tap = (
                    ky * 3
                    +
                    kx
                )

                program_weight(
                    1,
                    f,
                    c,
                    tap,
                    W2[
                        f,
                        c,
                        ky,
                        kx
                    ]
                )


for f in range(8):

    program_bias(
        1,
        f,
        b2[f]
    )


for f in range(8):

    program_quant(
        1,
        f,
        SHIFT2
    )


# ============================================================
# START NETWORK
# ============================================================

mmio_write(
    NET_CONTROL,
    1,
    "START TRAINED CNN"
)


# ============================================================
# POLL NET_STATUS
#
# DONE = 2
# ============================================================

load_imm32(
    13,
    2,
    "x13 = DONE status"
)

poll_pc = len(program) * 4

emit(
    encode_lw(
        11,
        10,
        NET_STATUS
    ),
    "Read NET_STATUS"
)

branch_pc = len(program) * 4

branch_offset = (
    poll_pc
    -
    branch_pc
)

emit(
    encode_bne(
        11,
        13,
        branch_offset
    ),
    "Poll until NET_STATUS == 2"
)


# ============================================================
# HALT
# ============================================================

emit(
    encode_jal(
        0,
        0
    ),
    "HALT"
)


# ============================================================
# CHECK ROM SIZE
# ============================================================

if len(program) > ROM_WORDS:

    raise RuntimeError(
        "\nGenerated program does not fit ROM.\n"
        f"Instructions : {len(program)}\n"
        f"ROM words    : {ROM_WORDS}\n"
    )


# ============================================================
# GENERATE instruction_memory.sv
# ============================================================

with open(
    "instruction_memory.sv",
    "w",
    encoding="utf-8"
) as f:

    f.write(
        "module instruction_memory (\n"
    )

    f.write(
        "    input  logic [31:0] address,\n"
    )

    f.write(
        "    output logic [31:0] instruction\n"
    )

    f.write(
        ");\n\n"
    )

    f.write(
        f"    logic [31:0] mem [0:{ROM_WORDS-1}];\n"
    )

    f.write(
        "    integer i;\n\n"
    )

    f.write(
        "    initial begin\n\n"
    )

    f.write(
        f"        for (i = 0; i < {ROM_WORDS}; "
        "i = i + 1)\n"
    )

    f.write(
        "            mem[i] = 32'h00000013;\n\n"
    )


    for index, (
        instruction,
        comment
    ) in enumerate(
        zip(
            program,
            comments
        )
    ):

        f.write(
            f"        mem[{index}] = "
            f"32'h{instruction:08X}; "
            f"// {comment}\n"
        )


    f.write(
        "\n    end\n\n"
    )

    f.write(
        "    always_comb begin\n"
    )

    # 4096 words = 12-bit word index.
    # Ignore upper address bits instead of indexing with [31:2],
    # which can produce out-of-range accesses.

    f.write(
        "        instruction = mem[address[13:2]];\n"
    )

    f.write(
        "    end\n\n"
    )

    f.write(
        "endmodule\n"
    )


# ============================================================
# GENERATE HUMAN-READABLE LISTING
# ============================================================

with open(
    "nova1_trained_program_listing.txt",
    "w",
    encoding="utf-8"
) as f:

    for index, (
        instruction,
        comment
    ) in enumerate(
        zip(
            program,
            comments
        )
    ):

        pc = index * 4

        f.write(
            f"{pc:08X}  "
            f"{instruction:08X}  "
            f"{comment}\n"
        )


# ============================================================
# SAVE RTL REFERENCE VECTORS
# ============================================================

np.savez(
    "nova1_rtl_vectors.npz",

    input_image=test_input,

    expected_layer1=expected_layer1,

    expected_scores=expected_scores,

    expected_class=np.array(
        expected_class,
        dtype=np.int32
    ),

    test_index=np.array(
        test_index,
        dtype=np.int32
    ),

    shift1=np.array(
        SHIFT1,
        dtype=np.int32
    ),

    shift2=np.array(
        SHIFT2,
        dtype=np.int32
    )
)


# ============================================================
# PRINT EXACT INPUT WORDS
#
# One channel, planar 8x8 image.
# Four pixels packed little-endian per 32-bit word.
# ============================================================

input_flat = (
    test_input[
        :,
        :,
        0
    ]
    .reshape(-1)
)


input_words = []


for i in range(
    0,
    64,
    4
):

    word = (
        int(input_flat[i + 0])
        |
        (
            int(input_flat[i + 1])
            << 8
        )
        |
        (
            int(input_flat[i + 2])
            << 16
        )
        |
        (
            int(input_flat[i + 3])
            << 24
        )
    )

    input_words.append(
        word
    )


# ============================================================
# PACK EXPECTED LAYER 0
#
# 3x3x4 = one 32-bit C4 word per output pixel.
# ============================================================

layer1_words = []


for y in range(3):

    for x in range(3):

        word = 0

        for lane in range(4):

            word |= (
                int(
                    expected_layer1[
                        y,
                        x,
                        lane
                    ]
                )
                <<
                (8 * lane)
            )

        layer1_words.append(
            word
        )


# ============================================================
# PACK FINAL 8 SCORES
#
# 8 channels -> two C4 words
# ============================================================

final_words = []


for group in range(2):

    word = 0

    for lane in range(4):

        channel = (
            group * 4
            +
            lane
        )

        word |= (
            int(
                expected_scores[
                    channel
                ]
            )
            <<
            (8 * lane)
        )

    final_words.append(
        word
    )


# ============================================================
# SUMMARY
# ============================================================

total_weights = (
    W1.size
    +
    W2.size
)

nonzero_weights = (
    np.count_nonzero(W1)
    +
    np.count_nonzero(W2)
)


print()
print(
    "=============================================="
)

print(
    "NOVA-1 TRAINED MODEL EXPORTER"
)

print(
    "=============================================="
)

print()

print(
    f"Layer 0 weights : {W1.size}"
)

print(
    f"Layer 1 weights : {W2.size}"
)

print(
    f"Total weights   : {total_weights}"
)

print(
    f"Nonzero weights : {nonzero_weights}"
)

print(
    f"Zero skipped    : "
    f"{total_weights - nonzero_weights}"
)

print()

print(
    f"Layer 0 bias    : {b1.tolist()}"
)

print(
    f"Layer 1 bias    : {b2.tolist()}"
)

print()

print(
    f"Layer 0 shift   : {SHIFT1}"
)

print(
    f"Layer 1 shift   : {SHIFT2}"
)

print()

print(
    f"Instructions    : {len(program)}"
)

print(
    f"ROM capacity    : {ROM_WORDS}"
)

print(
    f"ROM usage       : "
    f"{100.0 * len(program) / ROM_WORDS:.2f}%"
)

print()

print(
    "=============================================="
)

print(
    "RTL DEPLOYMENT SAMPLE"
)

print(
    "=============================================="
)

print(
    f"Dataset index   : {test_index}"
)

print(
    f"Expected class  : {expected_class}"
)

print(
    f"Expected scores : "
    f"{expected_scores.tolist()}"
)

print()

print(
    "INPUT MEMORY"
)

print(
    "----------------------------------------------"
)


for i, word in enumerate(
    input_words
):

    address = (
        0x1000
        +
        i * 4
    )

    print(
        f"0x{address:08X} = "
        f"0x{word:08X}"
    )


print()

print(
    "EXPECTED LAYER 0 MEMORY"
)

print(
    "----------------------------------------------"
)


for i, word in enumerate(
    layer1_words
):

    address = (
        0x4000
        +
        i * 4
    )

    print(
        f"0x{address:08X} = "
        f"0x{word:08X}"
    )


print()

print(
    "EXPECTED FINAL MEMORY"
)

print(
    "----------------------------------------------"
)


for i, word in enumerate(
    final_words
):

    address = (
        0x8000
        +
        i * 4
    )

    print(
        f"0x{address:08X} = "
        f"0x{word:08X}"
    )


print()

print(
    "Generated:"
)

print(
    "  instruction_memory.sv"
)

print(
    "  nova1_trained_program_listing.txt"
)

print(
    "  nova1_rtl_vectors.npz"
)

print()

print(
    "=============================================="
)

print(
    "TRAINED MODEL EXPORT COMPLETE"
)

print(
    "=============================================="
)
