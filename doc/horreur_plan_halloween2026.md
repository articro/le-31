# PROJET HORREUR HALLOWEEN 2026 — PLAN ZÉRO BUDGET
_Statut : en attente des 4 décisions utilisateur. Marmite & Monstres mis de côté (v1.8.0 prête à pousser, revue CrazyGames en cours — rien n'est supprimé)._

## 1. Ce que dit le marché (oct. 2026)
- **Anomaly horror ("Exit 8-likes") = LA vague virale 2026** : The Exit 8 = 2 M de ventes + film en salles US (avril 2026) ; **Home Alone (Anomaly) : ~27 K joueurs simultanés et 54,8 M de visites TikTok** (juillet 2026) ; Animal Hospital dans le même sillage ; genre defining sur Roblox en 2026.
- **Esthétiques dominantes du horreur gratuit itch.io** : PS1/PSX lo-fi (communauté Haunted PS1) et **analog horror VHS / faux bureau Windows** (REDACT.vhs, Channel 64, Phantomware 0, NetEscape).
- **Format gagnant** : session courte 10-20 min, une seule mécanique forte, "cursed job" ou boucle, moments clipables pour streamers/TikTok.
- Trou : la plupart des Exit 8-likes sont Windows-only (UE/Unity). **Un anomaly horror jouable DANS LE NAVIGATEUR = friction zéro depuis un lien TikTok** = notre angle d'attaque.

## 2. Moteur & outils (0 €)
| Besoin | Choix | Pourquoi |
|---|---|---|
| Moteur | **Godot 4.3** | Gratuit, sans royalties, export Web + Windows, pipeline déjà rodé dans ce sandbox (Marmite), shaders PSX faciles (basse rés + dithering + fog) |
| Art | **Génération procédurale maison (PIL/code)** + CC0 si besoin (Kenney, ambientCG) | Identité unique, zéro licence, zéro coût |
| Audio | Synth maison (comme l'OST Marmite) + Freesound CC0 pour les foley | Idem |
| Voix "cassette" | TTS déformé (pipeline voix déjà maîtrisé) | Code générique de l'analog horror, gratuit |
| i18n | FR + EN dès le jour 1 (leçon Marmite) | Marché TikTok mondial |
| Distribution | itch.io (compte existant) : gratuit / name-your-price ; build Web = lien jouable instantané | Viral sans friction |
| Marketing | Clips verticaux 30-60 s ; **mode capture intégré au jeu** (screenshots auto des moments forts) ; devlogs itch ; soumission Haunted PS1 demo disc | Exposition gratuite |

## 3. Trois concepts candidats
### A — RECOMMANDÉ : anomaly loop Halloween, vue FPS PSX-VHS
Couloir de maison hantée / cave bouclant sur lui-même ; repérer les anomalies (affiche qui change, lumière qui clignote mal, silhouette au fond, citrouille en trop…) ; chaque erreur = retour au départ + l'entité se rapproche ; sortie atteinte = fin. 10-20 min, 15-20 anomalies, 2-3 fins.
Pourquoi : formule prouvée 2026 (54,8 M de visites TikTok), scope tenuable en 4 semaines, le chat des streamers joue à "trouve l'anomalie" en direct, skin Halloween naturel.
### B — Shift maudit : analog horror de bureau
Night-shift : numériser des cassettes VHS familiales d'Halloween 1997 ; quelque chose apparaît à l'image ; tout se passe dans un faux OS rétro. Scope encore plus petit, très "genre code", mais moments clipables un cran en dessous.
### C — Roulette bonbons (duel de table, façon Buckshot Roulette)
Face au Marchand : piocher des bonbons d'un sac, certains maudits ; objets = sel, bougie, miroir… Tension de table, rejets infinis, très streamer. Mais mécanique à équilibrer finement = risque de tuning long.

## 4. Planning cible (si deadline 31 oct.)
- **S1** : graybox boucle complète (marche, loop, reset, sortie) + 6 anomalies + peur de base (sons, lumière).
- **S2** : direction artistique finale PSX-VHS + 15-20 anomalies + entité + identités son/voix cassette.
- **S3** : fins, juice, i18n FR/EN, page itch + covers + trailer (assemblé via le mode capture).
- **S4** : playtests utilisateurs, fixes, **sortie 24-25 oct.** pour chevaucher la recherche "halloween horror game".

## 5. Ce qu'il me faut de toi
1. Les 4 décisions (concept, style, langues, deadline).
2. ~15 min/jour de playtest sur le preview web + tes captures réelles (Win+Alt+R).
3. Validation des jumpscares/VO comme d'hab (je montre avant de renderer).
4. Compte itch existant ; idéalement un TikTok/YouTube Shorts où poster (sinon je prépare clips + légendes + hashtags prêts à publier).
5. La clé butler quand on pousse (tu pushes toi-même ou tu me la colles).

## 6. AVANCEMENT RÉEL
- **S1 FAITE (prototype jouable)** : projet Godot 4.3 `/home/user/hantise/` ; anneau-couloir 38 m ; boucle complète (passe propre +1 / passe avec anomalie = erreur / demi-tour correct = reroll / demi-tour inutile = erreur) ; 7 anomalies (affiche changée, citrouille en trop, lampe morte, silhouette, pancarte règle 3 piégée, porte ouverte aux yeux, chuchotement audio) ; escalade : 3 erreurs → poursuite par l'entité (cœur qui bat, fuite au départ, jumpscare si attrapé) ; 5 passes propres → porte EXIT lumineuse → victoire ; i18n FR/EN ; overlay VHS (scanlines, bruit, vignette, tracking) ; rendu PSX 320×180 ; audio 100 % synthétisé (drone 20 s bouclé, pas, sting, chime, whisper, heart, scare, creak).
- **Logique validée par autopilot headless** : joueur parfait = WIN en 5 boucles ; joueur aveugle = erreurs → poursuite → CAUGHT.
- Preview web live port 8080 (dossier export `/home/user/hantise_web/`).
- **S2 à faire** : anomalies supplémentaires (tache au sol, affiche à l'envers, lampe qui grésille, silhouette qui traverse), flicker aléatoire, entité aperçue au loin hors anomalie, variantes de couloir (coin encombré), page itch + covers, mode capture pour TikTok.
- **S2 FAITE** : 12 anomalies (+ tache sol, affiche retournée, lampe grésillante, silhouette qui traverse, porte supplémentaire), intro VHS datée « 31 OCT 1997 » typewriter, timestamp REC permanent, pause complète (reprendre/recommencer/titre), rampe de probabilité d'anomalie (55→85 %), crédit post-victoire, mode audit headless (13/13 OK), covers itch (cover 630×500, banner 1920×650, icon 128) + description FR/EN + recette de page dans /home/user/doc/le31_kit/LISEZMOI_itch.md.
- **BUILDS v1.0** : /home/user/hantise_web/ (web) · /home/user/hantise_win/LE31.exe (85 Mo) · /home/user/LE31-v1.0-web.zip.
- **RESTE S3/S4** : mode capture intégré pour TikTok, flicker global subtil, 2e variante de couloir (décor par run), page itch créée par l'utilisateur, playtests utilisateur, fixes polish, sortie 24-25 oct.

## 7. PIVOT « BEAU GRAPHIQUEMENT » (demande utilisateur : oubli itch, lancement Godot, budget Go libre)
- Rendu **Forward+** natif 1280×720 MSAA×2 : plus de pixelisation PSX, place au PBR.
- **Textures PBR 2K procédurales** (16 maps : albedo/normal/roughness/AO × sol bois, mur damassé, plafond plâtre, porte à panneaux) — tools/gen_pbr_h.py (numpy).
- Props 3D réels : lampes suspendues (cordon+abat-jour métal+ampoule émissive+ombre portée), plinthes et poutres, portes à encadrement+poignée laiton (+version ouverte noire aux yeux), affiches encadrées, pancarte sur planche, **citrouilles sculptées en lathe SurfaceTool** (visage émissif + lumière interne), entité volumétrique (capsule+tête+yeux, rim light) qui regarde le joueur.
- Environnement : brouillard volumétrique (god rays des lampes), SDFGI, glow/bloom, tonemap ACES, réverbération de couloir (AudioEffectReverb master).
- Touches : V = grain VHS on/off, G = bascule qualité (coupe fog/SDFGI/glow/ombres pour PC modestes).
- Logique de jeu inchangée et re-validée : audit 13/13, smart WIN, blind CAUGHT.
- **Livrable : /home/user/LE31_projet_godot_v2.zip (20 Mo, cache d'import inclus) + hantise/LANCEMENT.md**. itch mis de côté ; l'ancien build web v1.0 reste dans hantise_web mais n'est plus la cible.
- **S3 ACCESSIBILITÉ/UX (retours utilisateur v3)** : murs des coins scellés (16 quads de joint) ; menu principal vivant (caméra dérive dans le couloir + panneau JOUER/COMMENT JOUER/OPTIONS/QUITTER + toggle FR/EN) ; écran HOW TO PLAY en 5 règles ; OPTIONS complètes (volumes master/ambiance/effets, sensibilité souris, qualité, grain VHS, langue) persistées user://le31.cfg ; tuto contextuel (bannière BUT 10 s, hint déplacements 8 s, rappel règles 1er tour, bannière 1re anomalie, bannière sortie) ; toasts pédagogiques (+1 / bien vu / raté + RÉVÉLATION du nom de l'anomalie ratée) ; sous-titres des sons ([chuchotements] etc.) ; flèche-guide pulsante du 1er tour ; faisceau lumineux de la sortie ; pause auto si alt-tab ; F1 = mode photo (HUD off). Audit 13/13 + smart WIN + blind CAUGHT re-validés. Zip : LE31_projet_godot_v4.zip.
- **S4 LISIBILITÉ + TV (retours v4 + capture utilisateur)** : éclairage global ×2 (lampes 5.2, ampoules émissives 5.0, ambient 0.55, exposition ACES 1.35, fog 0.016, albedo PBR boosté ×1.6) + **lampe frontale SpotLight3D** garante de lisibilité ; flèche-guide = vrai chevron orange au sol (arrow.png) + toast explicatif au 1er tour ; ligne d'objectif PERMANENTE sous le HUD ; HOW TO PLAY auto-affiché au tout premier lancement (bouton C'EST PARTI) ; **shader TV qui bugue** : déchirures horizontales, jitter, vertical-hold slip, franges chromatiques, interlacement, OSD « ▶ PLAY » clignotant. Audit 0 erreur, smart WIN, blind CAUGHT. Zip v5 (41/41 assets).


## S5. Retour utilisateur v5 → correctifs v6 (3 octobre 2026)

### Demandé (verbatim)
1. « plus jamais je doit etre dans/un mur et voir a travers »
2. « je doit obligatoirement voir le sol »
3. « les bruits de pas je comprend pas que se sont mes pas »
4. « je peut courir infini, ajoute un systeme d'endurance »
5. « manque d'originalité, trop pompé sur exit 8… pas de risque de ban » ; identité propre : voir ses mains, entendre sa respiration, son cœur, « pleins de petits trucs »
6. « 21.3 MB je veut que sa augmente » via améliorations graphiques
7. COMMENT JOUER : pas de bouton « LANCER UNE PARTIE » dedans + overlay qui restait au lancement = bug
8. « g c'est pas la lampe torche ? » → il attendait que G allume la lampe

### Fait (v6)
- **Collisions réelles** : joueur = CharacterBody3D (capsule) + `move_and_slide`, 5 StaticBody3D (4 murs extérieurs + bloc intérieur). Plus de clamp analytique → physiquement impossible d'entrer dans un mur ou de voir à travers.
- **Sol visible** : normal map désactivée sur le sol (le signe du gradient assombrissait tout) + sol redessiné.
- **Lampe torche = G** (toggle, clic de creak) ; les options graphiques ne touchent plus à la lampe.
- **Endurance** : barre HUD (12, 690), drain 0.22/s en course, régén 0.16/s marche · 0.22/s arrêt, verrouillage du sprint sous 5 % ; respiration haletante sous 50 %, battements de cœur sous 25 %.
- **Mains visibles** (viewmodel enfant de la caméra) : manches + mains, balancement sin(bob), s'enfoncent quand l'endurance est basse.
- **Pas reconnaissables** : step.wav refait = thump grave 70 Hz + craquement de bois, pitch aléatoire 0.9–1.1 par pas, volume -6.
- **COMMENT JOUER** : bouton supprimer, auto-affiché au menu la 1re fois (mémo how_seen), masqué par `_start` → plus d'overlay résiduel.
- **Originalité (couche propre, rien de tel dans Exit 8) : les Bonbons Maudits** — draft 1/2 non bloquant de 9 s à chaque passe propre (miroir : les chuchotements trahissent l'anomalie · réglisse : la silhouette te chasse plus vite · caramel : une erreur de plus tolérée · sucre : endurance divisée par 2) ; poche max 3, **E pendant une chasse = lancer un bonbon → la silhouette se fige 2.5 s** ; i18n FR/EN complète.
- **Poids & graphismes** : PBR 2K → **3K** (4K = OOM sandbox), drone étendu à 45 s, **wind.wav** (vent en boucle) et **house.wav** (maison qui craque, 7 événements/24 s) mixés au vol, **poster_c** (chat noir) + affiche de base aléatoire par run (rejouabilité). 21.3 MB → **45.5 MB**.
- **Tests** : audit ALL OK (13 assertions) · smart WIN loops=5 mistakes=0 · blind CAUGHT, 0 SCRIPT ERROR.

### Addendum v6bis (même jour)
- **Zip introuvable chez l'utilisateur** : le snapshot workspace plafonne à ~128 MB et écrète les fichiers les plus récents → le zip 45 MB (qui incluait le cache .godot) et les assets sautaient à chaque fin de tour. Correctif : zip SANS .godot (inutile, Godot ré-importe à l'ouverture) = 29.8 MB, assets régénérables supprimés du workspace après build (tools/regen_h.sh les refait), scratch nettoyé (zip150/, builds/, LE31-v1.0-web.zip, v5.zip) → total 122 MB sous le plafond. Marmite INTACT (contrainte user).
- **4K abandonné** : 2 OOM kill sandbox (float32 4096² ×6 buffers) + solution par bandes = coutures visibles → refusé. Retiré de gen_pbr_h.py. PBR reste 3K + albedos détail max.
- **Audio stéréo** : drone 45 s, wind 20 s, house 24 s (pan aléatoire par événement) régénérés en 2 canaux (write2) ; **tension.wav** 20 s loop (pouls 140 BPM + triton 220/311 Hz + ticks) joué en boucle pendant les chasses (tension_pl, suivi via chasing dans _process), stoppé sinon.
- Tests finaux : 0 SCRIPT ERROR, audit ALL OK, smart WIN loops=5, blind CAUGHT. Zip v6 = 29 835 798 o, 102 fichiers (34 png, 12 wav, 3 sources).

### Livraison GitHub (même jour)
- PAT fine-grained 30 j (Contents R/W, tous dépôts articro) fourni par l'user via le panneau Connections GitHub (interface) puis collé en chat ; utilisé UNIQUEMENT en variable shell, jamais écrit dans le workspace (exclu snapshots).
- Dépôt **articro/le-31** PRIVÉ créé par l'user ; push commit 8c72719 (98 fichiers) + tag v6 sur main ; release v6 (id 402440043) avec asset LE31_projet_godot_v6.zip (29 835 798 o, state uploaded).
- Liens : https://github.com/articro/le-31 · https://github.com/articro/le-31/releases/tag/v6 · DL : https://github.com/articro/le-31/releases/download/v6/LE31_projet_godot_v6.zip (login articro requis tant que privé).
- Création de repo via API impossible sans permission Administration (volontairement absente du jeton) → repo créé par l'user en UI.
- Procédure v7 : regen+tests+zip, puis push tag v7 + release (jeton à recoller s'il n'est plus en session).

## S6. v7 « détail » (3 octobre 2026, après-midi)
- Question user : « maintenant tu peut me faire des fichier plus gros donc un meilleur jeux plus détailler et plus beau ? » → OUI : release GitHub = 2 Go max, la limite n'est plus la livraison mais la RAM de génération.
- **4K réel sans OOM** : tools/gen_pbr_4k.py = octaves fbm précalculées uint8 pleine résolution, accumulation par bandes 1024 lignes (chevauchement ±1 pour les gradients) → floor_albedo/normal + wall_albedo/normal en 4096², sans couture, micro-détail exclusif 4K (octaves 256/192). 58 s de génération.
- **Audio 44.1 kHz** : SR 22050→44100 dans gen_audio_h (tous les wav stéréo doublés en finesse).
- **Poussière dans le faisceau** : GPUParticles3D 140 motes, box d'émission devant la cam, gravité nulle, billboard alpha, emitting = headlamp_on and state=="play".
- **FOV kick** : cam.fov lerp 78 → 83 en sprint, 84.5 si stamina<0.2.
- Leçons : patchs python multi-ancres = risque de ligne tronquée (fov « , 0 ») et d'indent (1 tab au lieu de 2) → parse Indent ; toujours relire la zone patchée. /tmp tmpfs 993 M : le31push+Godot saturent → OOM gen_pbr_h ; libérer /tmp avant regen.
- Tests v7 : 0 SCRIPT ERROR, audit ALL OK, smart WIN, blind CAUGHT.
- **GitHub v7** : commit + tag v7 poussés, release id 402454614, asset LE31_projet_godot_v7.zip = 50 489 944 o (sans .godot, 102 fichiers). Poids : v5 21.4 → v6 29.8 → v7 50.5 MB, tout en détail utile.
- Workspace : v6.zip supprimé (sur GitHub), assets/.godot retirés après build → du sous le plafond snapshot.

## S7. v8 « C\u0152UR SILENCIEUX » (3 octobre 2026, midi)
- User : concept anomaly-loop trop compliqué (« exemple backroom : monstre + survivre + sortir ») mais INTERDIT de copier Backrooms → idée originale : **stealth sonore** : la silhouette est AVEUGLE, elle entend le bruit du corps du joueur (pas, respiration, c\u0153ur). Une phrase de but : « ELLE EST AVEUGLE. Elle entend ton c\u0153ur. Atteins la porte de sortie. »
- Mécanique : jauge BRUIT (immobile 0.03 / marche 0.32 / course 1.0 + c\u0153ur/respiration) ; rayon d'ouïe = bruit × 14 m ; états patrol/alert/chase ; E = bonbon-appât (bruit ailleurs, 4 s) ; 3 arches-refuges qui se referment (colliders dynamiques) = linéarise l'anneau ; lattes qui craquent (bruit pic 1.2) ; attrapée = jumpscare + retour au refuge (3 captures = fin) ; sortie à t=37.
- Bonbons revisés : sucre = bruit × 0.7 · miroir = (cue whisppers) · reglisse = chase 2.6 · caramel = 1 prise gratuite (graze).
- Graphismes réparés : 4K ABANDONNÉ (sol noir chez user = maps 4K) → retour 3K fiable ; colonne lumineuse verticale (source du « mur traversable ») SUPPRIMÉE ; arches + porte EXIT explicites ; mains reconstruites (paume, 4 doigts, pouce, manchette) ; lumière ambient relevée.
- Audio : music.wav 60 s stéréo 44.1 k (nappe mineure La + pulsation 50 BPM + notes éparses panées + vinyle) à -9 dB ; chuchotements anomalie -6 → -18+dist ; ambient -18.
- HUD : distance EXIT en m + jauge BRUIT rouge + label ; flèche guide permanente vers la sortie.
- Tests : audit 8 steps ALL OK (geometry/arch/segment/bait/hear/caught/win), smart WIN (marche silencieuse), blind CAUGHT (sprint). Leçons : dbg audit avait un `return` early qui coupait IA/bruit → audit déplacé en tête de _process ; entity lifecycle (queue_free sans null + _draw_loop qui rebuild world) → spawn après _draw_loop + guards is_instance_valid.
- GitHub : commit + tag v8, release id asset LE31_projet_godot_v8.zip = 47 561 714 o. v7.zip retiré du workspace.
- Prochain tour (accord user) : pipeline Shorts/TikTok GitHub supervisé (autoshorts / AI-Youtube-Shorts-Generator / clipforge) avec captures user.


## S8. v9 « MAISON HANTÉE » (3 octobre 2026, soir)

Retour utilisateur sur la v8 → 9 exigences, toutes traitées :

1. **Tout ce qui est visible est solide.** Fini l'anneau/les arches : les murs, portes
   (panneaux entrebâillés à 77° avec collider orienté), meubles, voiture du garage,
   baignoire, marches d'escalier, porte de sortie : 112 StaticBody3D vérifiés par l'audit.
2. **Une vraie maison (20 × 14 m)** : salon, cuisine, salle de bains (nord) ; garage,
   cage d'escalier (grenier condamné par des planches), chambre 1, chambre 2 (sud) ;
   couloir central. 7 ouvertures, sols bois/carrelage par pièce, plafond unique, 10 lampes,
   3 affiches, meubles PBR 3K.
3. **Spawns variés + elle ne campe plus la sortie** : entité sur graphe de 10 nœuds (BFS
   avec points de passage aux portes). Patrol aléatoire (1.2 m/s), alerte vers le bruit
   (1.6-1.7), traque (2.4 ; 2.8 sous Réglisse), abandon après 8 s de silence. Spawn
   toujours à > 7 m du joueur et > 4 m de la sortie. Elle ne traverse JAMAIS les murs
   (chemin par les portes).
4. **Musique audible** : music.wav v2 (sub 55 Hz, pad, pulse, cœur, vinyle, notes
   pentatoniques) jouée **dès le menu**, volume_db = -4 dB + curseur (était : -9 dB et
   seulement en jeu).
5. **Monstre qui fait peur** : ~2.5 m, jambes fines, torse conique noir, bras en 2
   segments qui se lèvent en traque, mains à doigts articulés, tête pâle allongée,
   yeux creux noirs, mâchoire béante dentée ; animation procédurale (tremblements,
   head-tilt snap toutes les ~2.7 s en traque, rebonds). Jumpscare : nouveau visage
   `face.png` plein écran.
6. **Belles mains** : viewmodel refait — 4 doigts × 3 phalanges (capsules, courbure
   progressive), ongles, pouce en 2 segments, manche + poignet. Mains du monstre idem.
7. **Sortie = soulagement** : porte EST (panneau EXIT émissif). À < 1.4 m : la caméra
   avance vers la porte, fondu au blanc chaud en 2.4 s, TOUTES les ambiances se coupent
   (drone, vent, maison, musique, tension), carillon, puis écran de fin chaleureux.
8. **Bonbons fonctionnels** : 4 bonbons émissifs posés dans la maison (ramassage à
   < 0.9 m : +1 en poche, carillon, toast, le mesh disparaît). E = lancer un appât à
   2.5 m devant soi : elle y va (testé par l'audit). Effets v8 conservés (Caramel =
   une esquive, Réglisse = elle court plus vite, Sucre = pas plus silencieux, Miroir =
   murmures).
9. **Initiatives** : zones de plancher qui grincent (5 disques, cd 3 s), flèche fantôme
   orientée vers la sortie, HUD = distance restante, intro texte « maison des Harper »,
   tutos réécrits maison, i18n FR/EN complet, caméra de menu qui dérive dans le couloir.

**Tests** (Godot 4.3 headless) : parse 0 erreur ; `--dbg=audit` → AUDIT ALL OK
(bfs/solid/candy/creak/hear/bait/win) ; `--dbg=smart` → WIN ; `--dbg=walk` → CAUGHT ×3 ;
`--dbg=blind` → WIN. Bugs corrigés au passage : colliders `StaticBody3D.shape` (→
CollisionShape3D), portes trop étroites pour la capsule (0.59 → 0.89 m), bot de test en
boucle infinie (chemin jamais terminé).

**Livraison** : `/home/user/LE31_projet_godot_v9.zip` (47 845 855 o, 116 fichiers,
36 png, 13 wav, 49 .import, sans .godot). Push GitHub release v9 en attente d'un token
(le PAT précédent n'est plus dans l'environnement).


### S8bis. Session de suite (équilibrage mesuré + auto-captures)

- **Bots de mesure** ajoutés : `--dbg=quiet` (marche normale, bruit 0.18), `--seed=N`
  (graine aléatoire). Matrice finale : quiet 6/6 WIN · walk (bruyant) CAUGHT×3 ·
  smart WIN · blind WIN · audit ALL OK.
- **Équilibrage entité** (5 itérations mesurées) : marche = ouïe 2.5 m ; sprint = 14 m ;
  chase 3.7 (4.3 Réglisse) > marche 3.4 mais < sprint 5.6 ; réaction : la traque ne
  démarre que si bruit > 0.6 à < 6 m, sinon « alerte » lente 2.2 m/s ; contact en
  patrouille = elle se jette sur toi (stun 1 s + invuln 2 s), pas de mort instantanée ;
  abandon après 7 s de calme ; patrouille 1.15 m/s qui évite le milieu du couloir et ne
  campe pas la sortie ; spawn pièces uniquement (> 7 m du joueur, > 4 m de la sortie).
- **Zones qui grincent** déplacées hors de l'axe obligatoire, posées près des bonbons
  (risque = récompense) + lattes sombres visibles au sol (fair play).
- **Corrections visuelles vérifiées par captures réelles** (Xvfb + Vulkan lavapipe,
  mode `--dbg=shot`) : bannière d'objectif avec retour à la ligne (ancres relatives) ;
  porte EXIT emission 2.2 → 0.5 (texte lisible) ; plâtre teinté 0.60 (était albedo 1.6 =
  rose fluo) ; voiture = carrosserie sombre + toit + vitres ; mains rapprochées ;
  entité : tête agrandie, yeux/mâchoire géants **placés côté -Z (face Godot)**, rim 1.0,
  albedo 0.06, halo omni froid 0.8 attaché (silhouette lisible dans le noir), bras
  semi-levés en traque. Bug trouvé grâce aux captures : `_begin_run` appelait
  `_draw_loop()` deux fois (l'entité spawnée était détruite ; l'IA la recréait en jeu,
  mais pas en mode shot).
- 6 captures de référence : `doc/le31_shots_v9/shot0..5.png` (couloir, salon, cuisine,
  monstre de face, garage, porte de sortie).
- Zip reconstruit : `/home/user/LE31_projet_godot_v9.zip` (47 847 164 o, 116 fichiers).
  Push GitHub release v9 toujours en attente d'un PAT.

## S9 — v10 SHIPPÉE (4 oct. 2026)
- Release v10 = id 403000748, tag v10, 7 assets (zip 47 850 609 o + 6 shots le31_v10_01..06).
- 10 demandes user livrées : maison sombre + torche 9/18 · clés (sortie aléatoire 3 spots + chambre verrouillée) · portes 1,6 m + piliers (audit physique 6 portes) · 3 cachettes sûres (placard ch2 15.8/9.0, alcôve garage 5.9/9.2, escalier 8.0/12.6) · piège collant F (×0,45, 8 s) · monstre animé (jambes LegL/LegR, gait 2.2/6.5, inclinaison) · mains supprimées · 3 spawns (1.2/7, 2.0/2, 11.5/2.2) · props (tapis, cartons, toiles, citrouilles×3, placards) · i18n complet.
- Équilibre v10 : creak 1.0 · give-up 6 s · chase 3.6 · quiet bot 3.5/0.14.
- Matrice : audit ALL OK (91 bodies) · quiet 5/6/9/10 WIN · smart WIN · blind WIN · walk CAUGHT×3.
- LEÇONS : spawn DANS bbox voiture = stuck bot ; node final derrière palier escalier inaccessible y=0 ; transparency_mode = prop Godot 3 (utiliser .transparency) ; ConeMesh absent en Godot 4 (CylinderMesh top_radius 0) ; spam "Parameter m is null" = pré-existant headless dummy, inoffensif GPU.
- Grenier condamné v10 ; étage complet = v11 sur demande. Token user à révoquer.
- MAJ v10 (même release 403000748, tag v10 déplacé) : ÉTAGE jouable ajouté — rampe visuelle + 24 marches colliders OUEST garage (x 0.9-2.1), transfert guidé 2,5 s (stair_t/stair_dir, triggers bas z 13.1-13.85 / haut z 8.35-9.1), dalle trémie x 0.8-2.2 z 8.3-9.2, murs hauts y 2.98-5.2 + toit 5.3, cloison x 12.5 porte z 6.2-7.8, props (matelas, lit, cartons, tapis, fenêtre émissive, placard-cachette 18.8/2.2), 2 omni (1 allumée). Graphe : NODES 10-12 étage + 13 pied rampe, NODE_LVL, EDGES [6,13],[13,10],[10,11],[10,12] ; _node_of(p, lvl) ; ent_level/player_level/bot_level/bait_level/entity_target_lvl ; hear ×0.25 cross-level ; contact |dy|<1.2 ; mode2 cross-level via BFS mid ; terrain_y quantifié marches ; voiture/roues/étagère décalées est ; node 6 → (4.5,9.3) ; spots clés A4 (15.8,3.0,2.98) B4 (6.5,2.5,2.98), candy 5e (16.2,11.5,2.98), hide 4e (18.8,2.2,2.98) + alcôve garage → (3.0,9.0) ; bot : clé étage = cheat au pied rampe ; audit step 5 = montée réelle 420 frames input forcé (dbg_move_frames/dbg_move_dir) + step 6 check + step 7 win.
- LEÇONS v10bis : move_and_slide ×N dans 1 frame = solver instable (tester via frames réelles) ; plan incliné 30-41° = jam capsule (même thick) ; assist lift sans restore = risque ; is_on_wall non fiable sur pente ; velocity perd composante horizontale après slide mur ; GDScript var de boucle = scope fonction (pas de redécla) ; else s'attache au if intermédiaire inséré ; override input doit précéder `if mv.length_squared()` ; grep sans accent = faux négatif.
