#!/bin/bash

INSTANCE_DIR="instances/homogeneous_fleet/70_100"
SCRIPT="src/main.jl"
OUT_DIR="out"

mkdir -p "$OUT_DIR"

if [ ! -d "$INSTANCE_DIR" ]; then
    echo "Erro: pasta '$INSTANCE_DIR' não encontrada!"
    exit 1
fi

for instance in "$INSTANCE_DIR"/*; do
    if [ ! -f "$instance" ]; then
        continue
    fi

    base=$(basename "$instance")
    log_file="$OUT_DIR/${base%.*}.log"

    echo "Executando $SCRIPT com $instance..."
    stdbuf -oL julia "$SCRIPT" "$instance" > "$log_file" 2>&1
    echo "Log salvo em $log_file"
    echo "------------------------------------"
done

echo "Execução concluída! Todos os logs estão em '$OUT_DIR/'."

