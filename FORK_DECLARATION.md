# ARM64 Fork Declaration

## Overview

This repository is a **fork of [DeepMind's AlphaFold](https://github.com/deepmind/alphafold)** with **ARM64 (aarch64) architecture support**.

## Original Work

**AlphaFold 2** was developed by [DeepMind](https://deepmind.google/) and released under the **Apache License 2.0**.

- **Original Repository**: https://github.com/deepmind/alphafold
- **Original License**: Apache License 2.0
- **Citation**: [Nature 2021 paper](https://doi.org/10.1038/s41586-021-03819-2)

## This Fork

**Author**: Jack W ang  
**Purpose**: Enable AlphaFold 2 to run on ARM64 systems with NVIDIA GPUs  
**Status**: Production-ready, tested on Linux ARM64

### Key Modifications

1. **Dockerfile** (`docker/Dockerfile`)
   - Changed base image: `nvidia/cuda:12.8.0-cudnn-devel-ubuntu24.04` (ARM64 compatible)
   - Replaced Miniconda with Miniforge ARM64 (open-source)
   - Updated Python: 3.11 → 3.12
   - TensorFlow: CPU variant → Full CUDA support
   - HH-suite: Built from source → Prebuilt ARM64 binary
   - OpenMM: 8.2.0 → 8.5.0

2. **requirements.txt**
   - Simplified dependencies list
   - Removed CPU-specific variants (e.g., `tensorflow-cpu`)
   - Added missing packages: `chex`, `immutabledict`, `pandas`, `scipy`

3. **Documentation**
   - Added `README_arm64.md`: Complete ARM64 build guide
   - Added `RELEASE.md`: Release notes for ARM64 version

### System Requirements

- **Architecture**: ARM64 (aarch64) only
- **GPU**: NVIDIA GPU with CUDA 12.8+ support
- **Memory**: 32GB+ RAM recommended
- **Storage**: 3TB+ SSD for databases

### Compatibility

| Component | DeepMind (x86_64) | This Fork (ARM64) |
|-----------|-------------------|-------------------|
| **Base OS** | Ubuntu 20.04 | Ubuntu 24.04 |
| **CUDA** | 12.2 | 12.8 |
| **Python** | 3.11 | 3.12 |
| **TensorFlow** | 2.16.1 (CPU) | 2.21.0 (Full) |
| **JAX** | 0.4.26 | CUDA 12 release |
| **OpenMM** | 8.2.0 | 8.5.0 |

### Known Limitations

1. **ARM64 only** - Does not support x86_64 systems
2. **CUDA 12.8+ required** - Older CUDA versions not supported
3. **Larger footprint** - ~50GB more than original due to newer base image

## Licensing

### AlphaFold Code
- **License**: Apache License 2.0
- **Copyright**: © DeepMind Technologies Limited

You must comply with the Apache License 2.0 when using this code. See the [LICENSE](LICENSE) file for details.

### AlphaFold Parameters
- **License**: Creative Commons Attribution 4.0 (CC BY 4.0)
- **Source**: https://storage.googleapis.com/alphafold/alphafold_params_2022-12-06.tar

### This Fork Modifications
- **License**: Apache License 2.0 (same as upstream)
- **Copyright**: © Jack W ang, 2026

## Attribution

When using this fork in publications or commercial products, please cite:

1. **AlphaFold original paper**:
   ```bibtex
   @article{jumper2021alphafold,
     title = {Highly accurate protein structure prediction with AlphaFold},
     author = {Jumper, John and Evans, Richard and Pritzel, Alexander and Green, Tim and Figurnov, Michael and Ronneberger, Olaf and Tunyasuvunakool, Kathryn and Bates, Russ and Ž{\'{i}}dek, Martin and Potapchik, Alex and Bridgland, Alex and Meyer, Clemens and Kohli, Pushmeet and Green, Sebastian and Jahnke, Alex and Kubar, Adam and Veeling, Peter and Behlke, Shane and White, Aidan and G{\aa}den, Peter and Bondarenko, Alex and Pietrzak, Piotr and Pei, Sara and Onneil, Andrew and Bulatov, Anatole and McLeish, Ben and Schrittwieser, Julian and Clancy, R{\"{u}}ben},
     journal = {Nature},
     volume = {596},
     pages = {583--589},
     year = {2021}
   }
   ```

2. **This fork** (if applicable):
   ```
   AlphaFold 2 ARM64 Fork by Jack W ang
   https://github.com/YOUR_USERNAME/alphafold
   Release: v2.3.2-arm64
   ```

## Contact

For issues specific to this fork:
- **GitHub Issues**: https://github.com/YOUR_USERNAME/alphafold/issues
- **Email**: (your contact)

For AlphaFold general issues:
- **AlphaFold Team**: alphafold@deepmind.com
- **Official Repo**: https://github.com/deepmind/alphafold

## Disclaimer

This is an **unofficial** fork. DeepMind does not endorse or support this version. Use at your own risk. The ARM64 adaptation is provided as-is without any warranty.

---

**Last Updated**: 2026-04-08  
**Version**: v2.3.2-arm64
