# LE 31 — v19 « MONSTRE »

> Version consacrée **uniquement à la créature**, comme demandé. Objectif : qu'au lancement on voie un monstre crédible.
> HUD : **`v19 MONSTRE`** en haut à droite. **Si tu ne lis pas ce texte, tu joues une vieille version.**

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

## Où j'en suis honnêtement

- **Ce qui est fait** : le monstre n'est plus un assemblage — c'est un personnage skinné, animé, mesuré, qui te suit du regard et dont les pieds se posent au sol.
- **Ce qui reste** : le **visage**. Le maillage vient d'une IA de sculpture : il n'a **ni yeux ni mâchoire ouverte**. À 2,80 m, avec les cheveux en moins, ça se voit de près. C'est la prochaine chose que je fais : yeux creux + mâchoire fendue sculptés dans le maillage et animés (la bouche qui s'ouvre pendant la chasse, c'est ce qui fait le plus peur).
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

Tout est reproductible : `tools/rig_monstre.py` (construction du squelette et des poids de sommets), `tools/anim_ref.py` (l'animation, portée à l'identique dans le jeu), `tools/anim_check.py` (mesures et rendus de contrôle).
