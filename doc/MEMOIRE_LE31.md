# MÉMOIRE LE 31 — transférable à une nouvelle session
_Ce fichier est LA source de vérité du projet « LE 31 » (jeu d'horreur Halloween, Godot 4.3).
Le projet « Marmite & Monstres » est ABANDONNÉ par l'utilisateur : ne JAMAIS le relancer, ne jamais en parler, ne jamais toucher aux dossiers marmite/ s'ils existent encore._

## 0. Miroir public (si workspace vide et sans token)
- Mémoire toujours lisible sans auth : https://raw.githubusercontent.com/articro/le-31-memoire/main/MEMOIRE_LE31.md (et START_LE31.md dans le même repo public articro/le-31-memoire).
- Le repo du JEU (articro/le-31) reste PRIVÉ : pour télécharger le zip v10 ou pusher, il faut un PAT que l'utilisateur colle en session.

## 1. Cadre & utilisateur
- Jeu horreur « LE 31 » : sortie avant le 31 oct 2026, lancement dans Godot (F5), PAS itch.io, zéro budget, « un jeu beau graphiquement ».
- Répondre en français, décisions directes, prendre des initiatives sans demander (l'utilisateur a déjà skipé un questionnaire : préférer trancher justifié).
- Anti-copie : concept simple + innovant, interdiction de copier Backrooms ; identité propre (VHS analog horror, 31 OCT 1997).
- L'utilisateur fournit de vraies captures in-game (Win+Alt+R) ; le jeu a un mode auto-capture `--dbg=shot`.
- Musique DOIT s'entendre ; effets vieille télé (VHS) assumés ; carré mobile assumé.
- Token GitHub : l'utilisateur colle un PAT classique (ghp_…) en session, JAMAIS persisté ; ancien token à révoquer ; en redemander un si besoin de push.

## 2. État GitHub (vérifié 2026-10-04)
- Repo : `github.com/articro/le-31` (compte articro).
- Release **v9** id 402871729 : zip v9 + 6 png le31_v9_01..06.
- Release **v10** id 403000748, tag v10 : `LE31_projet_godot_v10.zip` (47 853 009 o) + 6 png `le31_v10_01_couloir_sombre`, `02_salon`, `03_cuisine`, `04_monstre_anime`, `05_etage`, `06_sortie`. Body mentionne ÉTAGE.
- Arbre HEAD = 109 blobs (scripts/main.gd, project.godot, LANCEMENT.md, 36 png, 13 wav, 49 .import) + doc/MEMOIRE_LE31.md.
- Push : script `/home/user/push_v10.sh <PAT>` (clone, unzip payload chemin ABSOLU, commit, tag -f v10, release réutilisée via GET /releases/tags/v10, upload zip si absent). LEÇON : après tout push, vérifier `GET /repos/articro/le-31/git/trees/HEAD?recursive=1` (compte des blobs) avant d'annoncer.
- Mise à jour en place d'une release : DELETE /releases/assets/{id} puis re-upload ; PATCH /releases/{id} avec Content-Type: application/json.

## 3. Workspace
- `/home/user/hantise/` = projet Godot : `scripts/main.gd` (~3 000 lignes, TOUT le jeu), `project.godot`, `assets/` (tex/pbr/audio), `tools/regen_h.sh`, `LANCEMENT.md`.
- `/home/user/doc/` : `release_notes_v9.json`, `release_notes_v10.json`, `le31_shots_v9/`, `le31_shots_v10/`, `horreur_plan_halloween2026.md` (§S8, §S8bis, §S9), `MEMOIRE_LE31.md`, `START_LE31.md`.
- `/home/user/push_v9.sh`, `/home/user/push_v10.sh`, `/home/user/LE31_projet_godot_v10.zip`.
- **NON persistant / wipes fréquents** (plafond snapshot ~128 Mo) : `/home/user/.cache` (binaire Godot), `hantise/assets` et `hantise/.godot` parfois wiped EN COURS de session. Procédure rebuild standard :
  1. `cd /home/user/hantise && bash tools/regen_h.sh` (~60 s → 20 tex, 16 pbr, 13 audio)
  2. `curl -sL -o /home/user/.cache/g.zip https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_linux.x86_64.zip` + unzip + chmod +x
  3. `Godot --headless --path . --import` (→ 98 fichiers .godot/imported)
  4. Toujours vérifier qu'un `--check-only` a VRAIMENT tourné (binaire présent !) : un `grep -c ERROR` à 0 sans binaire = faux positif.
- Garder /home/user < ~120 Mo (zip v9/v10 locaux supprimables : recoverables depuis les releases).

## 4. Architecture technique (main.gd)
- Script unique : dict TR FR/EN (`tt()`), `_ready` parse `--dbg=X` et `--seed=N` (SANS `--` devant, sinon args users ignorés), states title/intro/play/win/dead.
- Maison 20×14 : couloir z 5.8–8.2 ; salon/cuisine/sdb au nord (portes 3.55/10.05/16.55), garage/ch1/ch2 + escalier au sud (portes 3.05/8.05/12.55-verrouillée/17.55) ; sortie EST (19.7,7) VERROUILLÉE (clé dorée) ; ouvertures 1.6 m + jambages + 18 piliers jonction collidés ; `_door_panel` v2 (porte ouverte 90°, passage ~1.4 m).
- ÉTAGE y=2.98 (dalle + trémie x 0.8–2.2 z 8.3–9.2, murs 2.98–5.2, toit 5.3, cloison x 12.5 porte z 6.2–7.8 ; grenier aménagé ouest + chambre est ; 1 lampe allumée, fenêtre émissive, placard-cachette).
- Escalier garage OUEST (x 0.9–2.1) : 24 marches colliders + **transfert guidé** `stair_t`/`stair_dir` (2.5 s), triggers bas (z 13.1–13.85, mv.z<-0.1, y<1) / haut (z 8.35–9.1, mv.z>0.1, y>2) ; `_terrain_y(p, lvl)` quantifié marches pour bots/entité.
- Graphe IA : `NODES` 14 (0–9 rez, 10–12 étage, 13 pied rampe), `NODE_LVL`, `EDGES` dont [6,13],[13,10],[10,11],[10,12] ; `_node_of(p, lvl)` ; `_bfs_path` (indices) / `_bfs_pts` (points + waypoints portes via `_edge_door`).
- Entité (« ELLE », aveugle) : hear_r = noise×14 (marche 0.18→2.5 m, sprint 5.6→14 m, grincements 1.0, immobile 0.03, cachée 0) ; ×0.25 si niveau différent ; modes 0 patrol 1.15 / 1 alerte 2.2 / 2 chase 3.6 (réglisse 4.3, glue ×0.45) ; give-up 6 s si noise<0.35 ; chase cross-level via BFS mid-waypoint ; contact <0.85 ET |Δy|<1.2 : caramel=graze, mode2=_caught, sinon lunge (stun 1 s + graze_cd 2 s) ; spawn nœuds 3..9 rez, >7 m joueur, >4 m sortie, ne campe pas la sortie ; anim : jambes LegL/LegR (gait 2.2 patrouille / 6.5 chase), inclinaison 0.04/0.14, colonne voûtée, épaules, lambeaux.
- Joueur : capsule 0.3/1.5 ; marche 3.4 / sprint 5.6 (endurance) ; lampe torche SpotLight energy 9 range 18 ON par défaut (G) ; V = VHS ; E = appât bonbon ; F = piège sucre collant (zone r1.6, 8 s, entité ×0.45) ; 3 spawns aléatoires SPAWN_POINTS [(1.2,7),(2.0,2),(11.5,2.2)] ; 4 cachettes HIDE_SPOTS (placard ch2 15.8/9.0, alcôve garage 3.0/9.0, escalier 8.0/12.6, placard étage 18.8/2.2) : hear 0, pas de contact, give-up ×3 ; 5 bonbons CANDY_SPOTS (dont étage 16.2/11.5/2.98) ; clés KEY_SPOTS_A (sortie, 4 spots dont étage 15.8/3.0/2.98) / KEY_SPOTS_B (ch1, 4 dont étage 6.5/2.5/2.98), pickup <0.9 + même niveau, ch1 unlock <1.3.
- Audio/visuel : PBR 2K procédural (regen_h.sh), fog volumétrique + SDFGI + glow (désactivés en mode shot), grain VHS shader, musique wav dès le menu.
- Modes dbg (headless) :
  - `--dbg=audit` : steps 0–7 = bfs+solid(≥40 bodies), candy+creak, hear+bait, portes PHYSIQUES (6×70 move_and_slide) + montée escalier RÉELLE (dbg_move_frames=420, dbg_move_dir, input forcé dans le code mouvement) + BFS étage, win avec clé. « AUDIT ALL OK » = vert.
  - `--dbg=smart|quiet|walk|blind` : bots BFS (indices) + nudge anti-stuck (1.1/2.4 m perpendiculaire) + terrain_y ; quiet 3.5/0.14, smart 3.6/0.05, walk 3.4/1.0, blind sourde ; bot clé étage = cheat au pied de rampe.
  - `--dbg=shot` : 6 poses low-FX, save /tmp/le31_shots/shotN.png frame 70. Commande : `xvfb-run -a Godot --path . --rendering-driver vulkan --resolution 960x540 --dbg=shot`.
- Matrice validée v10 : audit ALL OK (122 bodies) ; quiet seeds 5/6/10 WIN ; smart 3 WIN ; blind 7 WIN ; walk 4 CAUGHT×3 (normal).

## 5. Pièges appris (ne pas redécouvrir)
- `move_and_slide()` ×N dans une même frame = solver instable → tester via frames réelles (dbg_move_frames).
- Plan incliné 30–41° = jam capsule (même collider épais) → escalier = transfert guidé.
- Godot 4 : pas de ConeMesh (CylinderMesh top_radius 0) ; `transparency_mode` = prop Godot 3 (utiliser `.transparency`) ; var déclarée dans une boucle = scope fonction (pas de redéclaration) ; un `else` s'attache au `if` intermédiaire inséré ; override input AVANT `if mv.length_squared()`.
- Face avant Godot = −Z ; yaw IA `atan2(mv.x, mv.y)` ; yaw shot `atan2(-dx,-dz)`.
- Headless : spam « Parameter "m" is null » = pré-existant (dummy renderer), inoffensif GPU.
- Bots : ne jamais spawner dans un meuble (voiture !) ; nœud final derrière escalier inaccessible (y forcé 0) ; spots clés/cachettes à choisir hors furniture (vérifier bboxes _furn).
- GitHub : unzip payload en chemin ABSOLU (sinon commit vide qui vide le repo) ; OCR de PAT depuis capture = non fiable (faire coller le texte).
- `-- --dbg=X` = args users ignorés → passer `--dbg=X` directement.
- grep sans accent = faux négatif (ÉTAGE vs ETAGE).

## 6. Suite du plan
1. Validation v10 en jeu par l'utilisateur (lancement Godot, F5).
2. Si validé : pipeline TikTok/Shorts (approuvé en principe, CPU-only, ffmpeg/numpy maison, matière = captures user ou teasers motion-design) — NE PAS lancer sans feu vert.
3. v11 éventuel sur demande user uniquement (ex. extérieur, nouveaux étages, narration).
4. Révoquer l'ancien PAT après usage.

## 7. État v11 (2026-10-04 soir)
- Une session séparée a démarré v11 : patch « v11d » = **extérieur existant (sol + arbres + nuit)** visible depuis les fenêtres/sortie + **finitions du monstre**. Cette session a CRASHÉ 3× (« Something went wrong ») pendant un rendu de shots sous **lavapipe** (VK_DRIVER_FILES=lvp_icd.json, 28 min) → son workspace est probablement perdu.
- **Aucun commit/tag v11 sur GitHub** (vérifié : dernier commit = v10 + docs mémoire). Donc v11 est À REFAIRE depuis la base v10, sauf si un tag `v11-wip` apparaît (vérifier `GET /repos/articro/le-31/tags` au démarrage).
- Feuille de route v11 retenue : (1) extérieur nuit (sol, arbres silhouette, ciel/lune) visible par fenêtres + porte de sortie ouverte ; (2) finitions monstre (détails silhouette, mains/griffes, yeux) ; (3) audit + matrice bots verts ; (4) shots mesa-vulkan ; (5) push release v11.
- **RÈGLE ANTI-CRASH (absolue)** : après chaque étape validée (parse OK, audit OK, matrice OK), commit + tag `v11-wip` + push AVANT tout rendu long ou toute opération risquée. Un rendu de shots ne se lance JAMAIS avec du travail non poussé.
- Rendus shots : `sudo apt-get install -y xvfb mesa-vulkan-drivers` puis `xvfb-run -a Godot --path . --rendering-driver vulkan --resolution 960x540 --dbg=shot` (~5 min). JAMAIS lavapipe/lvp_icd.json (28 min, OOM, crash de turn).

## 8. v11 « VISION » (2026-10-05, session Arena 2)
- **Bug racine trouvé (mesuré)** : `PlaneMesh` + rotation (PI/2,0,PI/2) → normale **(−1,0,0)** = plans VERTICAUX.
  `_room_floor` (sols), le quad de plafond, `_wall_seg` (murs selon l'ordre des points), tapis, lattes,
  flaque collante → tout ça était debout. D'où : sol absent, mur fantôme beige, murs noirs, caméra
  « dans la géométrie ». Correctif : **boîtes pleines** partout (`_box`), dalles de sol 0,10 m par pièce,
  plafond = dalles d'étage (trémie ouverte). UV mesurées : « haut » d'un PlaneMesh = **+Z local**
  (yaw flèche = `atan2(dir.x, dir.y)`).
- Monstre redessiné _make_entity : 2,3 m, dos voûté, bras très longs, mains osseuses, tête aveugle
  dégagée, 7 lambeaux + 2 loques d'épaule ; animation existante conservée (LegL/LegR, bras, tête).
- Preset SÛR auto : GPU Intel/Arc/llvmpipe → `quality_high=false` + SDFGI/fog coupés (dans `_build_world`,
  APRÈS `_load_settings`) + **F2** bascule la qualité.
- Livrables : `/home/user/LE31_projet_godot_v11.zip` (47,8 Mo, 119 fichiers), `LE31_v11_main.gd.zip`,
  patch reproductible `/home/user/patch_v11a.py`, checkpoint `doc/checkpoints/main_v11b.gd`,
  aperçu `doc/art/monstre_v10_vs_v11.png`, notes `doc/release_notes_v11.md`.
- **Anti-OOM sandbox** : 2 vCPU / ~1,9 Go RAM → PAS de rendu de shots possible (llvmpipe = kill OOM).
  Les captures de validation sont faites par l'utilisateur (GPU Arc A750) ou via `--dbg=shot` chez lui.
- Piège nouveau : `pkill -x Godot_v4.3-...` ne matche PAS (comm tronqué à 15 car.) → utiliser
  `pkill -f "[G]odot_v4.3-stable"` (le crochet évite de tuer son propre shell).

## 9. v12 « ÉLARGIE » (2026-10-05, session Arena 2, après retour utilisateur)
- **Flèche au sol supprimée** (`ghost_arrow = null`, plus de suivi par frame) + textes i18n mis à jour.
- **Lampe recalculée** : energy 9 -> 4.6, range 18 -> 13, angle 50 -> 42 ; poussière 90 -> 55.
- **ESCALIER : vrai bug trouvé**. Base de la volée à z=13.6 avec mur sud à z=14 => joueur écrasé contre
  le mur, zone de déclenchement (13.1-13.85) inatteignable. L'audit **téléportait** le joueur dedans
  (angle mort du test !). Correctif : volée reculée de 1.2 m (base 12.4), rampe/rails/trémie -1.2,
  `RAMP_RECT` -> z 7.4-12.5, nœuds IA ajustés (13 -> 12.9), **déclencheurs larges sans condition `mv.z`**
  (x 0.65-2.4 ; z 12.4-13.95 et 6.6-8.3) + `stair_cd` anti-rebond + toasts.
- **MAISON ÉLARGIE** : couloir z 5.8-8.2 -> **z 5.0-9.0 (2.4 -> 4.0 m)**. Tous murs/portes/piliers/
  cloisons/waypoints BFS (_edge_door)/dalles de plafond recalculés (dalles : 14.0/6.9/5.9 au lieu de
  14.0/8.3/4.8). Meubles et spots déplacés (canapé 4.3, citrouille 9.9, KEY_SPOTS_A[2] -> (9.8,7.2),
  HIDE_SPOTS[1] -> (15.8,9.7), HIDE_SPOTS[2] -> (3.0,9.9), affiches z 4.93/9.07).
- **SCREAMER refait** : `assets/tex/screamer.png` (1280x853, généré), `flash_rect` rouge + secousse +
  zoom `scare_t` (0.6 s de décroissance), son `scare` doublé (+3 / -1 dB désaccordé) + `sting`,
  durée 0.55 -> 1.6 s (mort) et 0.95 s (respawn).
- **Monstre encore détaillé** : genoux, chevilles, 4 orteils/pied, 5 côtes, 6 vertèbres, clavicules,
  tendons de cou, 7 mèches de cheveux (en plus de l'existant). Aperçu `doc/art/monstre_v10_vs_v11.png`.
- **NOUVEAU accroupissement (C)** : vitesse 1.7, bruit 0.07 (au lieu de 0.18), caméra -0.42, pas -19 dB.
- **NOUVEAU 5 notes** (`NOTE_SPOTS`, `taken_notes`, `note_meshes`) : garage, salon, cuisine, chambre 2,
  étage ; toast lore + whisper ; compteur HUD « NOTES n/5 ».
- Validation : **AUDIT ALL OK (122 bodies)** ; bot quiet seed 5 = **WIN (1 prise)**.
- **PLAFOND DE SNAPSHOT** : workspace passé à 241 Mo => nettoyage obligatoire. Règle : garder
  `/home/user` < ~110 Mo. Supprimés : `uploads/` (captures déjà copiées), doublons d'images, `.godot`
  (régénérable par `--import`, 47 Mo). Le **zip projet se construit à la demande** :
  `bash /home/user/MAKE_ZIP_V12.sh` puis `bash /home/user/push_v12.sh <PAT>`.
- **Piège** : ne JAMAIS écrire un motif de kill (`pkill -f`, `pgrep -f`) dans la même commande que le
  chemin complet du binaire Godot — le motif matche la propre ligne de commande du shell et le tue.
  Utiliser `pkill -x Godot_v4.3-stab` (nom de process tronqué à 15 car.).
- **Props IA** : guide + 4 images prêtes (`doc/PROPS_IA_GUIDE.md`, `doc/props_ia/` : TV CRT, horloge,
  poupée, table). Space gratuit : huggingface.co/spaces/microsoft/TRELLIS.2 (MIT) ou
  stabilityai/TripoSR. JAMAIS Hunyuan3D-2 (licence hors UE). Monstre = procédural (décision v12).

### v13 CLAIRVOYANCE — le monstre devient un vrai modele 3D (2026-10-05)
- **Modele genere par IA (TRELLIS.2, Space Microsoft, licence MIT)** depuis `monstre_front.png` :
  reglages Decimation 100000 / Texture 1024 -> `monstre.glb` (4 443 492 o, glTF 2, 96 251 tris,
  73 160 sommets, 0 squelette, 0 animation, 2 WebP 2048^2 baseColor + metallicRoughness).
- **Decoupe `tools_split_monstre.py`** : echelle 2,35 m, pieds y=0, visage **-Z**, pivots bakes
  hanches y=0,94 / cou y=2,15 -> `assets/models/monstre_{body,head,legL,legR}.obj` + `monstre_tex.png`
  (1024^2, vt inverse car glTF). Pas de decoupe des bras : ils sont SOUDES au torse (trous sinon).
- **Integration `patch_v13a.py`** : `_make_entity()` aiguille vers `_build_entity_model()` si
  `assets/models/monstre_body.obj` existe ET `dbg != "nomodel"` ; sinon repli procedural v11/v12 intact.
  Noeuds Body (y 0,94) / LegL / LegR (pivots hanches) / Head (y 2,15) -> l'animation existante les pilote
  sans changement. Materiau : albedo_tex `monstre_tex.png`, couleur (0,66/0,64/0,62), rough 0,72,
  SSS 0,16, rim 0,55, cull disabled. Aura OmniLight + `ent_breath`/`ent_growl`/`ent_sniff` en 3D.
- **CORRECTION ORIENTATION (v13)** : le monstre regarde vers **-Z** (yeux/machoire a z~-0,13 cote
  procedural ; rotation 180 deg Y appliquee a la decoupe) mais le code de marche utilisait
  `atan2(dx, dz)` -> il marchait **A L'ENVERS depuis la v11**. Corrige en `atan2(-dx, -dz)` (chasse) et
  rotation **fluide** en patrouille (`lerp_angle`, 3,6 rad/s) dans `_move_entity_toward`.
- **Marqueur en jeu** : coin haut-droit `v13 CLAIRVOYANCE`. Trace console : `DBG entity=MODEL3D (TRELLIS)`
  ou `DBG entity=PROCEDURAL`. Comparaison a chaud : lancer avec `--dbg=nomodel`.
- Validation : **AUDIT ALL OK (122 bodies)** avec le modele ; bot `quiet seed 5` = **WIN (2 prises)** ;
  chargement des 4 OBJ verifie (sommets 52 159 / 2 146 / 10 244 / 9 646 ; texture 1024^2).
- Pieges v13 : (1) le `.glb` est REFUSE par le chat -> passer par l'upload GitHub web ;
  (2) `raw.githubusercontent` = cache CDN -> verifier par l'API contents ;
  (3) import Godot headless : `--import` ecrit 8 `.import` (~45 s) ;
  (4) warning LOD « non-finite normal » sans gravite.

### v14 VISEUR — le camescope Hi8 (2026-10-05)
- **Camera A** (choix utilisateur) : clic droit maintenu ou **T** leve le viseur ; shader plein ecran
  (`CAM_SHADER`, const dans main.gd) = teinte verte + desaturation + grain + scanlines + vignette + glitch.
  HUD : `● REC  HI8  31 OCT 1997  hh:mm:ss  [BATT n%]` (horodatage = 23:10 + run_time).
- **Batterie** : 100 % au depart, -0,62 %/s viseur leve, bip (+ son `lowbatt.wav`) sous 20 %, extinction a 0.
  **5 piles** (+35 %) posees aux NOTE_SPOTS decalees (0.45, +0.02, 0.35) via `_spawn_pile()` ; ramassage
  a moins de 1,5 m (et |dy| < 1,6).
- **Rembobinage (R)** : -9 % batterie, cooldown 7 s, duree 1,5 s ; gelee de la creature (position restauree
  chaque frame = `rewind_pos`, mode force a 0) ; traînee des 20 dernieres secondes (echantillon 0,1 s,
  210 points max) tracee en ImmediateMesh additif sans test de profondeur ; le bruit pose
  `bait_pos = position joueur` + `bait_timer = 3,5 s` -> **elle vient voir**.
- **Marqueur** : sphere additive rouge a y 2,45 sur la creature, visible seulement au viseur (`ent_marker`,
  recree automatiquement a chaque respawn de l'entite).
- **Sons generes (numpy one-off)** : `cam_click.wav` (0,14 s), `tape_rewind.wav` (1,4 s, moteur + flutter
  + clics), `lowbatt.wav` (0,62 s, deux bips).
- **Piege de code** : les ancres du patch doivent tenir compte du fait que les blocs `if scare_t` et
  `if entity != null ... entity.visible` sont DEJA apres le deplacement de l'entite dans `_process` :
  `_cam_update(d)` est insere juste avant `if scare_t > 0.0:` pour pouvoir la geler APRES son propre
  deplacement de frame.
- Validation : AUDIT ALL OK (122 bodies) ; bot quiet seed 5 = WIN (1 prise) ; `--dbg=cam` = 5 piles,
  grade 1,0, batterie 100 -> 87,6, traînee 76 points.

### v15 MOUVEMENT — le monstre T-pose de l'utilisateur, en 6 parties animes (2026-10-05)
- **Fichier recu** : `monstreTpose.glb` (4 837 856 o, 99 897 tri, 2 webp 1024, 0 skin) depose par l'utilisateur
  a la RACINE du repo -> range dans `assets/models/monstre_tpose.glb`.
  **ATTENTION** : son `clé.glb` est un **duplicata octet-pour-octet du monstre** (md5 20f207e1..., meme taille) :
  la generation de la cle a echoue silencieusement. A refaire.
- **Decoupe `tools_split_tpose.py`** : 6 parties (body 63 741 / head 7 664 / legR 8 472 / legL 8 328 /
  armR 5 723 / armL 5 969 tri), echelle 2,35 m, pieds y=0, visage -Z, pivots hanches 0,94 / cou 2,00 /
  **epaules ( 0,30 ; 1,88)**. Methode de segmentation : jambes = y < 0,94 puis **test axe du bras**
  (t plus grand que 0,05 et perpendiculaire < 0,16 le long de l'axe epaule->main) — indispensable car
  les PIEDS ecartes (jusqu'a 0,56 m) tombaient sinon dans les bras. Piege : tester les 2 cotes en
  MIRROIR (l'axe gauche = axe droit avec x inverse), sinon le bras gauche part dans le corps.
- **Pose en jeu** : bras a 47,7 deg sous l'horizontale dans le modele -> `rotation.z = -+0,528 rad` pour les
  faire pendre (mains a x 0,49 / y 0,98) ; jambes resserrees de `-+0,20 rad` (ecart des pieds 1,12 -> ~0,72 m).
- **Animation des bras (patch_v15a)** : ils sont maintenant **separes** donc reellement animes
  (balancement en marche, lever avant en chasse), branchges sur `ent_model_kind` :
  1 = v15 (6 parties) par defaut, 0 = v13 (4 parties). **F3 bascule les deux a chaud** (rebuild de l'entite
  en conservant position et mode) ; `--dbg=model1` force la v13, `--dbg=m2` verifie la structure (nouveau test).
- **Cles** : remplacees par une vraie forme 3D (`_key_model()` : tige cylindrique + anneau torus + panneton
  + 2 dents) et **rotation lente** en jeu (0,7 rad/s).
- **TRELLIS.2 par API (gradio_client)** : l'API fonctionne depuis la sandbox (`/start_session`,
  `/preprocess_image`, `/image_to_3d` avec resolution 512/1024/1536, `/extract_glb` avec decimation_target
  et texture_size) MAIS le **quota ZeroGPU anonyme est epuise** (~180 s de GPU par jour et par IP ;
  une generation demande 120 s). Message : "Authenticate with a Hugging Face token for more quota".
  -> Reessayer le lendemain, ou demander un **jeton HF gratuit** (read) a l'utilisateur pour generer
  d'un coup cle + TV + poupee + horloge via `/home/user/tools/trellis_gen.py` (deja ecrit).
- Validation : AUDIT ALL OK (122 bodies) ; bot quiet seed 5 = WIN ; `--dbg=m2` = 99 897 tri repartis ;
  camera v14 intacte. Release **404060487** (tag v15 = 27604f69, 173 blobs, zip 74 101 123 o).
