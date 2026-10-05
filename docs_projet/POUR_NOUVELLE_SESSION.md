# POUR UNE NOUVELLE CONVERSATION — état LE 31 au 2026-10-05 (v13 prête, v12 en ligne)

_À copier-coller tel quel dans une nouvelle session si besoin._

---

Projet LE 31 (Godot 4.3, repo **privé** `articro/le-31`, miroir mémoire `articro/le-31-memoire`).
**Tout le travail vit dans `/home/user/hantise`** (projet Godot complet) — s'il est absent, le
récupérer depuis la release GitHub (`LE31_projet_godot_v12.zip`), jamais demander un `main.gd` au chat.

## Contenu de la version en cours (v13 « CLAIRVOYANCE »)
1. **Monstre 3D IA** : `monstre.glb` (TRELLIS.2, MIT, 96 251 tris) découpé en 4 parties animables
   (`assets/models/monstre_{body,head,legL,legR}.obj` + `monstre_tex.png`) → silhouettes réalistes.
   Intégration dans `_make_entity()` → `_build_entity_model()`; **repli procédural conservé**
   (fichiers absents ou `--dbg=nomodel`).
2. **Orientation corrigée** : le monstre regardait à l'envers depuis la v11 (convention -Z) ; marche
   et patrouille corrigées (`atan2(-dx,-dz)` + `lerp_angle` dans `_move_entity_toward`).
3. Rappel du reste : map élargie, escaliers réparés, lampes 4,6/13/42, screamer VHS, C accroupi,
   5 notes, blackout, grognement + reniflement 3D, preset sûr Intel/Arc (F2 = qualité).
- Validation : **AUDIT ALL OK (122 bodies)** avec le modèle · bot `quiet seed 5` = **WIN**.
- Marqueur en jeu : coin haut-droit **v13 CLAIRVOYANCE** ; console : `DBG entity=MODEL3D (TRELLIS)`.

## Fichiers clés
- Code : `hantise/scripts/main.gd` (3 466 lignes) · checkpoints `doc/checkpoints/main_v13.gd`,
  `main_v12.gd`, `main_v11a/b.gd`, `main_v10_ref.gd`.
- Patch reproductible : `/home/user/patch_v13a.py` (+ v11a/b, v12a→d).
- Découpe du GLB : `/home/user/tools_split_monstre.py` (échelle 2,35 m, visage -Z, pivots 0,94/2,15).
- Publication : `bash MAKE_ZIP_V13.sh` puis `bash push_v13.sh <PAT>` (**PAT à redemander à l'utilisateur**,
  jamais persisté, à révoquer après la série de pushes).
- Notes : `doc/release_notes_v13.md`, `doc/SOLUTION_MONSTRE.md`, `doc/MEMOIRE_LE31.md` (§9 = journal).

## Pièges sandbox (à réapprendre sinon)
- 2 vCPU / ~1,9 Go : **aucun rendu d'image possible** (lavapipe = OOM/kill, déjà interdit par
  l'utilisateur). Validation visuelle = PC de l'utilisateur (Intel Arc A750).
- `/home/user/.cache` (binaire Godot) est effacé à chaque snapshot → re-télécharger
  `Godot_v4.3-stable_linux.x86_64` AVANT tout `--import`/audit ; sinon `--version` répond
  « No such file or directory ».
- `.obj`/`.png` doivent être importés (`--headless --path . --import`, ~45 s) sinon `load()` renvoie null.
- Un seul process Godot à la fois ; tuer avec `pkill -f "[G]odot_v4.3-stable"` (jamais le motif nu).
- Plafond de snapshot ~128 Mo : `hantise/.godot` (69 Mo) se supprime sans risque, le **zip projet se
  construit à la demande** puis se supprime après le push.
- Upload par le chat : images/pdf/txt/md uniquement — **les `.glb` sont refusés** (passer par GitHub web).
