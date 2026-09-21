import numpy as np

# ============================================================
# NOVA-1 TINY CNN TRAINER
#
# Architecture:
#
# 8x8x1
#   -> Conv3x3, Cout=4, stride=2
#   -> ReLU
#   -> 3x3x4
#   -> Conv3x3, Cout=8, stride=1
#   -> 1x1x8 logits
#   -> Softmax
#
# ============================================================

np.random.seed(42)

EPOCHS = 40
BATCH_SIZE = 32
LEARNING_RATE = 0.01
NUM_CLASSES = 8


# ============================================================
# LOAD DATASET
# ============================================================

data = np.load("nova1_tiny_dataset.npz")

train_images = data["train_images"]
train_labels = data["train_labels"]

test_images = data["test_images"]
test_labels = data["test_labels"]


# Add channel dimension:
#
# (N,8,8) -> (N,8,8,1)

train_images = train_images[..., None]
test_images = test_images[..., None]


print()
print("==============================================")
print("NOVA-1 TINY CNN TRAINING")
print("==============================================")

print("Train:", train_images.shape)
print("Test :", test_images.shape)


# ============================================================
# INITIALIZE WEIGHTS
#
# Hardware-compatible layout:
#
# W1 = [filter][channel][ky][kx]
# W2 = [filter][channel][ky][kx]
# ============================================================

W1 = (
    np.random.randn(4, 1, 3, 3).astype(np.float32)
    * np.sqrt(2.0 / 9.0)
)

b1 = np.zeros(
    4,
    dtype=np.float32
)


W2 = (
    np.random.randn(8, 4, 3, 3).astype(np.float32)
    * np.sqrt(2.0 / 36.0)
)

b2 = np.zeros(
    8,
    dtype=np.float32
)


# ============================================================
# CONVOLUTION FORWARD
# ============================================================

def conv_forward(x, W, b, stride):

    N, H, WW, Cin = x.shape

    Cout = W.shape[0]

    OH = ((H - 3) // stride) + 1
    OW = ((WW - 3) // stride) + 1

    out = np.zeros(
        (N, OH, OW, Cout),
        dtype=np.float32
    )

    for n in range(N):

        for oy in range(OH):

            for ox in range(OW):

                iy = oy * stride
                ix = ox * stride

                patch = x[
                    n,
                    iy:iy+3,
                    ix:ix+3,
                    :
                ]

                # patch:
                # [3,3,Cin]

                for f in range(Cout):

                    # Hardware W layout:
                    # [filter, channel, ky, kx]
                    #
                    # Convert to [ky,kx,channel]

                    kernel = np.transpose(
                        W[f],
                        (1, 2, 0)
                    )

                    out[n, oy, ox, f] = (
                        np.sum(
                            patch * kernel
                        )
                        + b[f]
                    )

    return out


# ============================================================
# CONVOLUTION BACKWARD
# ============================================================

def conv_backward(
    x,
    W,
    dout,
    stride
):

    N, H, WW, Cin = x.shape

    Cout = W.shape[0]

    OH = dout.shape[1]
    OW = dout.shape[2]

    dx = np.zeros_like(x)

    dW = np.zeros_like(W)

    db = np.zeros(
        Cout,
        dtype=np.float32
    )


    for n in range(N):

        for oy in range(OH):

            for ox in range(OW):

                iy = oy * stride
                ix = ox * stride

                patch = x[
                    n,
                    iy:iy+3,
                    ix:ix+3,
                    :
                ]


                for f in range(Cout):

                    grad = dout[
                        n,
                        oy,
                        ox,
                        f
                    ]


                    db[f] += grad


                    # Weight gradient

                    for c in range(Cin):

                        dW[f, c] += (
                            patch[:, :, c]
                            * grad
                        )


                    # Input gradient

                    kernel = np.transpose(
                        W[f],
                        (1, 2, 0)
                    )

                    dx[
                        n,
                        iy:iy+3,
                        ix:ix+3,
                        :
                    ] += (
                        kernel * grad
                    )


    return dx, dW, db


# ============================================================
# FORWARD NETWORK
# ============================================================

def forward(x):

    z1 = conv_forward(
        x,
        W1,
        b1,
        stride=2
    )

    a1 = np.maximum(
        z1,
        0
    )

    z2 = conv_forward(
        a1,
        W2,
        b2,
        stride=1
    )

    # z2 shape:
    #
    # [N,1,1,8]

    logits = z2[:, 0, 0, :]

    return (
        z1,
        a1,
        z2,
        logits
    )


# ============================================================
# SOFTMAX
# ============================================================

def softmax(logits):

    shifted = (
        logits
        -
        np.max(
            logits,
            axis=1,
            keepdims=True
        )
    )

    exp_values = np.exp(
        shifted
    )

    return (
        exp_values
        /
        np.sum(
            exp_values,
            axis=1,
            keepdims=True
        )
    )


# ============================================================
# ACCURACY
# ============================================================

def accuracy(images, labels):

    _, _, _, logits = forward(
        images
    )

    predictions = np.argmax(
        logits,
        axis=1
    )

    return np.mean(
        predictions == labels
    )


# ============================================================
# TRAINING
# ============================================================

num_train = len(
    train_images
)


for epoch in range(EPOCHS):

    indices = np.random.permutation(
        num_train
    )

    epoch_loss = 0.0
    batches = 0


    for start in range(
        0,
        num_train,
        BATCH_SIZE
    ):

        batch_indices = indices[
            start:start+BATCH_SIZE
        ]

        x = train_images[
            batch_indices
        ]

        y = train_labels[
            batch_indices
        ]


        # ----------------------------------------------------
        # FORWARD
        # ----------------------------------------------------

        z1 = conv_forward(
            x,
            W1,
            b1,
            stride=2
        )

        a1 = np.maximum(
            z1,
            0
        )

        z2 = conv_forward(
            a1,
            W2,
            b2,
            stride=1
        )

        logits = z2[
            :,
            0,
            0,
            :
        ]


        probabilities = softmax(
            logits
        )


        # ----------------------------------------------------
        # LOSS
        # ----------------------------------------------------

        batch_n = len(x)

        loss = -np.mean(
            np.log(
                probabilities[
                    np.arange(batch_n),
                    y
                ]
                + 1e-12
            )
        )

        epoch_loss += loss

        batches += 1


        # ----------------------------------------------------
        # SOFTMAX GRADIENT
        # ----------------------------------------------------

        dlogits = probabilities.copy()

        dlogits[
            np.arange(batch_n),
            y
        ] -= 1.0

        dlogits /= batch_n


        dz2 = np.zeros_like(
            z2
        )

        dz2[
            :,
            0,
            0,
            :
        ] = dlogits


        # ----------------------------------------------------
        # LAYER 2 BACKWARD
        # ----------------------------------------------------

        da1, dW2, db2 = conv_backward(
            a1,
            W2,
            dz2,
            stride=1
        )


        # ----------------------------------------------------
        # RELU BACKWARD
        # ----------------------------------------------------

        dz1 = (
            da1
            *
            (z1 > 0)
        )


        # ----------------------------------------------------
        # LAYER 1 BACKWARD
        # ----------------------------------------------------

        _, dW1, db1 = conv_backward(
            x,
            W1,
            dz1,
            stride=2
        )


        # ----------------------------------------------------
        # GRADIENT CLIPPING
        # ----------------------------------------------------

        np.clip(
            dW1,
            -5,
            5,
            out=dW1
        )

        np.clip(
            dW2,
            -5,
            5,
            out=dW2
        )

        np.clip(
            db1,
            -5,
            5,
            out=db1
        )

        np.clip(
            db2,
            -5,
            5,
            out=db2
        )


        # ----------------------------------------------------
        # SGD UPDATE
        # ----------------------------------------------------

        W1 -= (
            LEARNING_RATE
            * dW1
        )

        b1 -= (
            LEARNING_RATE
            * db1
        )

        W2 -= (
            LEARNING_RATE
            * dW2
        )

        b2 -= (
            LEARNING_RATE
            * db2
        )


    # ========================================================
    # EPOCH RESULTS
    # ========================================================

    train_acc = accuracy(
        train_images,
        train_labels
    )

    test_acc = accuracy(
        test_images,
        test_labels
    )


    print(
        f"Epoch {epoch+1:02d}/{EPOCHS} "
        f"| Loss {epoch_loss/batches:.4f} "
        f"| Train {train_acc*100:.2f}% "
        f"| Test {test_acc*100:.2f}%"
    )


# ============================================================
# FINAL TEST
# ============================================================

final_accuracy = accuracy(
    test_images,
    test_labels
)


print()
print("==============================================")
print("TRAINING COMPLETE")
print("==============================================")

print(
    f"Final test accuracy : "
    f"{final_accuracy*100:.2f}%"
)


# ============================================================
# SAVE FLOAT MODEL
# ============================================================

np.savez(
    "nova1_tinycnn_float.npz",

    W1=W1,
    b1=b1,

    W2=W2,
    b2=b2
)


print()
print(
    "Saved:"
)

print(
    "  nova1_tinycnn_float.npz"
)


# ============================================================
# DISPLAY A FEW PREDICTIONS
# ============================================================

_, _, _, logits = forward(
    test_images[:16]
)

predictions = np.argmax(
    logits,
    axis=1
)


print()
print(
    "Sample predictions:"
)

for i in range(16):

    print(
        f"Sample {i:02d}: "
        f"true={test_labels[i]} "
        f"pred={predictions[i]}"
    )


print(
    "=============================================="
)
