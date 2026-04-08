#!/bin/bash
# AlphaFold 2 ARM64 测试脚本
# 快速测试 AlphaFold 2 在 ARM64 系统上的构建

# 配置
DOWNLOAD_DIR="/home/mutek/genedata"
OUTPUT_DIR="/home/mutek/alphafold_output"
FASTA_FILE="/home/mutek/test_protein.fasta"
MAX_TEMPLATE_DATE="2022-01-01"
MODEL_PRESET="monomer"
DB_PRESET="reduced_dbs"  # 使用精简数据库快速测试

# 打印配置信息
echo "=========================================="
echo "AlphaFold 2 ARM64 测试脚本"
echo "=========================================="
echo "数据库目录：$DOWNLOAD_DIR"
echo "输出目录：$OUTPUT_DIR"
echo "FASTA 文件：$FASTA_FILE"
echo "模板日期：$MAX_TEMPLATE_DATE"
echo "模型预设：$MODEL_PRESET"
echo "数据库预设：$DB_PRESET"
echo "=========================================="

# 检查数据库目录
if [ ! -d "$DOWNLOAD_DIR" ]; then
    echo "❌ 错误：数据库目录不存在：$DOWNLOAD_DIR"
    echo "请运行：./scripts/download_all_data.sh $DOWNLOAD_DIR reduced_dbs"
    exit 1
fi

# 检查精简数据库是否可用
if [ "$DB_PRESET" = "reduced_dbs" ]; then
    if [ ! -f "$DOWNLOAD_DIR/small_bfd/bfd-first_non_consensus_sequences.fasta" ]; then
        echo "⚠️  警告：精简数据库不存在，需要完整数据库"
        echo "请运行：./scripts/download_all_data.sh $DOWNLOAD_DIR"
        exit 1
    fi
    echo "✅ 精简数据库已就绪"
else
    # 检查完整数据库
    if [ ! -f "$DOWNLOAD_DIR/bfd/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt.a3m" ]; then
        echo "⚠️  警告：完整数据库不存在"
        echo "请运行：./scripts/download_all_data.sh $DOWNLOAD_DIR"
        exit 1
    fi
    echo "✅ 完整数据库已就绪"
fi

# 检查 FASTA 文件
if [ ! -f "$FASTA_FILE" ]; then
    echo "❌ 错误：FASTA 文件不存在：$FASTA_FILE"
    exit 1
fi

# 创建输出目录
mkdir -p "$OUTPUT_DIR"
echo "✅ 输出目录已创建：$OUTPUT_DIR"

# 检查 Docker
if ! command -v docker &> /dev/null; then
    echo "❌ 错误：Docker 未安装"
    exit 1
fi

# 检查 GPU 访问
echo "🔍 检查 GPU 访问..."
if ! docker run --rm --gpus all nvidia/cuda:12.8.0-base nvidia-smi &> /dev/null; then
    echo "⚠️  警告：Docker GPU 访问可能有问题"
    echo "请检查 NVIDIA Container Toolkit 安装"
else
    echo "✅ GPU 访问正常"
fi

# 检查镜像
echo "🔍 检查 AlphaFold Docker 镜像..."
if ! docker images | grep -q "alphafold.*arm64"; then
    echo "⚠️  警告：找不到 alphafold:arm64 镜像"
    echo "请先构建镜像：docker build -f docker/Dockerfile -t alphafold:arm64 ."
else
    echo "✅ AlphaFold ARM64 镜像已就绪"
fi

# 运行 AlphaFold
echo ""
echo "=========================================="
echo "启动 AlphaFold 2 ARM64 测试"
echo "=========================================="
echo "预计运行时间：5-15 分钟（精简数据库）"
echo ""

python3 docker/run_docker.py \
    --fasta_paths="$FASTA_FILE" \
    --max_template_date="$MAX_TEMPLATE_DATE" \
    --model_preset="$MODEL_PRESET" \
    --db_preset="$DB_PRESET" \
    --data_dir="$DOWNLOAD_DIR" \
    --output_dir="$OUTPUT_DIR" \
    --num_multimer_predictions_per_model=1

# 检查结果
echo ""
echo "=========================================="
if [ $? -eq 0 ]; then
    echo "✅ AlphaFold 测试完成！"
    echo ""
    echo "结果文件："
    ls -lh "$OUTPUT_DIR/"
    echo ""
    echo "主要文件："
    echo "  - ranked_0.pdb    : 最佳结构预测"
    echo "  - ranked_0.jdf    : 预测置信度"
    echo "  - aligned.txt     : MSA 对齐结果"
    echo ""
else
    echo "❌ AlphaFold 运行失败"
    exit 1
fi
echo "=========================================="
