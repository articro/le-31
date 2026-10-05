#!/usr/bin/env bash
# Construit le paquet v12 complet à partir du projet (à lancer avant push_v12.sh)
cd /home/user/hantise || exit 1
rm -f /home/user/LE31_projet_godot_v12.zip
zip -q -r /home/user/LE31_projet_godot_v12.zip . -x "./.godot/*" -x "./.git/*"
ls -la /home/user/LE31_projet_godot_v12.zip | awk '{print $5" octets"}'
unzip -l /home/user/LE31_projet_godot_v12.zip | tail -2
