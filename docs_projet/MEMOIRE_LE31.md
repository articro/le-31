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

### v17 DEMARCHE — 10 parties (genoux + coudes), creature dormante, banque sonore refaite (2026-10-05)
- **Retour utilisateur** apres la v15 : « plus de mouvement », « elle apparait trop tot », « les sons sont nuls »,
  « le grincement ne fait pas de bruit ». Les 4 points sont traites.
- **Decoupe 10 parties** (`tools` : script inline) : body 63 741 / head 7 664 / armUR 1 879 / armLR 3 844 /
  armUL 1 956 / armLL 4 013 / thighR 4 142 / shinR 4 330 / thighL 3 930 / shinL 4 398 tri.
  Pivots : hanches (0 ; 0,94) · genoux (+-0,373 ; 0,47) · epaules (+-0,30 ; 1,88) · coudes (+-0,62 ; 1,528).
  Offsets enfants : coude-epaule = (0,32 ; -0,352) · genou-hanche = (0,373 ; -0,47) — exprimes dans le repere
  du parent NON tourne (le parent applique ensuite sa rotation, comme un vrai rig).
- **`_build_entity_model3()` + `_anim_entity3()`** : cuisses sin(phase) x0,78 , genoux repliés
  (-max(0,sin(phase+0,75))x1,15 en chasse), bras antagonistes + coudes (-0,95 en chasse), corps qui tangue
  (rotation.z 0,075 / y bob), **tete qui suit le joueur** (lerp_angle borne +-0,9) et **pas synchronises**
  (`mstep.wav` joue a chaque franchissement de PI de la phase). Articulations = spheres du meme materiau
  (rayons 0,115 bassin / 0,085 epaules / 0,078 genoux / 0,062 coudes) pour masquer les coupes.
- **Dormance** : `_ent_asleep()` = `run_time < 75 et notes_found == 0`. Pendant la dormance : invisible,
  immobilise (vitesse de patrouille 0), hear_r = 0, position forcee sur `entity_node` (choisi LE PLUS LOIN
  du joueur via sort_custom). **Reveil** : elle est repositionnee au point le plus eloigne de toi, + sting
  + growl lointain, puis la « laisse d'ecoute » (v16) prend le relais. L'audit force `ent_spawn_delay = 0`.
- **Banque sonore ENTIEREMENT refaite** (21 fichiers, synthese numpy main-codee) : step/mstep (pas),
  creak (grincement de bois, 119 Ko, volume -8 -> -2 dB + **declenchement en marchant partout** via
  `creek_sfx_t`), heart, breath, growl, sniff, whisper, chime, **key_jingle** (nouveau, ramassage de cle),
  **paper** (nouveau, ramassage de note), scare, sting, drone, wind, house (craquements aleatoires),
  tension, music (boucle 32 s), cam_click, tape_rewind, lowbatt.
  `play()` charge par nom -> aucun cablage a refaire.
- **F3** fait maintenant defiler 3 modeles (v17 -> v15 -> v13).
- Validation : AUDIT ALL OK (122 bodies) ; `--dbg=m2` construit les 2 modeles (99 897 tri chacun) ;
  bot quiet = WIN ; bot walk = se fait attraper (laisse d'ecoute active) ; le detail de debug `--dbg=m2`
  teste desormais AUSSI le modele 10 parties.
- Release **404417768** (tag v17 = 4a47a8f8, 199 blobs, zip 58 015 454 o).

---

## S17 — v19 « MONSTRE » (06/10/2026) — création skinnée

**Le changement de méthode.** Toutes les versions v13→v18 assemblaient la créature en 10 morceaux rigides collés
(boules aux articulations pour cacher les coupes) : d'où les trous aux coudes et les épaules déformées.
La v19 abandonne l'assemblage : `tools/rig_monstre.py` transforme le maillage TRELLIS brut
(`monstre_tpose.glb`, 83 569 sommets, 99 897 triangles, A-pose, texture WebP réencodée en PNG) en
**personnage skinné** `assets/models/monstre_rig.glb` :

* squelette de **21 os** (hips, spine, chest, neck, head, clavL/R, upperarm, forearm, hand, thigh, shin, foot, toe) ;
* poids de sommets = distance point‑segment avec **fenêtres anatomiques à bords lissés** (gate smoothstep),
  puis **lissage laplacien** du maillage (8 voisins) ; 4 influences maximum par sommet ;
* bascule 180° : le visage regarde **−Z** (convention Godot) ;
* piège à retenir : **l'os racine doit porter le même décalage que le maillage** (ici −0,5 sur Y) sinon le
  squelette pivote 0,5 m trop bas. C'est ce qui a coûté une régénération.
* piège n°2 : **Godot 4.3 ne lit pas le WebP dans un glTF** (`Couldn't load image … image/webp`) → texture grise.
  L'exporteur réencode donc la texture en PNG.

**L'animation** (`tools/anim_ref.py`, portée à l'identique dans `main.gd::_anim_entity_rig`) :

* jambes en **IK 2 os** dans le plan sagittal ; hauteur du bassin calée sur la foulée maximale
  (`reach = 0,965 × chaîne`) pour que l'IK ne sature jamais ;
* **phase d'appui pilotée par la distance** : `gait += (vitesse × dt) / (foulée / 0,62)` — l'appui dure 62 % du cycle ;
* l'inclinaison et le roulis du bassin sont **retranchés** des jambes (sinon 12 cm de décalage du pied) ;
* l'oscillation verticale du bassin est compensée pour ne pas rallonger la jambe (sinon le pied flotte de 7 cm) ;
* filtre 1 pôle (16 s⁻¹) sur les seules rotations de jambes ; les canaux de pose (lean, arm_x, arm_z, arm_fwd,
  elbow…) sont fondus à 3,6–5 s⁻¹ → transitions douces entre rôde / alerte / chasse / recul / bond ;
* angles de bras **mesurés**, pas devinés : `rz +0,60` fait pendre le bras, `ry −1,10` le tend vers l'avant.
  C'est `arm_fwd` (lacet des épaules) qui donne l'attitude de chasse.

**Mesures en moteur** (`--dbg=rig`, 240 images) : pénétration du pied dans le sol **−0,008 m**,
piétinement résiduel **2,5 cm/image** (bruit de mesure), 21 os, chaîne 0,3422.
Batterie complète : `audit` OK (bodies=123), `m2` total_tris=99897, `mvis` 37/37, `quiet` WIN catches=0.

**Autres correctifs v19** : rayon anti‑mur porté à **0,50 m** ; **déclic anti‑blocage** (si elle avance de moins de
0,45 m en 1,6 s alors qu'elle traque, elle est replacée à 7‑30 m, même étage) ; **collider de la rampe de
l'escalier du garage** — la rampe était purement décorative, le joueur butait sur les 24 marches de 12,4 cm et
ne pouvait donc jamais monter à l'étage.

**Reste à faire (v20)** : visage (yeux creux + mâchoire fendue animée — le maillage TRELLIS n'en a pas),
puis les 4 props, l'extérieur nuit, les 8 trophées.

---

## S18 — v20 « VISAGE » (06/10/2026) — peau et visage peints en UV

La géométrie TRELLIS contient bien des orbites et une bouche, mais la texture était beige et uniforme : le visage
était donc illisible. `tools/skin_tex.py` peint la peau **en espace UV** (aucun risque pour le maillage) :

1. **carte de cavité** : concavité par sommet (écart a la moyenne des 12 voisins, projeté sur la normale),
   lissée en UV → les creux (orbites, bouche, narines, plis du cou, aisselles) s'assombrissent seuls ;
2. **orbites renforcées** : les 25 % de sommets les plus creux de chaque côté de la face, en deux puits noirs ;
3. **extrémités refroidies** (mains, pieds, visage), **crasse** (bruit basse fréquence + gravité),
   **teinte cadavre**, arêtes saillantes éclaircies de 8 % ;
4. piège : dans un atlas UV, **un sommet = un seul pixel** → tout masque doit être renormalisé après lissage,
   sinon l'intensité est divisée par ~100 et rien ne se voit.

**Correction trouvée** : en chasse, un bras partait vers l'avant et l'autre vers l'arrière. Le lacet d'épaule doit
être appliqué avec **−sgn** (le côté gauche = x négatif dans le modèle Godot). Vérifié à l'image, face caméra.

**Ménage du dépôt** : les 16 fichiers OBJ du monstre découpé (v13/v15/v17, ~32 Mo) sont supprimés — la créature
est skinnée. Ne restent que `monstre_rig.glb` (le personnage), `monstre_tpose.glb` (la source pour régénérer),
`monstre_rig_0.png` (**texture extraite par l'importateur Godot : obligatoire, ne pas supprimer**),
`monstre_rig_bones.json` et `monstre_sole.json`.
Commande de reconstruction complète : `bash /home/user/REBUILD_v20.sh`.

**Mesures** : texture de base 0,306 de luminosité moyenne → 0,285 ; creux 0,074 ; orbites 0,105.
Tests : `rig` −0,008 m de pénétration / 2,5 cm de patinage / 21 os · `audit` ALL OK bodies=123 ·
`m2` RIG SKINNE 99897 tri · `mvis` 37/37 · `quiet` WIN catches=0. Paquet : **60 713 249 octets, 159 fichiers**.
