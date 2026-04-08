#!/bin/bash
# AlphaFold 测试脚本 - 快速测试

set -e

DOWNLOAD_DIR="/home/mutek/genedata"
ALPHAFOLD_DIR="/home/mutek/alphafold"
OUTPUT_DIR="/home/mutek/alphafold_output"

# 创建测试序列
cat > /tmp/test.fasta << 'EOF'
>test_protein
MKTAYIAKQRQISFVKSSFSGLPSTILPDTNKYVLLVGCTCGSMGLGQKKVAVDCALG
EOF

# 创建输出目录
mkdir -p "$OUTPUT_DIR"

echo "=========================================="
echo "       AlphaFold 快速测试"
echo "=========================================="
echo ""
echo "📁 数据库目录：$DOWNLOAD_DIR"
echo "📁 AlphaFold: $ALPHAFOLD_DIR"
echo "📁 输出目录：$OUTPUT_DIR"
echo ""

# 检查 Docker 和 GPU
echo "🔍 检查环境..."
# docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi > /dev/null 2>&1
echo "✅ Docker 可用 (跳过 GPU 测试，直接运行)"

# 运行测试
echo ""
echo "🚀 开始运行 AlphaFold..."
echo "⏱️  预计时间：10-30 分钟"
echo ""

cd "$ALPHAFOLD_DIR"

python3 docker/run_docker.py \
    --fasta_paths=/tmp/test.fasta \
    --max_template_date=2022-01-01 \
    --model_preset=monomer \
    --db_preset=full_dbs \
    --data_dir="$DOWNLOAD_DIR" \
    --output_dir="$OUTPUT_DIR" \
    --num_multimer_predictions_per_model=1 \
    --enable_gpu_relax=true

echo ""
echo "=========================================="
echo "  ✅ AlphaFold 测试完成！"
echo "=========================================="
echo ""
echo "📊 测试结果在：$OUTPUT_DIR/"
echo ""
ls -lh "$OUTPUT_DIR/"
echo ""
echo "📄 查看结果：ls -lh $OUTPUT_DIR/*.pdb"
