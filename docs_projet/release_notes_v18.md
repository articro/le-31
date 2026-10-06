# LE 31 — v18 « QUALITÉ »

> Version corrective issue des 6 captures du 06/10/2026. **Objectif : tuer la liste de reproches avant de continuer le contenu.**
> HUD : **`v18 QUALITE`** en haut à droite (si tu ne vois pas ce texte, tu joues une vieille version).

## Corrigé, point par point

| Reproche | Correction v18 |
|---|---|
| « plein écran → le jeu reste sur le côté gauche » | `project.godot` : `stretch/mode="canvas_items"` + `aspect="expand"` + `resizable=true`. Le jeu remplit désormais tout l'écran, quelle que soit la résolution (le rendu s'adaptait mal en `disabled`). |
| « il est trop petit, grandis-le » | Constante `ENT_SCALE = 1,191` appliquée aux trois modèles du monstre : il passe de **2,35 m à 2,80 m**. |
| « le monstre quand il poursuit il est de dos » | L'orientation était calculée à l'envers (`atan2(x, z)`) : corrigée en `atan2(mv2.x, mv2.y)`. Il regarde maintenant **le joueur**, face à lui, en chasse. |
| « il écarte les bras bizarrement » | Suppression de l'écartement forcé des bras pendant la poursuite : le balancement redevient une **course naturelle** (épaules basses, alternance avant/arrière). |
| « il va dans les murs, je ne veux pas » | Nouveau test `_ent_can_stand()` (SphereShape3D **rayon 0,42**, mask 1) qui refuse tout déplacement qui traverserait la géométrie, avec **glissement le long des murs** au lieu d'un arrêt sec. |
| « les escaliers sont toujours bouchés avec des objets » | Garde dans `_furn()` : tout meuble placé dans la boîte de l'escalier du garage (**x 0,30→2,70 / z 6,60→13,20 / hauteur < 2,20 m**) est déplacé à **x = 6,6**. La cage d'escalier reste vide. |
| « il y a deux barres sur l'interface, enlève-les » | **Barres de bruit et d'endurance supprimées.** Remplacées par une **pastille de bruit** discrète (elle pulse quand tu fais du bruit) et un **libellé d'endurance** qui n'apparaît que sous 55 %. |
| « l'interface est trop vide → un fond avec le monstre qui rôde » | **Menu principal refait** : la créature **patrouille en arrière-plan du menu** (créée dès l'écran-titre, elle n'existait avant qu'après le lancement d'une partie !), la caméra est plantée au bout du couloir et la regarde aller et venir **entre 6 et 14 m**, cadrée en permanence (vérifié par raycasts : `angle ≤ 7,3°`, **0 occultation**, 37 mesures sur 30 s de patrouille). |
| « le décor est toujours super pauvre » | Nouveau décor riche `_decor_rich()` : **~80 objets** ajoutés — 12 cadres photo muraux, 5 tapis, 16 cartons empilés, bouteilles, jouets d'enfant, chaussures, piles de livres, assiettes sales, toiles d'araignée, ampoules suspendues avec leur lumière. |
| « un fonctionnement pour voir ce qu'on possède » | **Inventaire (touche I)** : panneau listant clé, bonbons, sucre collant, piles, batterie, cassette — avec compteurs en direct. |
| « change les sons, je ne comprends pas quel bruit va avec quelle action » | **Sons refaits un par un**, avec une identité claire : pas = claquement de semelle net ; monstre = 38/57 Hz + craquement d'os ; grincements de plancher = CRIIIC long + **CRAC final** ; **2 sons neufs** : `door_creak` (porte qui s'ouvre) et `lock` (mécanique de serrure). Le verrou qui résiste, la porte qui s'ouvre et le tintement de clé sont maintenant **trois sons différents et reconnaissables**. |
| « je veux des bruits de grincement » | 3 variantes de grincement (long / court / aigu, transposées aléatoirement) sur les lattes du plancher, + grincement de porte dédié. |

## Bonus (bug majeur trouvé au passage)

- **Le shader Hi8 du caméscope n'avait jamais compilé** : un `:=` (syntaxe GDScript) traînait dans un fichier de shader → `SHADER ERROR` à chaque partie depuis la v14, et **la vision nocturne du caméscope était muette**. Corrigé : le caméscope a enfin son grain, sa teinte et son vignettage.
- **Bug d'initialisation** : un bloc d'affectations s'exécutait avant la création des nœuds HUD → `_ready()` s'interrompait et **certaines parties n'avaient aucun corps physique** (`bodies=0` au lieu de 122). Corrigé.

## Volumes rééquilibrés (testés en jeu)

| Son | Volume |
|---|---|
| pas (marcher / accroupi) | −5 / −13 dB |
| grincement de plancher | −2 / −3 / −4 dB ×3 variantes |
| monstre (pas, grognement) | −8 dB |
| porte : verrou / ouverture | −3 dB / −4 dB |
| clé, papier, appareil photo | cristallins, audibles même sous la respiration |
| cœur / chuchotements | −18 à −24 dB (nappe de fond, pas de masquage) |

## Vérifications automatiques

```
--dbg=audit   → AUDIT ALL OK  (bodies=122)          [122 corps physiques, maison intacte]
--dbg=m2      → total_tris=99897                    [le monstre 3D a bien ses 10 parties]
--dbg=mvis    → 37/37 points : angle ≤ 7,3°, occultation 0   [monstre du menu visible]
--dbg=quiet   → EVT WIN catches=0                   [partie gagnable de bout en bout]
```

`main.gd` : 4 628 lignes. Toutes les parties du monstre (10 morceaux, 99 897 triangles) sont en place.

## Prochaine étape (v19)

- Props 3D restants (`key_cave`, `prop_tv_crt`, `prop_poupee`, `prop_horloge`, clé dorée) : génération TRELLIS dès que le quota du compte est rechargé (07/10).
- Extérieur nuit + ciel, 8 trophées internes.
- Si un point de la liste ci-dessus n'est **pas** réglé sur ta machine, dis-le moi avec une capture : c'est cette liste qui pilote la v19.
