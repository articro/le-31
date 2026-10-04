# LE 31 — MAISON HANTÉE (v10) — LANCEMENT DANS GODOT (FR)

## 1. Installer Godot
- Télécharge **Godot 4.3 STABLE, version « Standard »** (pas .NET / pas 4.4+) :
  https://godotengine.org/download/archive/4.3-stable/
- Aucune installation : dézippe et lance l'exécutable.

## 2. Ouvrir le jeu
- Dézippe `LE31_projet_godot_v10.zip` où tu veux (le dossier `hantise/`).
- Dans Godot : Manager → Import → sélectionne `hantise/project.godot` → Import & Edit.
- Au premier lancement, laisse Godot réimporter les assets (~1-2 min, une seule fois).
- Appuie sur **F5** (ou le bouton Lecture). Choisis FRANÇAIS ou ENGLISH. Ça tourne.
- La musique commence **dès le menu** : vérifie le volume dans OPTIONS si besoin.

## 3. Le but (rappel v10)
- Tu es dans une **vraie maison** : salon, cuisine, salle de bains, garage, cage d'escalier
  (grenier condamné), deux chambres, couloir central. La **porte de sortie est à l'EST**.
- La maison est **SOMBRE** au lancement : ta lampe torche (G, allumée par défaut) est vitale.
- La sortie est **VERROUILLÉE** : trouve la **clé dorée** (position aléatoire à chaque partie).
  Une **2e clé** ouvre la chambre verrouillée du couloir Sud (bonbon + placard à l'intérieur).
- Une flèche fantôme au sol pointe toujours vers la sortie.
- **ELLE est aveugle, mais elle entend ton cœur et tes pas.** Elle MARCHE en patrouille et
  COURT quand elle te traque. Courir (MAJ) = du bruit. Elle abandonne après ~6 s de silence.
- Ramasse les **4 bonbons** qui brillent. **E** = en lancer un : elle va voir ailleurs.
  **F** = poser un piège de **sucre collant** : elle y reste engluée et ralentie (~8 s).
- **3 CACHETTES** où elle ne peut rien contre toi : placard de la chambre 2, alcôve du garage,
  renfoncement de l'escalier. Dedans, elle t'oublie — mais ne reste pas toute la nuit.
- **3 points d'apparition** aléatoires au départ et après chaque prise.
- Certaines zones de plancher **grincent**. Si elle te touche : jumpscare, tu te réveilles
  à l'entrée. **3 prises = game over.** Sors vivant.

## 4. Contrôles
- ZQSD / WASD / flèches : marcher · MAJ : courir (endurance !) · SOURIS : regarder
- **G** : lampe torche · **E** : lancer un bonbon · **F** : piège collant · **V** : grain VHS · ÉCHAP : pause
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
