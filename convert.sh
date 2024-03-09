#!/bin/bash
echo "Minecraft JE 3D Model Splitter"
echo "Prerequisites: jq >= 1.6"
echo "Caution: Cannot convert files that contains multiple textures in one element"
file_path="$1"
file_dir=$(dirname "${1}")
if [[ -z $1 ]]; then
  echo ""
  echo "Usage: ./convert.sh <file>"
  exit
fi
echo "Splitting model into multiple models with single texture..."
cat $file_path | jq --raw-output '.textures | del(.particle) | keys | .[]' |
while IFS= read -r line; do
  output_name=$(cat $file_path | jq --raw-output ".textures.\"$line\"")
  cat $file_path | jq "\"$line\" as \$raw_texture | \"#\\(\$raw_texture)\" as \$texture |
.elements |= map(select(.faces | map(.texture | . == \$texture) | all)) |
.textures |= with_entries(select([.key] | inside([\$raw_texture, \"particle\"]))) |
.textures |= (.particle = .[\$raw_texture])" > "${file_dir}/${output_name}.json"
done
read -r -p "Press Enter to close..."
