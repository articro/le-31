# NOTES DE SORTIE — LE 31 v11 « VISION »
_2026-10-05 — corrections issues des captures in-game de l'utilisateur_

## BUG RACINE CORRIGÉ (cause de « les murs disparaissent / le sol n'est pas là »)
Un test Godot (`PlaneMesh` + rotation) a prouvé que les quads appelés « sol », « plafond »
et « murs » étaient en réalité des **plans VERTICAUX** :
- `_room_floor` : rotation (PI/2, 0, PI/2) → normale (-1, 0, 0) = **mur vertical au centre de chaque pièce**.
  Le sol était donc invisible de dessus, et ce mur fantôme est la grande surface beige/pâle des captures
  (et la « caméra dans la géométrie » quand le joueur le traversait).
- `_wall_seg` : quad avec normale dépendante de l'ordre des points → **plusieurs murs invisibles de l'intérieur**.
- `_quad` (plafond, tapis, lattes, flaque collante) : mêmes erreurs d'orientation → plafond = mur fantôme
  qui coupait la maison en deux, tapis/lattes/flaque debout et non au sol.

## CORRECTIONS
1. **Sols** : chaque pièce a désormais une vraie **dalle-boîte** (0,10 m) — visible, texturée par pièce,
   plus de z-fighting, plus de mur fantôme. La couverture est totale (8 dalles).
2. **Murs** : tous les `_wall_seg` sont des **boîtes** (invisibles d'aucun côté, jamais de « trous »).
3. **Plafond** : les dalles de l'étage (2,82–2,98) font office de plafond ; la trémie de l'escalier
   reste ouverte. Le quad-plafond fautif est supprimé.
4. **Affiches** : les images regardent enfin le joueur (elles étaient tournées vers le mur).
5. **Tapis, lattes grinçantes, flaque de sucre, fenêtre de l'étage** : remis à plat.
6. **Flèche au sol** : plaque horizontale de 0,8 m devant le joueur, orientée vers la sortie,
   émission ÷3, fondu selon la distance, disparaît près de la porte. Plus de halo géant.
7. **Monstre (« ELLE ») — refonte de silhouette** : 2,3 m, dos voûté (bosse), torse en carène,
   bras très longs tombant sous les genoux, mains osseuses à 12 phalanges, tête aveugle enfoncée
   entre les épaules avec sourcils, mâchoire fendue, 5 dents, yeux cousus, 7 lambeaux en jupe,
   pieds digitigrades. Animation conservée (jambes LegL/LegR, bras, tête, inclinaison, dandinement).
8. **Preset graphique SÛR auto-détecté** : si le GPU est Intel/Arc/llvmpipe/lavapipe,
   SDFGI + fog volumétrique sont désactivés au démarrage (instables sur ces pilotes → surfaces noires).
   Ajout du réglage + **touche F2** pour basculer Haute/Basse qualité en jeu (toast de confirmation).
9. Ambiance légèrement remontée (ambient 0,30) pour ne plus jamais tomber au noir absolu.

## VALIDATION
- Audit : **AUDIT ALL OK** (122 bodies) après patch.
- Matrice bots : voir `doc/matrice_v11.log`.
- Captures de contrôle : `doc/shots_v11/` (à juger sur PC, GPU Arc A750).

## À FAIRE CÔTÉ UTILISATEUR
1. Lancer le projet (F5) et comparer avec les 5 captures de bug.
2. Si ça convient : push v11 sur GitHub (PAT) → tag + release + zip + captures.
3. Remettre le repo en privé après usage, révoquer le PAT.
