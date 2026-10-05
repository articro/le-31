# LE 31 — version 13 « CLAIRVOYANCE » (2026-10-05)

**Le monstre n'est plus un assemblage de primitives : c'est un vrai modèle 3D sculpté par IA.**

## Ce qui change
- **Modèle 3D réaliste** (`monstre.glb`, généré avec TRELLIS.2 — Microsoft Research, licence MIT) :
  **96 251 triangles**, peau texturée **1024²**, relief (normal map) + rugosité, silhouette voûtée de
  **2,35 m** aux membres démesurés. Découpé en 4 parties animables : corps, tête, jambe gauche, jambe droite.
- **Animations rebranchées sur le modèle** : balancement des jambes depuis les pivots de hanches,
  tête qui dodeline puis se tend en chasse, corps qui tangue, inclinaison avant en course.
- **Sons 3D dans le corps du monstre** : souffle, **grognement** (3,2–6 s en chasse), **reniflement**
  (< 5,5 m quand il te cherche) — ils tournent maintenant *autour* de la silhouette.
- **CORRECTION IMPORTANTE d'orientation** : le monstre marchait **à l'envers** depuis la v11
  (il regardait dans le sens opposé à sa marche). Corrigé : il fait maintenant face à sa direction,
  en patrouille comme en chasse, avec une rotation fluide dans les virages.
- **Refus offert** : le monstre en primitives reste dans le jeu. Lance avec `--dbg=nomodel` pour comparer
  les deux en direct (et si les fichiers du modèle sont absents, le jeu bascule tout seul dessus).
- Marqueur de version en jeu : **v13 CLAIRVOYANCE** (coin haut-droit).

## Validation
- `AUDIT ALL OK` (122 bodies) avec le modèle 3D en place.
- Bot `quiet seed 5` : **WIN (2 prises)** — partie complète terminée avec le nouveau monstre.
- Fichiers vérifiés : 4 OBJ chargés (52 159 / 2 146 / 10 244 / 9 646 sommets), texture 1024².

## Installation
Télécharger `LE31_projet_godot_v13.zip`, l'extraire, ouvrir le dossier dans **Godot 4.3** et lancer
(le premier lancement importe les modèles, ~45 s). Rien d'autre à faire.

## Réglages de génération (reproductible)
`monstre_front.png` (photo de face) → Space TRELLIS.2 → Res 1024, Decimation **100000**, Texture **1024**
→ Extract GLB. Pour une autre variante : relancer avec le même fichier, seed aléatoire — l'intégration
est automatique.

## Interdit
Aucune référence aux Backrooms, aucun itch.io, aucune musique commerciale. Tout est libre de droits (MIT/CC0).
