#!/usr/bin/env bash
# LE 31 — REBUILD : reconstruit TOUT le livrable a partir des sources du projet.
# A lancer depuis n'importe ou : bash /home/user/REBUILD_v20.sh
#   1. regenere le personnage skinné (squelette + poids de sommets) depuis monstre_tpose.glb
#   2. re-peint la peau et le visage (orbites, bouche, crasse) en espace UV
#   3. re-exporte les points de contact des pieds
#   4. reconstruit le paquet .zip du projet
# Prerequis : numpy, scipy, Pillow (python3 -m pip install numpy scipy pillow).
set -e
echo "== 1/4 personne skinnée =="
python3 /home/user/tools/rig_monstre.py
echo "== 2/4 peau et visage =="
python3 /home/user/tools/skin_tex.py
echo "== 3/4 semelle =="
python3 /home/user/tools/sole_extract.py
echo "== 4/4 paquet =="
bash /home/user/MAKE_ZIP_V20.sh
echo
echo "Termine. Pour tester dans Godot : ouvrir /home/user/hantise (l'import prend ~5 min la 1re fois),"
echo "puis F5. Le marqueur en haut a droite doit afficher : v20 VISAGE"
echo "Tests automatises : --dbg=rig · --dbg=audit · --dbg=m2 · --dbg=mvis · --dbg=quiet"
