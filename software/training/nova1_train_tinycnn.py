import numpy as np

# ============================================================
# NOVA-1 TINY CNN TRAINING DATASET GENERATOR
# Stage 1: Generate a real 8-class vision dataset
# ============================================================

np.random.seed(42)

H = 8
W = 8
NUM_CLASSES = 8

SAMPLES_PER_CLASS = 500


def make_pattern(class_id):

    img = np.zeros((H, W), dtype=np.float32)

    # Small random position variation
    shift_x = np.random.randint(-1, 2)
    shift_y = np.random.randint(-1, 2)

    def put(y, x, value=1.0):

        y += shift_y
        x += shift_x

        if 0 <= y < H and 0 <= x < W:
            img[y, x] = value

    # --------------------------------------------------------
    # Class 0: vertical line
    # --------------------------------------------------------

    if class_id == 0:

        for y in range(1, 7):
            put(y, 3)


    # --------------------------------------------------------
    # Class 1: horizontal line
    # --------------------------------------------------------

    elif class_id == 1:

        for x in range(1, 7):
            put(3, x)


    # --------------------------------------------------------
    # Class 2: main diagonal
    # --------------------------------------------------------

    elif class_id == 2:

        for i in range(1, 7):
            put(i, i)


    # --------------------------------------------------------
    # Class 3: anti-diagonal
    # --------------------------------------------------------

    elif class_id == 3:

        for i in range(1, 7):
            put(i, 7 - i)


    # --------------------------------------------------------
    # Class 4: plus sign
    # --------------------------------------------------------

    elif class_id == 4:

        for y in range(1, 7):
            put(y, 3)

        for x in range(1, 7):
            put(3, x)


    # --------------------------------------------------------
    # Class 5: X sign
    # --------------------------------------------------------

    elif class_id == 5:

        for i in range(1, 7):

            put(i, i)
            put(i, 7 - i)


    # --------------------------------------------------------
    # Class 6: box
    # --------------------------------------------------------

    elif class_id == 6:

        for x in range(1, 7):

            put(1, x)
            put(6, x)

        for y in range(1, 7):

            put(y, 1)
            put(y, 6)


    # --------------------------------------------------------
    # Class 7: center block
    # --------------------------------------------------------

    elif class_id == 7:

        for y in range(2, 6):
            for x in range(2, 6):

                put(y, x)


    # Random brightness
    brightness = np.random.uniform(
        0.65,
        1.0
    )

    img *= brightness


    # Add noise
    noise = np.random.normal(
        0,
        0.08,
        (H, W)
    )

    img += noise


    img = np.clip(
        img,
        0,
        1
    )

    return img


# ============================================================
# BUILD DATASET
# ============================================================

images = []
labels = []


for class_id in range(NUM_CLASSES):

    for _ in range(SAMPLES_PER_CLASS):

        images.append(
            make_pattern(class_id)
        )

        labels.append(
            class_id
        )


images = np.array(
    images,
    dtype=np.float32
)

labels = np.array(
    labels,
    dtype=np.int64
)


# ============================================================
# SHUFFLE
# ============================================================

indices = np.arange(
    len(images)
)

np.random.shuffle(
    indices
)

images = images[indices]
labels = labels[indices]


# ============================================================
# TRAIN / TEST SPLIT
# ============================================================

split = int(
    0.8 * len(images)
)

train_images = images[:split]
train_labels = labels[:split]

test_images = images[split:]
test_labels = labels[split:]


# ============================================================
# SAVE
# ============================================================

np.savez(
    "nova1_tiny_dataset.npz",

    train_images=train_images,
    train_labels=train_labels,

    test_images=test_images,
    test_labels=test_labels
)


# ============================================================
# INFORMATION
# ============================================================

print()
print(
    "=============================================="
)

print(
    "NOVA-1 TINY VISION DATASET"
)

print(
    "=============================================="
)

print(
    "Image shape          :",
    images.shape
)

print(
    "Training samples     :",
    len(train_images)
)

print(
    "Test samples         :",
    len(test_images)
)

print(
    "Classes              :",
    NUM_CLASSES
)

print()

print(
    "Class 0 : vertical line"
)

print(
    "Class 1 : horizontal line"
)

print(
    "Class 2 : main diagonal"
)

print(
    "Class 3 : anti-diagonal"
)

print(
    "Class 4 : plus"
)

print(
    "Class 5 : X"
)

print(
    "Class 6 : box"
)

print(
    "Class 7 : center block"
)

print()

print(
    "Generated:"
)

print(
    "  nova1_tiny_dataset.npz"
)

print(
    "=============================================="
)
