# LE 31 🎃

Jeu d'horreur **anomaly-loop** (FPS) pour Halloween 2026 — Godot 4.3, Forward+.
Sortie prévue avant le 31 octobre 2026. FR / EN.

## Le principe
Vous êtes coincé dans un couloir de maison hantée, version 31 OCT 1997 sur une vieille télé.
À chaque traversée, quelque chose change — ou pas. Passez la porte au bout (t=31) uniquement
quand le couloir est **normal**. Erreur = retour à la case départ. 3 erreurs = quelqu'un vient vous chercher.

## Identité du jeu (ce qui n'existe nulle part ailleurs)
- **Bonbons Maudits** : draft tactile 1/2 à chaque passe propre (miroir, réglisse, caramel, sucre),
  poche max 3, **E pendant une chasse = lancer un bonbon** pour figer la silhouette 2,5 s.
- **Corps incarné** : mains visibles, endurance limitée, respiration et cœur audibles.
- **Vieille télé qui bugue** : shader CRT/VHS (tears, jitter, franges, interlace, OSD ▶ PLAY).

## Lancer le jeu
1. Installer [Godot 4.3](https://godotengine.org/download) (version standard, pas .NET).
2. Ouvrir `project.godot` depuis ce dépôt (ou décompresser la release zip).
3. F5 (ou ▶). Voir `LANCEMENT.md` pour les détails et commandes.

## Commandes
ZQSD/WASD/flèches : se déplacer · MAJ : courir (endurance !) · Souris : regarder ·
G : lampe torche · E : lancer un bonbon (chasse) · 1/2 : choisir un bonbon (draft) · ESC : pause.

## Contenu technique
PBR procédural 3K (16 maps), 12 wav stéréo générés (drone 45 s, vent, maison, tension de chasse),
12 anomalies, collisions physiques réelles (CharacterBody3D + StaticBody3D).
Tout est généré par script (`tools/`), zéro asset téléchargé, zéro budget.

© 2026 articro — dépôt horodaté faisant preuve d'antériorité.
