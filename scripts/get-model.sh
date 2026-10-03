#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source .env
mkdir -p models

for f in "$MODEL_FILE" "$MMPROJ_FILE"; do
  url="https://huggingface.co/$HF_REPO/resolve/main/$f"
  dest="models/$f"

  remote=$(curl -sIL "$url" | grep -i '^content-length' | tail -n1 | tr -d '\r' | awk '{print $2}')
  if [[ -z "$remote" || "$remote" == "0" ]]; then
    echo "ERROR: could not find '$f' in $HF_REPO."
    echo "Check the exact file name on https://huggingface.co/$HF_REPO (Files and versions tab)."
    exit 1
  fi

  have=$(stat -c %s "$dest" 2>/dev/null || echo 0)
  if [[ "$have" == "$remote" ]]; then
    echo "$f already complete ($(numfmt --to=iec "$remote"))"
    continue
  fi

  echo "Downloading $f ($(numfmt --to=iec "$remote")) ..."
  curl -L -C - --fail -o "$dest" "$url"
done

echo
echo "Done. Files in ./models:"
ls -lh models/*.gguf
