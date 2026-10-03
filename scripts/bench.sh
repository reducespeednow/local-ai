#!/usr/bin/env bash
# The server must be stopped first, otherwise the model is loaded twice and the laptop runs out of memory.
set -euo pipefail
cd "$(dirname "$0")/.."
source .env

if docker ps --format '{{.Names}}' 2>/dev/null | grep -qx llama; then
  echo "The llama container is running. Stop it first with: ai-down"
  exit 1
fi

if ! command -v llama-bench >/dev/null; then
  echo "llama-bench not found. It comes from nixos/local-ai.nix (llama-cpp with Vulkan)."
  exit 1
fi

echo "Benchmarking models/$MODEL_FILE ..."
llama-bench -m "models/$MODEL_FILE" -ngl 99 -p 512,2048 -n 128
