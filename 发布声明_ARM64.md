# AlphaFold 2 Linux arm64 Docker 镜像构建指南

本文档记录在 **Linux arm64** 系统上构建 AlphaFold 2 Docker 镜像的完整流程，适用于 GitHub 发布。

**作者**: Jack Wang  
**系统**: Linux arm64 (aarch64), NVIDIA GB10 GPU  
**构建时间**: 2026-04-08  
**基础镜像**: `nvidia/cuda:12.8.0-cudnn-devel-ubuntu24.04` `nvidia/cuda:13.2.0-cudnn-devel-ubuntu24.04`

---

## 📋 环境要求

### 硬件要求
- **架构**: ARM64 (aarch64)
- **GPU**: NVIDIA GPU (CUDA 12.8 Cuda13.2下编译通过)
- **内存**: 建议 32GB+
- **磁盘**: 至少 3TB SSD (SSD 强烈推荐，用于数据库)

### 软件要求
- **Docker**: 24.0+
- **NVIDIA Container Toolkit**: 已安装并配置
- **磁盘空间**: 构建时需要额外 50GB 临时空间

---

## 🔧 构建步骤

### 1. 克隆 AlphaFold 仓库

```bash
git clone https://github.com/deepmind/alphafold.git
cd alphafold
```

### 2. 准备 Dockerfile

使用 `docker/Dockerfile`，关键修改点：

**ARM64 特定配置**：
- 基础镜像：`nvidia/cuda:12.8.0-cudnn-devel-ubuntu24.04` `nvidia/cuda:13.2.0-cudnn-devel-ubuntu24.04`
- Miniforge ARM64 版本：`Miniforge3-Linux-aarch64.sh`
- HH-suite ARM64 预编译包：`hhsuite-linux-arm64.tar.gz`

### 3. 构建镜像

```bash
docker build -f docker/Dockerfile -t alphafold:arm64-v2.3.2 .
```

**构建过程中遇到的问题**：

1. **下载速度问题**：
   - CUDA 基础镜像 (~2.6GB) 下载可能需要 30-50 分钟
   - 建议使用国内镜像源或离线包

2. **OpenMM 安装失败**：
   ```bash
   # 如果 conda install openmm=8.5.0 失败
   # 尝试降级版本
   conda install openmm=8.3.0
   ```

3. **JAX CUDA 安装**：
   ```bash
   # JAX 需要手动指定 CUDA 版本
   pip install "jax[cuda12]" -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html
   ```

### 4. 构建优化技巧

**使用构建缓存**：
```bash
docker build --progress=plain \
  --cache-from alphafold:arm64-v2.3.2 \
  -f docker/Dockerfile \
  -t alphafold:arm64-v2.3.2 \
  .
```

**多阶段构建（可选）**：
```dockerfile
# 阶段 1: 构建依赖
FROM nvidia/cuda:12.8.0-cudnn-devel-ubuntu24.04 AS builder

# 安装依赖...

# 阶段 2: 运行环境
FROM nvidia/cuda:12.8.0-cudnn-runtime-ubuntu24.04
# 复制必要文件...
```

---

## 📦 下载数据库

数据库不在镜像中，需要单独下载：

```bash
# 方法 1: 完整数据库 (~556 GB 下载，2.62 TB 解压后)
./scripts/download_all_data.sh /home/mutek/genedata

# 方法 2: 精简数据库 (适合测试)
./scripts/download_all_data.sh /home/mutek/genedata reduced_dbs
```

**数据库结构**：
```
/home/mutek/genedata/
├── bfd/           # ~1.8 TB
├── mgnify/        # ~120 GB
├── pdb70/         # ~56 GB
├── pdb_mmcif/     # ~238 GB
├── params/        # ~5.3 GB (模型参数)
├── uniref30/      # ~206 GB
├── uniprot/       # ~105 GB
└── uniref90/      # ~67 GB
```

**建议**：
- 使用 `aria2c` 加速下载：`sudo apt install aria2`
- 下载到非 Docker 目录（避免构建上下文过大）
- 确保目录权限：`sudo chmod 755 --recursive /home/mutek/genedata`

---

## 🚀 运行测试

### 测试脚本

```bash
#!/bin/bash
# test_alphafold.sh

DOWNLOAD_DIR="/home/mutek/genedata"
OUTPUT_DIR="/home/mutek/alphafold_output"

# 等待数据库准备完成
echo "等待 BFD 数据库解压完成..."
while true; do
    BFD_SIZE=$(du -sh "$DOWNLOAD_DIR/bfd/" 2>/dev/null | awk '{print $1}')
    echo "BFD 大小：$BFD_SIZE"
    
    if [[ "$BFD_SIZE" == *"T"* ]]; then
        echo "✅ BFD 数据库已就绪！"
        break
    else
        echo "⏳ 等待中..."
        sleep 60
    fi
done

# 运行 AlphaFold
python3 docker/run_docker.py \
    --fasta_paths=/home/mutek/test_protein.fasta \
    --max_template_date=2022-01-01 \
    --model_preset=monomer \
    --db_preset=reduced_dbs \
    --data_dir="$DOWNLOAD_DIR" \
    --output_dir="$OUTPUT_DIR" \
    --num_multimer_predictions_per_model=1
```

### 直接运行命令

```bash
docker run --rm -it \
  --gpus all \
  -v /home/mutek/genedata:/database \
  -v /home/mutek/alphafold_output:/output \
  alphafold:arm64-v2.3.2 \
  --fasta_paths=/database/test.fasta \
  --max_template_date=2022-01-01 \
  --model_preset=monomer \
  --db_preset=reduced_dbs \
  --data_dir=/database \
  --output_dir=/output
```

---

## 🐛 常见问题

### 1. GPU 不可用

```bash
# 检查 GPU 是否可见（根据你实际下载的镜像使用13.2或12.8版本）
docker run --rm --gpus all nvidia/cuda:13.2.0-cudnn-runtime-ubuntu24.04 nvidia-smi
docker run --rm --gpus all nvidia/cuda:12.8.0-cudnn-runtime-ubuntu24.04 nvidia-smi

# 如果失败，检查 NVIDIA Container Toolkit
systemctl status nvidia-container-toolkit
```

### 2. 内存不足

**解决方案**：
- 使用 `reduced_dbs` 模式
- 限制 MSA 搜索：`--max_template_date`
- 增加 Swap 空间

### 3. JAX CUDA 错误

```bash
# 检查 CUDA 版本兼容性
python -c "import jax; print(jax.devices())"

# 如果失败，手动安装指定版本
pip install jax==0.4.20 jaxlib==0.4.20+cuda12.cudnn9 -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html
```

### 4. HH-suite 找不到

```bash
# 检查 PATH
echo $PATH

# 确保 HHsuite bin 在 PATH 中
export PATH=/opt/hhsuite/bin:$PATH
```

---

## 📊 构建时间参考

| 步骤 | x86_64 | arm64 |
|------|--------|-------|
| 基础镜像下载 | 5-10 分钟 | 10-15 分钟 |
| 依赖安装 | 15-20 分钟 | 20-30 分钟 |
| Python 包安装 | 5-10 分钟 | 8-12 分钟 |
| **总计** | **30-40 分钟** | **40-60 分钟** |

*注：arm64 版本稍慢，但功能完全相同*

---

## ✅ 验证清单

构建完成后，运行以下检查：

- [ ] `docker images | grep alphafold` - 镜像已创建
- [ ] `docker run --rm --gpus all alphafold:arm64 nvidia-smi` - GPU 可用
- [ ] `docker run --rm alphafold:arm64 python -c "import tensorflow; print(tf.__version__)"` - TF 正常
- [ ] `docker run --rm alphafold:arm64 python -c "import jax; print(jax.devices())"` - JAX 正常
- [ ] `docker run --rm alphafold:arm64 hhblits -version` - HH-suite 可用
- [ ] 实际运行测试脚本 - 端到端成功

---

## 📝 GitHub 发布准备

### 1. 创建镜像标签

```bash
docker tag alphafold:arm64-v2.3.2 username/alphafold:arm64-v2.3.2
```

### 2. 推送至 Docker Hub

```bash
docker login
docker push username/alphafold:arm64-v2.3.2
```

### 3. 创建 GitHub Release

**Release 标题**: `AlphaFold 2.3.2 ARM64 Release`

**描述模板**：
```markdown
## AlphaFold 2.3.2 - ARM64 版本

### 支持平台
- Linux ARM64 (aarch64)
- NVIDIA GPU (CUDA 12.8)

### 镜像信息
- 镜像名：`username/alphafold:arm64-v2.3.2`
- 基础镜像：`nvidia/cuda:12.8.0-cudnn-devel-ubuntu24.04`
- Python 版本：3.12
- TensorFlow: 2.21.0
- JAX: CUDA 12 版本

### 快速开始

```bash
# 拉取镜像
docker pull username/alphafold:arm64-v2.3.2

# 运行测试
docker run --rm --gpus all \
  -v $PWD/output:/output \
  -v $PWD/fasta_dir:/fasta_dir \
  -v $PWD/database:/database \
  username/alphafold:arm64-v2.3.2 \
  --fasta_paths=/fasta_dir/test.fasta \
  --max_template_date=2022-01-01 \
  --model_preset=monomer \
  --data_dir=/database \
  --output_dir=/output
```

### 已知限制
- 需要 NVIDIA GPU (CUDA 12.8+)
- 至少 32GB 内存
- 数据库需单独下载 (~556GB)

### 文档
- [AlphaFold 官方文档](https://github.com/deepmind/alphafold)
- [本文档](README_arm64.md)
```

### 4. 添加标签

```bash
git tag arm64-v2.3.2
git push origin arm64-v2.3.2
```

---

## 📚 参考资料

- [AlphaFold 官方 GitHub](https://github.com/deepmind/alphafold)
- [NVIDIA Container Toolkit](https://github.com/NVIDIA/nvidia-docker)
- [JAX CUDA 安装](https://jax.readthedocs.io/en/latest/installation.html)
- [HH-suite ARM64 预编译包](https://github.com/soedinglab/hh-suite)

---

**最后更新**: 2026-04-08  
**维护者**: Jack W ang  
**状态**: ✅ 已测试验证
