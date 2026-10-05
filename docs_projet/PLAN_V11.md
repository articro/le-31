# PLAN v11 — corrections de rendu + refonte du monstre
_Écrit le 2026-10-04 d'après les captures in-game de l'utilisateur (Intel Arc A750 8 Go, Ryzen 7 2700, 24 Go)._
_Captures sources : /home/user/doc/le31_bugs_2026-10-04/_

## Bloquant immédiat
Workspace vide (normal) + repo `articro/le-31` **privé** → impossible de récupérer `main.gd` (~3 000 lignes) sans **PAT** (ou zip v10 en pièce jointe).
L'utilisateur a donné le droit de lancer tout ce qui est nécessaire. **Ne rien pousser avant son feu vert visuel sur les nouvelles captures.**

## Diagnostic (5 captures)
1. **bug1_couloir_murs_noirs** : des pans de murs non éclairés tombent au noir absolu → lisibles comme des trous (« les murs disparaissent »). Aucune lumière ambiante de secours.
2. **bug2_sol_sans_matiere** : grande zone de sol sans revêtement (plaque brune unie) + zones noires (trou de couverture). Le sol n'est pas « défini ».
3. **bug3_fleche_flottante** : la flèche au sol est énorme, inclinée/en l'air, halo émissif qui écrase la scène (aussi vue entre les jambes du monstre, cf. bug5).
4. **bug4_camera_dans_geometrie** : caméra à l'intérieur d'une géométrie (mur/monstre) → gros polygone beige illisible, fond noir.
5. **bug5_monstre_illisible** : le monstre se lit comme « un cône sombre avec une lampe et des mains squelettiques blanches ». Ne ressemble à rien.

## Hypothèses de causes (à vérifier dans le code)
- SDFGI + fog volumétrique + glow = effets fragiles sur **Intel Arc** (bugs driver Vulkan connus). Nos 6 captures de release sont faites en `--dbg=shot` **avec ces effets désactivés** → elles ne montrent pas ce que voit l'utilisateur.
- Murs/noirs : occlusion ambiante du WorldEnvironment trop agressive + aucune lumière de remplissage + matériaux peut-être face unique (backface → trou).
- Sol : couverture partielle (pièces sans mesh de sol ou sol unique z-fighté) + la flèche z-fight avec le sol.
- Flèche : quad émissif mal orienté (rotation/quaternion) et/ou positionné au centre du joueur au lieu du sol.
- Monstre : silhouette conique (CylinderMesh top_radius 0 = le « piège » mémorisé) + tête-abat-jour + proportions qui ne lisent pas à distance.

## Corrections prévues (dans main.gd)
1. **Éclairage/ambiance** : ambient light minimale chaude (~0.04), occlusion réduite, murs en double-face (`cull_mode = disabled`) sur les pans intérieurs, plafond complet, et **préréglage « sûr » auto-détecté** (GPU Intel → SDFGI dégradé ou off, fog volumétrique allégé) + option dans le menu.
2. **Sol** : revêtements par pièce (lattes salon/couloir, carrelage cuisine/sdb, béton garage, plancher étage), couverture 100 %, pas de z-fighting, collisions revérifiées par l'audit.
3. **Flèche au sol** : plaque fine (≈4 mm) collée au sol, orientée vers la sortie à chaque frame, émission ÷3, fondu selon distance, extinction à <2 m de la porte.
4. **Monstre (refonte complète, procédurale pour garder anim + collider)** : 2,2 m, dos voûté, bras très longs sous les genoux, tête aveugle enfoncée entre les épaules, mâchoire fendue, mains osseuses, loques, jambes fines digitigrades ; respiration, tête qui pivote vers la source de bruit, démarche traînante (patrouille) / course (chasse).
5. **Option plan B** : si le rendu en jeu ne convainc pas → maillage IA (TRELLIS/SF3D via Space Hugging Face gratuit, jamais Hunyuan3D-2 = licence hors UE) + retopo Blender + rig Mixamo → .glb.

## Validation (matrice connue, ne pas régresser)
- `--dbg=audit --seed=1` → « AUDIT ALL OK », 122 bodies.
- Bots : quiet/smart/blind = WIN ; walk = CAUGHT ×3 (normal).
- 6 nouvelles captures (`--dbg=shot`, xvfb + vulkan 960×540) envoyées à l'utilisateur.
- Push v11 (tag + release + zip + captures) **uniquement après feu vert**, puis vérifier `git/trees/HEAD?recursive=1`.

## Rappels
- PAT `ghp_…` collé en session, jamais persisté, à révoquer après usage.
- Pipeline TikTok/Shorts : pas sans feu vert explicite.
- Toujours vérifier que le binaire Godot existe avant de croire un `--check-only` (faux positif sinon).


---

## ÉTAT AU 2026-10-05 (fin de session 2)
**FAIT**
- Bug racine identifié et corrigé (plans verticaux → boîtes) : sols, murs, plafond, tapis, lattes, flaque.
- Flèche au sol refaite (orientation vérifiée par mesure des UV : « haut » = +Z local).
- Monstre redessiné (2,3 m voûté) + aperçu comparatif `doc/art/monstre_v10_vs_v11.png`.
- Preset SÛR auto Intel/Arc/llvmpipe + touche F2 (qualité).
- Audit : AUDIT ALL OK (122 bodies). Bot quiet seed 5 : WIN (avant refonte finale ; matrice complète en cours).
- Livrables : `LE31_v11_main.gd.zip` (32 Ko, à copier dans un v10 extrait → test immédiat),
  `doc/release_notes_v11.md`, `doc/checkpoints/main_v11b.gd`, `patch_v11a.py`, `push_v11.sh`.

**EN COURS / RESTE**
- Matrice bots smart:3 / blind:7 / walk:4 sur le code final (log : `doc/matrice_v11.log`).
- Rendu des captures : IMPOSSIBLE dans la sandbox (2 vCPU / 1,9 Go, llvmpipe = OOM kill).
  → soit l'utilisateur lance `--dbg=shot` chez lui, soit il envoie ses captures Win+Alt+R.
- Publication : dès PAT reçu → `zip -r LE31_projet_godot_v11.zip` puis `bash push_v11.sh <PAT>`
  (commit + tag + release + captures), VÉRIFIER le compte de blobs après push.
