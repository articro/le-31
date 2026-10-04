# PREMIER MESSAGE À COLLER DANS UNE NOUVELLE CONVERSATION
(copier tout le bloc ci-dessous, ou simplement : « Continue LE 31 : lis /home/user/doc/MEMOIRE_LE31.md » si le workspace est partagé)

---
Projet actif unique : **LE 31**, jeu d'horreur Halloween en Godot 4.3, repo GitHub `articro/le-31`.
Lis d'abord `/home/user/doc/MEMOIRE_LE31.md` (mémoire complète : architecture, pièges, état GitHub) et `/home/user/doc/horreur_plan_halloween2026.md` §S9. Si ces fichiers sont absents, voici l'essentiel :

- État : **v10 shippée** = release id 403000748, tag v10, assets `LE31_projet_godot_v10.zip` (47 853 009 o) + 6 png le31_v10_01_couloir_sombre/02_salon/03_cuisine/04_monstre_anime/05_etage/06_sortie. Release v9 = id 402871729. Arbre HEAD ~110 blobs.
- Workspace : `/home/user/hantise/` (projet Godot, scripts/main.gd ~3 000 lignes = tout le jeu), `/home/user/doc/`, `/home/user/push_v10.sh <PAT>`.
- Wipes fréquents (~128 Mo) : si `hantise/assets` ou `/home/user/.cache/Godot_v4.3-stable_linux.x86_64` manquent → `bash hantise/tools/regen_h.sh` + curl Godot 4.3 zip dans .cache + `--headless --import` (98). Vérifier que le binaire existe avant de croire un check-only.
- Commandes : audit `Godot --headless --path . --dbg=audit --seed=1` (attendre « AUDIT ALL OK », 122 bodies) ; bots `--dbg=smart|quiet|walk|blind --seed=N` (quiet/smart/blind doivent WIN, walk CAUGHT×3) ; shots `xvfb-run -a Godot --path . --rendering-driver vulkan --resolution 960x540 --dbg=shot` (SANS `--` devant --dbg).
- Contenu v10 : maison sombre + torche (G, 9/18, ON), sortie EST verrouillée (clé dorée aléatoire 4 spots dont étage), 2e clé chambre verrouillée, 4 cachettes sûres, piège collant F, monstre animé marche/course (aveugle, ouïe noise×14, ×0.25 à travers plancher), escalier garage OUEST = transfert guidé 2.5 s vers ÉTAGE (grenier aménagé + chambre), 3 spawns, 5 bonbons, mains viewmodel supprimées, i18n FR/EN.
- Pièges majeurs : move_and_slide ×N/1 frame = instable ; pente 30-41° = jam capsule ; Godot 4 sans ConeMesh ; else s'attache au if inséré ; override input avant `if mv.length_squared()` ; push GitHub = vérifier tree après ; unzip chemins absolus.
- Règles user : français décisif, initiatives sans demander, zéro budget, beau graphiquement, anti-copie Backrooms, musique audible, PAS itch.io. **Le projet « Marmite & Monstres » est abandonné : ne jamais en parler ni y toucher.** Le pipeline TikTok/Shorts est approuvé en principe mais NE PAS le lancer sans feu vert explicite.
- Prochaine étape attendue : validation v10 en jeu par l'utilisateur, puis décisions v11/Shorts selon son retour.
---
