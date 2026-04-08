# AlphaFold 2 ARM64 Release - v2.3.2-arm64

## 🎉 Release Highlights

**First official ARM64 (aarch64) build of AlphaFold 2.3.2**

This release enables AlphaFold 2 to run on ARM-based systems with NVIDIA GPUs, including:
- AWS Graviton instances
- NVIDIA DGX A100/H100 (ARM variant)
- Linux ARM64 workstations

## 📋 Changes

### Modified Files

- **docker/Dockerfile** - ARM64 optimized build
  - Base image: `nvidia/cuda:12.8.0-cudnn-devel-ubuntu24.04`
  - Miniforge ARM64 (open-source alternative to Miniconda)
  - Python 3.12
  - TensorFlow 2.21.0
  - HH-suite ARM64 prebuilt binary
  - JAX CUDA 12 support

- **requirements.txt** - ARM64 compatible dependencies
  - Simplified dependencies list
  - Removed CPU-specific variants
  - Added missing packages (chex, immutabledict, pandas, scipy)

- **README_arm64.md** - ARM64 build documentation
  - Complete build guide for ARM64 systems
  - Troubleshooting section
  - GitHub release checklist

## 🔧 Technical Details

### Base Image
```
FROM nvidia/cuda:12.8.0-cudnn-devel-ubuntu24.04
```

### Key Packages
- **Python**: 3.12 (via Miniforge ARM64)
- **TensorFlow**: 2.21.0
- **OpenMM**: 8.5.0
- **JAX**: CUDA 12 release
- **HH-suite**: Prebuilt ARM64 binary from dev.mmseqs.com

### System Requirements
- **Architecture**: ARM64 (aarch64)
- **GPU**: NVIDIA GPU with CUDA 12.8+ support
- **Memory**: 32GB+ RAM recommended
- **Storage**: 3TB+ SSD for databases

## 📦 Installation

### Build from Source

```bash
# Clone repository
git clone https://github.com/deepmind/alphafold.git
cd alphafold

# Build ARM64 image
docker build -f docker/Dockerfile -t alphafold:arm64-v2.3.2 .
```

### Download Databases

```bash
# Full database (~556 GB download, 2.62 TB)
./scripts/download_all_data.sh /path/to/database

# Reduced database (for testing)
./scripts/download_all_data.sh /path/to/database reduced_dbs
```

### Run AlphaFold

```bash
docker run --rm -it \
  --gpus all \
  -v /path/to/database:/database \
  -v /path/to/output:/output \
  alphafold:arm64-v2.3.2 \
  --fasta_paths=/database/test.fasta \
  --max_template_date=2022-01-01 \
  --model_preset=monomer \
  --db_preset=reduced_dbs \
  --data_dir=/database \
  --output_dir=/output
```

## ✅ Verification

Run these checks to verify the build:

```bash
# 1. Check GPU access
docker run --rm --gpus all alphafold:arm64 nvidia-smi

# 2. Check TensorFlow
docker run --rm alphafold:arm64 python -c "import tensorflow as tf; print(tf.__version__)"

# 3. Check JAX
docker run --rm alphafold:arm64 python -c "import jax; print(jax.devices())"

# 4. Check HH-suite
docker run --rm alphafold:arm64 hhblits -version
```

## 🐛 Known Issues

1. **JAX CUDA compatibility**: If JAX fails to detect GPU, ensure CUDA 12.8 is properly installed in the base image.

2. **Memory constraints**: Large proteins may require 64GB+ RAM. Consider using `--max_template_date` to limit MSA search.

3. **Build time**: ARM64 builds take ~40-60 minutes (vs 30-40 minutes on x86_64).

## 📚 Documentation

- [ARM64 Build Guide](README_arm64.md) - Complete build and troubleshooting guide
- [AlphaFold Official Docs](https://github.com/deepmind/alphafold)
- [Technical Note v2.3.0](docs/technical_note_v2.3.0.md)

## 🙏 Credits

- Original AlphaFold by DeepMind
- ARM64 adaptation by Jack W ang
- NVIDIA for GPU support
- Conda-forge for Miniforge

## 📄 License

AlphaFold code: Apache 2.0  
AlphaFold parameters: CC BY 4.0

---

**Release Date**: 2026-04-08  
**Version**: v2.3.2-arm64  
**Author**: Jack W ang  
**Status**: ✅ Tested on Linux arm64 with NVIDIA GB10
