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
