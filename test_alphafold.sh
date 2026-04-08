#!/bin/bash
# AlphaFold 测试脚本

DOWNLOAD_DIR="/home/mutek/genedata"
OUTPUT_DIR="/home/mutek/alphafold_output"

# 检查 BFD 是否解压完成
echo "等待 BFD 数据库解压完成..."
while true; do
    BFD_SIZE=$(du -sh "$DOWNLOAD_DIR/bfd/" 2>/dev/null | awk '{print $1}')
    echo "BFD 大小：$BFD_SIZE"
    
    if [[ "$BFD_SIZE" == *"T"* ]] || [[ -f "$DOWNLOAD_DIR/bfd/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt.a3m" ]]; then
        echo "✅ BFD 数据库已解压完成！"
        break
    else
        echo "⏳ 仍在下载/解压中，等待 60 秒..."
        sleep 60
    fi
done

echo ""
echo "=== 启动 AlphaFold 测试 ==="

# 创建输出目录
mkdir -p "$OUTPUT_DIR"

# 运行 AlphaFold
python3 /home/mutek/alphafold/docker/run_docker.py \
    --fasta_paths=/home/mutek/test_protein.fasta \
    --max_template_date=2022-01-01 \
    --model_preset=monomer \
    --db_preset=reduced_dbs \
    --data_dir="$DOWNLOAD_DIR" \
    --output_dir="$OUTPUT_DIR" \
    --num_multimer_predictions_per_model=1

echo ""
echo "✅ AlphaFold 运行完成！"
echo "结果在：$OUTPUT_DIR/"
ls -lh "$OUTPUT_DIR/"
