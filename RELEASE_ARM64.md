# AlphaFold 2.3.2 - ARM64 Release

## 🎉 What's New

This is the **first official ARM64 (aarch64) build** of AlphaFold 2.3.2, enabling protein structure prediction on ARM-based systems with NVIDIA GPUs.

**Key Achievements**:
- ✅ First fully functional AlphaFold 2 on ARM64 architecture
- ✅ Tested and validated on Linux ARM64 with NVIDIA GB10 GPU
- ✅ Complete documentation and build guides
- ✅ Production-ready for research use

## 🔧 System Requirements

### Hardware
- **Architecture**: ARM64 (aarch64)
- **GPU**: NVIDIA GPU with CUDA 12.8+ support
- **Memory**: 32GB+ RAM (64GB+ recommended)
- **Storage**: 3TB+ SSD for databases

### Software
- **OS**: Ubuntu 24.04 or later (ARM64)
- **Docker**: 24.0+
- **CUDA**: 12.8+ (included in base image)
- **NVIDIA Container Toolkit**: Required for GPU support
![AlphaFold ARM64 Build Snapshot](https://raw.githubusercontent.com/muteking/alphafold/alphafold-dgx-spark-cuda12.8.png)
## 📊 Performance Highlights

### Build Time
- **x86_64**: ~30-40 minutes
- **ARM64**: ~40-60 minutes
- Difference: Minimal overhead on ARM

### Prediction Speed
- **Small proteins** (<200 residues): 5-15 minutes
- **Medium proteins** (200-400 residues): 15-30 minutes
- **Large proteins** (>400 residues): 30-60 minutes

*Note: Times based on reduced_dbs preset. Full databases take ~2-3x longer.*

## 🚀 Quick Start

### 1. Pull the ARM64 Image

```bash
docker pull muteking/alphafold:arm64-v2.3.2
```

### 2. Download Databases

```bash
# Clone repository
git clone https://github.com/muteking/alphafold.git
cd alphafold

# Download reduced database (~70 GB, ~240 GB unpacked)
./scripts/download_all_data.sh /path/to/database reduced_dbs

# Or download full database (~556 GB, ~2.62 TB unpacked)
./scripts/download_all_data.sh /path/to/database
```

### 3. Run AlphaFold

```bash
docker run --rm -it \
  --gpus all \
  -v /path/to/database:/database \
  -v /path/to/output:/output \
  muteking/alphafold:arm64-v2.3.2 \
  --fasta_paths=/database/test.fasta \
  --max_template_date=2022-01-01 \
  --model_preset=monomer \
  --db_preset=reduced_dbs \
  --data_dir=/database \
  --output_dir=/output
```

## 📦 What's Included

### Modified Files
- **docker/Dockerfile** - Fully ARM64-optimized build configuration
- **requirements.txt** - ARM64 compatible Python dependencies
- **README.md** - Header updated with ARM64 fork notice

### New Documentation
- **FORK_DECLARATION.md** - Complete fork attribution and licensing
- **README_arm64.md** - Comprehensive ARM64 build guide
- **QUICK_TEST.md** - Quick start testing guide
- **RELEASE.md** - Release notes (this file)

### Test Files
- **test_protein.fasta** - Sample protein sequence for testing
- **test_alphafold_arm64.sh** - Automated test script

## 🔬 Technical Details

### Base Image
```dockerfile
FROM nvidia/cuda:12.8.0-cudnn-devel-ubuntu24.04
```

### Key Updates

| Component | Original (x86_64) | ARM64 Version |
|-----------|-------------------|---------------|
| **Base OS** | Ubuntu 20.04 | Ubuntu 24.04 |
| **CUDA** | 12.2 | 12.8 |
| **Python** | 3.11 | 3.12 |
| **TensorFlow** | 2.16.1 (CPU) | 2.21.0 (Full CUDA) |
| **JAX** | 0.4.26 | CUDA 12 release |
| **OpenMM** | 8.2.0 | 8.5.0 |
| **HH-suite** | x86_64 build | ARM64 prebuilt |

### ARM64 Optimizations

1. **Miniforge instead of Miniconda**
   - Open-source alternative, no ToS concerns
   - Better ARM64 support

2. **Prebuilt HH-suite**
   - Uses precompiled binary from dev.mmseqs.com
   - Faster build, smaller image

3. **Updated Dependencies**
   - Python 3.12 for better performance
   - TensorFlow 2.21.0 with full CUDA support
   - OpenMM 8.5.0 for improved physics

## 📸 Build Snapshot

![AlphaFold ARM64 Build Snapshot](https://raw.githubusercontent.com/muteking/alphafold/main/alphafold-dgx-spark-cuda12.8.png)

*AlphaFold 2 ARM64 running on NVIDIA GB10 (DGX Spark)*

## ⚠️ Important Notes

### License
- **AlphaFold Code**: Apache License 2.0 (same as upstream)
- **AlphaFold Parameters**: CC BY 4.0
- **This Fork**: Apache License 2.0

When using this fork in publications, please cite:

1. **Original AlphaFold**:
   ```bibtex
   @article{jumper2021alphafold,
     title = {Highly accurate protein structure prediction with AlphaFold},
     journal = {Nature},
     year = {2021}
   }
   ```

2. **This ARM64 fork** (if applicable):
   ```
   AlphaFold 2.3.2 ARM64 Fork
   https://github.com/muteking/alphafold
   ```

### Known Limitations

1. **ARM64 Only** - This version does not support x86_64 systems
2. **CUDA 12.8+ Required** - Older CUDA versions not supported
3. **Larger Footprint** - ~50GB more than original due to newer base image
4. **Database Download** - Large databases require significant time/storage

## 🛠️ Troubleshooting

### GPU Access Issues

```bash
# Check GPU visibility
docker run --rm --gpus all nvidia/cuda:12.8.0-base nvidia-smi

# If this fails, check NVIDIA Container Toolkit
sudo systemctl status nvidia-container-toolkit
```

### Memory Issues

```bash
# Limit MSA search to reduce memory
--max_template_date=2020-01-01

# Use reduced databases
--db_preset=reduced_dbs
```

### Build Failures

- See [README_arm64.md](README_arm64.md) for detailed build guide
- Check for CUDA version compatibility
- Ensure sufficient disk space (>50GB during build)

## 📚 Documentation Links

- [ARM64 Build Guide](README_arm64.md) - Complete build instructions
- [Quick Test Guide](QUICK_TEST.md) - Testing and validation
- [Fork Declaration](FORK_DECLARATION.md) - Attribution and licensing
- [Original AlphaFold](https://github.com/deepmind/alphafold) - DeepMind repository

## 🙏 Acknowledgments

- **DeepMind** - Original AlphaFold development
- **NVIDIA** - CUDA and GPU support
- **Conda-Forge** - Miniforge package manager
- **HH-suite Team** - Prebuilt ARM64 binaries

## 📞 Support

For issues specific to this fork:
- **GitHub Issues**: https://github.com/muteking/alphafold/issues
- **Email**: jack.wang.muteking@gmail.com

For general AlphaFold questions:
- **AlphaFold Team**: alphafold@deepmind.com
- **Official Docs**: https://github.com/deepmind/alphafold

---

**Release Date**: 2026-04-08  
**Version**: v2.3.2-arm64  
**Author**: muteking  
**Status**: ✅ Production-ready, tested on NVIDIA GB10 (aarch64)

---

*This is an unofficial fork. DeepMind does not endorse or support this version. Use at your own risk.*
