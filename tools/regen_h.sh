#!/bin/bash
# Régénère TOUS les assets de LE 31 (à lancer avant toute ouverture Godot/export)
set -e
cd "$(dirname "$0")"
python3 gen_tex_h.py > /dev/null
python3 gen_pbr_h.py > /dev/null
python3 gen_audio_h.py > /dev/null
echo "ASSETS LE31 REGENERES: $(ls ../assets/tex | wc -l) tex, $(ls ../assets/pbr | wc -l) pbr, $(ls ../assets/audio | wc -l) audio"
