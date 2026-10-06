# LE 31 — v20 « VISAGE » puis v20b « MÂCHOIRE »

> Version consacrée **uniquement à la créature**, comme demandé. Objectif : qu'au lancement on voie un monstre crédible.
> HUD : **`v20 VISAGE`** en haut à droite. **Si tu ne lis pas ce texte, tu joues une vieille version.**

## Ce qui n'allait pas (et pourquoi)

Le monstre des v13→v18 était **découpé en 10 morceaux rigides** (un bras, une cuisse, une tête…) collés les uns aux autres, avec des **boules aux articulations** pour cacher les coupes. C'est une méthode d'assemblage : ça ne peut pas donner un résultat propre — d'où les boules visibles sur tes captures, les **trous aux coudes** et les épaules déformées.

## Ce que j'ai fait

J'ai **abandonné l'assemblage par morceaux** et construit un **vrai personnage skinné**, comme dans un jeu professionnel :

| | Avant (v18) | Maintenant (v19) |
|---|---|---|
| Maillage | 10 morceaux rigides | **1 seul maillage continu** (99 897 triangles) |
| Articulations | boules visibles aux épaules/coudes/genoux/hanches | **aucune boule** — la peau se déforme (skinning par poids de sommets) |
| Squelette | 0 os | **21 os** (bassin, colonne, nuque, tête, clavicules, bras, avant-bras, mains, cuisses, tibias, pieds, orteils) |
| Pieds | patinaient au sol | **IK à 2 os** : le pied se pose, se verrouille au sol, pousse, décolle |
| Démarche | jambes balancées en sinus | **phase pilotée par la distance parcourue** (comme un vrai jeu) |
| Corps | rigide, penché en bloc | buste qui accompagne la vitesse, roulis dans les virages, respiration |
| Tête | fixe | **elle te suit du regard** (limites anatomiques) + micro-tics |
| Bras | écartés (défaut de la pose d'origine) | **pendants en rôde/marche, tendus vers toi en chasse** (angles mesurés, pas devinés) |
| Transitions | sauts brusques | **fondu automatique** entre rôde / alerte / chasse / recul / bond |

**Comment j'ai vérifié (mesures en moteur, pas à l'œil)** — `--dbg=rig` :

```
pénétration du pied dans le sol : -0,008 m   (8 mm : invisible)
piétinement pendant l'appui      : 2,5 cm pour 12 cm d'avancée par image (bruit de mesure)
os : 21 | chaîne de jambe : 0,342 | bassin ↔ cheville : 0,415 / 0,090
```

Le piétinement a été supprimé en trois étapes, chacune vérifiée : (1) l'appui dure 62 % du cycle, la phase devait donc avancer de `distance/0,62` et non `distance` — le pied reculait 1,61 fois trop vite ; (2) l'inclinaison du bassin n'était pas retranchée des jambes (12 cm de décalage) ; (3) l'oscillation du bassin rallongeait la jambe et faisait flotter le pied de 7 cm — compensée.

## Les autres reproches de ta liste, traités dans cette version

| Reproche | État |
|---|---|
| « il rentre toujours dans les murs » | rayon de collision porté à **0,50 m** + **déclic anti-blocage** : si elle n'avance plus d'au moins 45 cm en 1,6 s alors qu'elle te traque, elle se replace 7 à 30 m plus loin, sur le même étage. Fini le monstre figé contre un mur. |
| « il reste bloqué là où j'apparais » | l'apparition est calculée au point **le plus éloigné possible** de toi (déjà en v18), et le repli anti-blocage choisit toujours un point **à plus de 7 m de toi**. |
| « l'étage supérieur on peut toujours pas y aller » | **cause trouvée** : la rampe de l'escalier du garage était **purement décorative** (aucun collider). Le joueur butait sur chacune des 24 marches. Le collider de pente est ajouté → l'escalier se monte. |
| « met-la loin au début » | inchangé + renforcé : première apparition au nœud le plus lointain, réveil également au point le plus lointain. |

## v20 : le visage et la peau (nouveau)

Tes captures montraient aussi un visage « déformé ». J'ai vérifié : la géométrie du crâne contient bien des orbites
et une bouche, mais elles étaient **invisibles** — la texture d'origine était beige et uniforme.

Ce que j'ai fait, sans toucher au maillage (donc sans aucun risque de le casser) — tout est peint **en espace UV** :

1. **Carte de cavité** calculée sur le maillage : pour chaque sommet, on mesure sa concavité locale (écart à la
   moyenne de ses 12 voisins, projeté sur la normale). Les creux s'assombrissent tout seuls → orbites, bouche,
   narines, plis du cou, aisselles, entre les orteils.
2. **Orbites renforcées** (318 sommets) : deux puits noirs, le « regard vide ».
3. **Extrémités refroidies** : mains, pieds et visage assombris et virés au gris-bleu (le sang s'en va).
4. **Crasse** : bruit basse fréquence + assombrissement des parties basses.
5. **Teinte cadavre** : fini le beige argile, la peau est terne et marbrée.
6. **Arêtes saillantes légèrement éclaircies** (+8 %) : la forme se lit même dans le noir.

La texture est passée de `beige uniforme (0,306 de luminosité moyenne)` à `cadavre marbré (0,285)`, avec les creux à
**0,074** et les orbites à **0,105** (contre 0,306 partout avant).

**Correction trouvée au passage** : en chasse, un bras partait vers l'avant et l'autre vers l'arrière (erreur de
signe sur le lacet des épaules). Corrigé : **les deux bras se tendent vers toi**.

## Où j'en suis honnêtement

- **Ce qui est fait** : le monstre n'est plus un assemblage — c'est un personnage skinné, animé, mesuré, qui te suit du regard et dont les pieds se posent au sol.
- **Ce qui reste** : la **mâchoire animée** (une vraie bouche qui s'ouvre pendant la chasse nécessite d'ajouter des dents et une mâchoire mobile au maillage — c'est la prochaine étape), puis les 4 props 3D, l'extérieur nuit et les 8 trophées.
- **Ce que j'aimerais que tu me dises** si tu n'es pas convaincu : est-ce la démARCHE, la SILHOUETTE, ou le VISAGE qui te dérange ? Une capture de ce qui te choque me suffit.

## Vérifications automatiques

```
--dbg=rig    → pénétration -0,008 m | patinage 2,5 cm/image | 21 os      [créature]
--dbg=audit  → AUDIT ALL OK (bodies=123)                                [maison + rampe]
--dbg=m2     → total_tris=99897                                         [3 modèles dispo]
--dbg=mvis   → 37/37 points, angle ≤ 7,3°, occultation 0                [menu]
--dbg=quiet  → EVT WIN catches=0                                        [partie gagnable]
```

`main.gd` : 5 122 lignes. Nouveau fichier de référence : `assets/models/monstre_rig.glb` (+ `monstre_sole.json` pour les points de contact des pieds).

## Reproduire

Tout est reproductible : `tools/rig_monstre.py` (squelette + poids de sommets), `tools/skin_tex.py` (peau et visage peints en UV), `tools/sole_extract.py` (points de contact des pieds), `tools/anim_ref.py` (animation, portée à l'identique dans le jeu), `tools/anim_check.py` (mesures et rendus).


---

# v20b « MÂCHOIRE » (correctif de la v20)

La v20 avait un visage, mais bouche fermée : muet, sans dents. La v20b lui donne une mâchoire
qui bouge et une bouche noire.

## Ce qui change

- **Os `jaw`** (22 os au total) : le bas du visage suit la mâchoire. Le menton descend quand la
  bouche s'ouvre — vérifié au rapporteur : 0,34 rad = 20°.
- **10 dents** (5 en haut, 5 en bas) et **une cavité buccale** peinte en noir : la bouche ouverte
  n'est plus un trou dans la peau.
- **Placement mesuré, pas deviné** : un test automatique (`tools/test_dents.py`) vérifie que
  *aucune* dent ne dépasse la peau du visage. Résultat : **0 dent visible / 70**.
  Les dents sont plantées 1,1 cm en retrait ; la bouche au repos paraît fermée.
- **Ouverture animée** : 2° en rôde, 6° en alerte, 20° en chasse (avec des claquements rapides),
  34° quand il recule en hurlant, 26° au bond.
- **Bras resserrés en chasse et au bond** : ils pendaient écartés de 40° sous les épaules
  (le « monstre qui écarte les bras bizarrement »). Ils tombent maintenant le long du corps,
  tendus vers l'avant. C'est plus proche d'une démarche de prédateur.
- **Deux bugs corrigés dans le générateur** : la cavité buccale n'était jamais ajoutée au maillage
  (7 sommets perdus, 6 triangles pointant dans le vide) et le décalage des dents s'appliquait
  après l'assemblage — donc jamais. Les deux sont réparés et contrôlés par le test.

## Mesures

```
--dbg=rig    os=22 · triangles 99 983 · pénétration du pied -0,008 m · patinage 2,5 cm/image
--dbg=audit  AUDIT ALL OK
--dbg=m2     RIG SKINNE os=22 tri=99983
--dbg=mvis   37/37 points, 7,3°, occultation 0
```

## Correctifs v18/v19 toujours en place

Plein écran, HUD allégé, inventaire (touche **I**), décor enrichi, monstre rôdant dans le menu,
sons refaits, créature skinnée (maillage continu), IK des jambes sans patinage, tête qui te suit,
déclic anti-blocage, **escalier du garage accessible**.
