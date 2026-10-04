# LE 31 — MAISON HANTÉE (v9) — LANCEMENT DANS GODOT (FR)

## 1. Installer Godot
- Télécharge **Godot 4.3 STABLE, version « Standard »** (pas .NET / pas 4.4+) :
  https://godotengine.org/download/archive/4.3-stable/
- Aucune installation : dézippe et lance l'exécutable.

## 2. Ouvrir le jeu
- Dézippe `LE31_projet_godot_v9.zip` où tu veux (le dossier `hantise/`).
- Dans Godot : Manager → Import → sélectionne `hantise/project.godot` → Import & Edit.
- Au premier lancement, laisse Godot réimporter les assets (~1-2 min, une seule fois).
- Appuie sur **F5** (ou le bouton Lecture). Choisis FRANÇAIS ou ENGLISH. Ça tourne.
- La musique commence **dès le menu** : vérifie le volume dans OPTIONS si besoin.

## 3. Le but (rappel)
- Tu es dans une **vraie maison** : salon, cuisine, salle de bains, garage, cage d'escalier
  (grenier condamné), deux chambres, couloir central. La **porte de sortie est à l'EST**.
- Une flèche fantôme au sol pointe toujours vers la sortie.
- **ELLE est aveugle, mais elle entend ton cœur et tes pas.** Marche doucement.
  Courir (MAJ) = du bruit = elle te traque. Elle abandonne après ~8 s de silence.
- Ramasse les **4 bonbons** qui brillent. **E** = en lancer un : elle va voir ailleurs.
- Certaines zones de plancher **grincent**. Si elle te touche : jumpscare, tu te réveilles
  à l'entrée. **3 prises = game over.** Sors vivant.

## 4. Contrôles
- ZQSD / WASD / flèches : marcher · MAJ : courir (endurance !) · SOURIS : regarder
- **G** : lampe torche · **E** : lancer un bonbon · **V** : grain VHS · ÉCHAP : pause
- OPTIONS : volumes (musique / effets), sensibilité souris, VHS, qualité.

## 5. Config graphique
- Rendu **Forward+** : PBR 3K (albedo+normal+roughness+AO) générés maison,
  brouillard volumétrique, SDFGI, glow/bloom, tonemap ACES, 10 lampes avec ombres.
- PC modeste ? Menu OPTIONS → qualité basse (coupe brouillard, SDFGI, glow, ombres).

## 6. Vérifié avant livraison (headless, Godot 4.3)
- **AUDIT ALL OK** : chemin BFS entrée→sortie, 112 colliders solides, ramassage bonbon,
  grincement, ouïe (elle entend le bruit), appât (E attire), victoire à la porte EST.
- Bot prudent → **WIN** · Bot bruyant → **CAUGHT ×3** · Entité sourde → WIN.
- Zéro asset externe : textures, PBR, audio et visuels 100 % générés par le pipeline maison
  (`tools/regen_h.sh`).
