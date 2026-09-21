"""Reproduce supplied artifacts without modifying original scripts, models or RTL."""
from pathlib import Path
import shutil
import subprocess
import sys
import numpy as np

root = Path(__file__).resolve().parents[2]
work = root / 'build' / 'reproduce'
work.mkdir(parents=True, exist_ok=True)
for relative in ['data/nova1_tiny_dataset.npz', 'models/nova1_tinycnn_float.npz']:
    shutil.copyfile(root / relative, work / Path(relative).name)
for relative in ['software/quantization/nova1_quantize_model.py',
                 'software/deployment/nova1_trained_model_exporter.py']:
    subprocess.run([sys.executable, str(root / relative)], cwd=work, check=True)
for relative in ['models/nova1_tinycnn_int8.npz', 'results/trained_cnn/nova1_rtl_vectors.npz']:
    with np.load(root / relative, allow_pickle=False) as expected, np.load(work / Path(relative).name, allow_pickle=False) as actual:
        if set(expected.files) != set(actual.files):
            raise RuntimeError(f'Array keys differ: {relative}')
        for key in expected.files:
            if not np.array_equal(expected[key], actual[key]):
                raise RuntimeError(f'Array differs: {relative}:{key}')
for relative in ['rtl/memory/instruction_memory.sv', 'software/deployment/nova1_trained_program_listing.txt']:
    if (root / relative).read_text() != (work / Path(relative).name).read_text():
        raise RuntimeError(f'Text differs: {relative}')
print('PASS: Python quantization and export reproduce supplied model, vectors, ROM and listing.')
print('RTL simulation was not run by this checker.')
