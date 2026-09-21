import numpy as np

# ============================================================
# NOVA-1 TRAINED MODEL -> INT8 QUANTIZATION
#
# Converts the trained floating-point CNN into integer
# parameters suitable for NOVA-1 and performs integer-only
# inference using NOVA-1-style arithmetic.
#
# Network:
#
# 8x8x1
#   -> Conv3x3, Cout=4, stride=2
#   -> ReLU + quantization
# 3x3x4
#   -> Conv3x3, Cout=8, stride=1
#   -> ReLU + quantization
# 1x1x8
#
# ============================================================

np.set_printoptions(
    linewidth=160,
    suppress=True
)

# ============================================================
# LOAD DATA
# ============================================================

dataset = np.load(
    "nova1_tiny_dataset.npz"
)

model = np.load(
    "nova1_tinycnn_float.npz"
)

test_images = dataset["test_images"]
test_labels = dataset["test_labels"]

W1 = model["W1"]
b1 = model["b1"]

W2 = model["W2"]
b2 = model["b2"]


# ============================================================
# QUANTIZATION CONFIGURATION
#
# Input:
# float [0,1] -> uint8-ish integer [0,127]
#
# Weight scale:
# independently chosen for each layer.
#
# We then determine a power-of-two output shift so the
# accelerator can use arithmetic right shift.
# ============================================================

INPUT_SCALE = 127.0


def quantize_weights(W):

    max_abs = np.max(
        np.abs(W)
    )

    if max_abs == 0:
        scale = 1.0
    else:
        scale = 127.0 / max_abs

    Wq = np.round(
        W * scale
    )

    Wq = np.clip(
        Wq,
        -127,
        127
    ).astype(np.int8)

    return Wq, scale


W1_q, W1_scale = quantize_weights(W1)
W2_q, W2_scale = quantize_weights(W2)


# ============================================================
# FLOAT REFERENCE CONV
# ============================================================

def float_conv(
    x,
    W,
    b,
    stride
):

    H, WW, Cin = x.shape

    Cout = W.shape[0]

    OH = ((H - 3) // stride) + 1
    OW = ((WW - 3) // stride) + 1

    out = np.zeros(
        (OH, OW, Cout),
        dtype=np.float32
    )

    for oy in range(OH):

        for ox in range(OW):

            iy = oy * stride
            ix = ox * stride

            for f in range(Cout):

                acc = b[f]

                for c in range(Cin):

                    for ky in range(3):

                        for kx in range(3):

                            acc += (
                                x[
                                    iy + ky,
                                    ix + kx,
                                    c
                                ]
                                *
                                W[
                                    f,
                                    c,
                                    ky,
                                    kx
                                ]
                            )

                out[
                    oy,
                    ox,
                    f
                ] = acc

    return out


# ============================================================
# CALIBRATION
#
# First estimate layer-1 accumulator range.
# ============================================================

CALIBRATION_SAMPLES = min(
    300,
    len(test_images)
)


def quantize_input(image):

    x = np.round(
        image * INPUT_SCALE
    )

    return np.clip(
        x,
        0,
        127
    ).astype(np.int32)


# Bias integer scale for layer 1:
#
# accumulator scale =
#
# INPUT_SCALE * W1_scale

b1_q = np.round(
    b1
    *
    INPUT_SCALE
    *
    W1_scale
).astype(np.int32)


# ============================================================
# RAW INTEGER CONVOLUTION
# ============================================================

def int_conv_raw(
    x,
    W,
    b,
    stride
):

    H, WW, Cin = x.shape

    Cout = W.shape[0]

    OH = ((H - 3) // stride) + 1
    OW = ((WW - 3) // stride) + 1

    out = np.zeros(
        (OH, OW, Cout),
        dtype=np.int64
    )

    for oy in range(OH):

        for ox in range(OW):

            iy = oy * stride
            ix = ox * stride

            for f in range(Cout):

                acc = int(
                    b[f]
                )

                for c in range(Cin):

                    for ky in range(3):

                        for kx in range(3):

                            acc += (
                                int(
                                    x[
                                        iy + ky,
                                        ix + kx,
                                        c
                                    ]
                                )
                                *
                                int(
                                    W[
                                        f,
                                        c,
                                        ky,
                                        kx
                                    ]
                                )
                            )

                out[
                    oy,
                    ox,
                    f
                ] = acc

    return out


# ============================================================
# FIND POWER-OF-TWO SHIFT
# ============================================================

def choose_shift(
    max_value
):

    shift = 0

    while (
        (max_value >> shift)
        > 127
    ):

        shift += 1

    return shift


# ============================================================
# CALIBRATE LAYER 1
# ============================================================

max_acc1 = 0


for i in range(
    CALIBRATION_SAMPLES
):

    xq = quantize_input(
        test_images[i][..., None]
    )

    raw = int_conv_raw(
        xq,
        W1_q,
        b1_q,
        stride=2
    )

    raw = np.maximum(
        raw,
        0
    )

    max_acc1 = max(
        max_acc1,
        int(
            np.max(raw)
        )
    )


SHIFT1 = choose_shift(
    max_acc1
)


# ============================================================
# NOVA-1 ACTIVATION QUANTIZATION
# ============================================================

def requant_relu(
    raw,
    shift
):

    # ReLU

    raw = np.maximum(
        raw,
        0
    )

    # Power-of-two quantization

    raw = raw >> shift

    # NOVA-1 signed INT8 positive range

    raw = np.clip(
        raw,
        0,
        127
    )

    return raw.astype(
        np.int32
    )


# ============================================================
# LAYER 2 BIAS
#
# Layer-1 integer activation represents:
#
# real_activation approximately
#
# int_activation *
# 2^SHIFT1 /
# (INPUT_SCALE * W1_scale)
#
# Therefore layer-2 accumulator scaling is:
#
# W2_scale *
# INPUT_SCALE *
# W1_scale /
# 2^SHIFT1
# ============================================================

LAYER1_REAL_SCALE = (
    INPUT_SCALE
    *
    W1_scale
    /
    (2 ** SHIFT1)
)


b2_q = np.round(
    b2
    *
    LAYER1_REAL_SCALE
    *
    W2_scale
).astype(np.int32)


# ============================================================
# CALIBRATE LAYER 2
# ============================================================

max_acc2 = 0


for i in range(
    CALIBRATION_SAMPLES
):

    xq = quantize_input(
        test_images[i][..., None]
    )

    raw1 = int_conv_raw(
        xq,
        W1_q,
        b1_q,
        stride=2
    )

    a1 = requant_relu(
        raw1,
        SHIFT1
    )

    raw2 = int_conv_raw(
        a1,
        W2_q,
        b2_q,
        stride=1
    )

    raw2 = np.maximum(
        raw2,
        0
    )

    max_acc2 = max(
        max_acc2,
        int(
            np.max(raw2)
        )
    )


SHIFT2 = choose_shift(
    max_acc2
)


# ============================================================
# INTEGER NOVA-1 INFERENCE
# ============================================================

def nova1_inference(
    image
):

    xq = quantize_input(
        image[..., None]
    )


    # Layer 0

    raw1 = int_conv_raw(
        xq,
        W1_q,
        b1_q,
        stride=2
    )

    a1 = requant_relu(
        raw1,
        SHIFT1
    )


    # Layer 1

    raw2 = int_conv_raw(
        a1,
        W2_q,
        b2_q,
        stride=1
    )

    a2 = requant_relu(
        raw2,
        SHIFT2
    )


    scores = a2[
        0,
        0,
        :
    ]

    prediction = int(
        np.argmax(scores)
    )

    return (
        prediction,
        scores,
        xq,
        a1,
        raw1,
        raw2
    )


# ============================================================
# FLOAT INFERENCE
# ============================================================

def float_inference(
    image
):

    x = image[..., None]

    z1 = float_conv(
        x,
        W1,
        b1,
        stride=2
    )

    a1 = np.maximum(
        z1,
        0
    )

    z2 = float_conv(
        a1,
        W2,
        b2,
        stride=1
    )

    scores = z2[
        0,
        0,
        :
    ]

    return int(
        np.argmax(scores)
    )


# ============================================================
# EVALUATE
# ============================================================

float_correct = 0
int_correct = 0
agreement = 0


for i in range(
    len(test_images)
):

    fp = float_inference(
        test_images[i]
    )

    qp, _, _, _, _, _ = (
        nova1_inference(
            test_images[i]
        )
    )

    if fp == test_labels[i]:
        float_correct += 1

    if qp == test_labels[i]:
        int_correct += 1

    if fp == qp:
        agreement += 1


float_accuracy = (
    float_correct
    /
    len(test_images)
)

int_accuracy = (
    int_correct
    /
    len(test_images)
)

agreement_rate = (
    agreement
    /
    len(test_images)
)


# ============================================================
# PRINT QUANTIZATION INFORMATION
# ============================================================

print()
print(
    "=============================================="
)

print(
    "NOVA-1 INT8 QUANTIZATION"
)

print(
    "=============================================="
)

print()

print(
    f"W1 scale     : {W1_scale:.6f}"
)

print(
    f"W2 scale     : {W2_scale:.6f}"
)

print()

print(
    f"Layer 1 max accumulator : {max_acc1}"
)

print(
    f"Layer 1 quant shift     : {SHIFT1}"
)

print()

print(
    f"Layer 2 max accumulator : {max_acc2}"
)

print(
    f"Layer 2 quant shift     : {SHIFT2}"
)

print()

print(
    "Bias layer 1:"
)

print(
    b1_q
)

print()

print(
    "Bias layer 2:"
)

print(
    b2_q
)

print()

print(
    "=============================================="
)

print(
    "ACCURACY"
)

print(
    "=============================================="
)

print(
    f"Float accuracy       : "
    f"{float_accuracy*100:.2f}%"
)

print(
    f"INT8 accuracy        : "
    f"{int_accuracy*100:.2f}%"
)

print(
    f"Float/INT8 agreement : "
    f"{agreement_rate*100:.2f}%"
)


# ============================================================
# SELECT A CORRECT TEST VECTOR FOR RTL
# ============================================================

selected = None


for i in range(
    len(test_images)
):

    fp = float_inference(
        test_images[i]
    )

    qp, scores, xq, a1, raw1, raw2 = (
        nova1_inference(
            test_images[i]
        )
    )

    if (
        fp == test_labels[i]
        and
        qp == test_labels[i]
    ):

        selected = i
        break


if selected is None:

    raise RuntimeError(
        "No mutually correct test vector found."
    )


prediction, scores, xq, a1, raw1, raw2 = (
    nova1_inference(
        test_images[selected]
    )
)


print()
print(
    "=============================================="
)

print(
    "RTL DEPLOYMENT VECTOR"
)

print(
    "=============================================="
)

print(
    f"Test sample     : {selected}"
)

print(
    f"True class      : {test_labels[selected]}"
)

print(
    f"INT8 prediction : {prediction}"
)

print()

print(
    "Final 8 class scores:"
)

print(
    scores
)

print()

print(
    "Quantized input image:"
)

print(
    xq[:, :, 0]
)

print()

print(
    "Layer-1 integer output:"
)

print(
    a1
)


# ============================================================
# SAVE QUANTIZED MODEL
# ============================================================

np.savez(
    "nova1_tinycnn_int8.npz",

    W1=W1_q,
    b1=b1_q,

    W2=W2_q,
    b2=b2_q,

    shift1=np.array(
        SHIFT1,
        dtype=np.int32
    ),

    shift2=np.array(
        SHIFT2,
        dtype=np.int32
    ),

    input_scale=np.array(
        INPUT_SCALE,
        dtype=np.float32
    ),

    test_index=np.array(
        selected,
        dtype=np.int32
    ),

    test_input=xq.astype(
        np.uint8
    ),

    expected_layer1=a1.astype(
        np.uint8
    ),

    expected_scores=scores.astype(
        np.uint8
    ),

    expected_class=np.array(
        prediction,
        dtype=np.int32
    )
)


print()
print(
    "Generated:"
)

print(
    "  nova1_tinycnn_int8.npz"
)

print()

print(
    "=============================================="
)

print(
    "QUANTIZATION COMPLETE"
)

print(
    "=============================================="
)
