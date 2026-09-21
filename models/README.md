# Trained model artifacts

- `nova1_tinycnn_float.npz`: supplied floating-point checkpoint.
- `nova1_tinycnn_int8.npz`: supplied integer weights, biases, shifts, selected input, and expected outputs.

The network has 324 weights (323 nonzero), 12 biases, and shifts 10 and 6. Reference vectors are in `../results/trained_cnn/nova1_rtl_vectors.npz`; the dataset is in `../data/nova1_tiny_dataset.npz`. Load with NumPy using `allow_pickle=False`.

Software uses HWC activation arrays and OIHW weight arrays. Hardware input storage is planar CHW where applicable; output feature maps use C4 packing. Preserve these distinctions when extending to multiple input channels.

The quantizer calibrates using test images in the supplied implementation. A separate calibration split is future verification work. Model hashes are recorded in `../docs/source-manifest.json`.
