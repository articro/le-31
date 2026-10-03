# LE 31 — LANCEMENT DANS GODOT (FR)

## 1. Installer Godot
- Télécharge **Godot 4.3 STABLE, version "Standard"** (pas .NET / pas 4.4+) :
  https://godotengine.org/download/archive/4.3-stable/
- Aucune installation : dézippe et lance l'exécutable.

## 2. Ouvrir le jeu
- Dézippe `LE31_projet_godot_v2.zip` où tu veux (le dossier `hantise/`).
- Dans Godot : Manager → Import → sélectionne `hantise/project.godot` → Import & Edit.
- Le cache d'import est inclus : l'ouverture est directe (sinon laisse-le réimporter les textures 2K, ~1 min).
- Appuie sur **F5** (ou le bouton Lecture). Choisis FRANÇAIS ou ENGLISH. Ça tourne.

## 3. Contrôles
- ZQSD / WASD / flèches : marcher · MAJ : courir · SOURIS : regarder
- ÉCHAP : pause · V : grain VHS on/off · G : qualité haute/basse
- Règle du jeu : lis la pancarte. Traverse si rien n'a changé. Demi-tour si quelque chose a changé.

## 4. Config graphique
- Rendu **Forward+** : PBR 2K (albedo+normal+roughness+AO), brouillard volumétrique,
  SDFGI (illumination globale), glow/bloom, tonemap ACES, ombres portées des lampes,
  réverbération de couloir.
- PC modeste ? Appuie sur **G** en jeu : coupe brouillard volumétrique, SDFGI, glow et ombres.
- Résolution native 1280×720 (MSAA ×2). Change-la dans Project Settings → Display si besoin.

## 5. Vérifié avant livraison
- Autopilot headless : joueur parfait → victoire en 5 boucles ; joueur aveugle → rattrapé.
- Audit des 13 anomalies : 13/13 sans erreur.
- Zéro asset externe : textures PBR, pixel art, audio et covers 100 % générés par le pipeline maison.

## EN (short)
Godot 4.3 Standard → open `hantise/project.godot` → F5. WASD/arrows, SHIFT run, mouse look,
ESC pause, V VHS grain, G quality toggle. Forward+ PBR 2K + volumetric fog + SDFGI + glow.
