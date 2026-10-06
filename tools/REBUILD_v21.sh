#!/usr/bin/env bash
# LE 31 — REBUILD COMPLET (v21). Usage :
#   bash tools/REBUILD_v21.sh            -> assets + import + audit + paquet
#   bash tools/REBUILD_v21.sh --rig      -> en plus : re-rig de la creature (rig/skin/semelle)
# Prerequis : numpy, scipy, Pillow. Le binaire Godot 4.3 est retéléchargé si absent.
set -e
PROJ="$(cd "$(dirname "$0")/.." && pwd)"
GODOT=/home/user/.cache/Godot_v4.3-stable_linux.x86_64
cd "$PROJ"

if [ ! -x "$GODOT" ]; then
  echo "== Godot 4.3 absent : telechargement =="
  mkdir -p /home/user/.cache && cd /home/user/.cache
  curl -sL -o g.zip https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_linux.x86_64.zip
  unzip -o -q g.zip && rm -f g.zip && chmod +x "$GODOT"
  cd "$PROJ"
fi

if [ "$1" = "--rig" ]; then
  echo "== 1/5 creature : squelette + poids =="; python3 tools/rig_monstre.py
  echo "== 2/5 peau et visage (UV) ==";         python3 tools/skin_tex.py
  echo "== 3/5 machoire + dents ==";            python3 tools/patch_jaw.py
  echo "== 4/5 semelle (contacts pieds) ==";    python3 tools/sole_extract.py
else
  echo "== creature : conservee (--rig pour la regenerer) =="
fi

echo "== assets proceduraux (tex/pbr/audio) =="; bash tools/regen_h.sh
echo "== import Godot =="; "$GODOT" --headless --path . --import 2>&1 | tail -3
echo "== audit =="; "$GODOT" --headless --path . --dbg=audit --seed=1 2>&1 \
  | grep -E "AUDIT|bodies=" | tail -3
echo "== paquet (construit dans /tmp, jamais dans le workspace) =="
ZIP=/tmp/LE31_projet_v21-wip.zip
rm -f "$ZIP"
zip -qr "$ZIP" . -x "./.godot/*" -x "./.git/*" -x "./.gitignore"
echo "$ZIP : $(stat -c%s "$ZIP") octets, $(unzip -l "$ZIP" | tail -1 | awk '{print $2}') fichiers"
