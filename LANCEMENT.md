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
- **L'ÉTAGE** : l'escalier du garage (ouest) monte à un étage sombre (2 zones : grenier
  aménagé à l'ouest, chambre à l'est). Elle entend mal à travers le plancher — mais elle
  monte très bien quand elle te traque. Clé, bonbon et cachette peuvent s'y trouver.
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

## 7. NOUVEAU — v11 « VISION » (corrections des captures du 04/10)
Bug racine trouvé et corrigé : les « sols », le « plafond » et plusieurs « murs » étaient en réalité
des plans **verticaux** (normale (-1,0,0) mesurée par test Godot) → sol invisible, mur fantôme au
centre des pièces, murs disparaissant selon l'angle. Tout est passé en **boîtes pleines** :
- sols : 8 dalles-boîtes par pièce, texturées par pièce, aucun trou ni z-fighting ;
- murs : boîtes (visibles des deux côtés) ;
- plafond : dalles de l'étage, trémie de l'escalier ouverte ;
- tapis, lattes grinçantes, flaque de sucre, fenêtre de l'étage : remis à plat ;
- flèche au sol : plaque horizontale 0,8 m, orientée correctement (elle pointait à 180°), discrète ;
- monstre redessiné : 2,3 m, dos voûté, bras longs, mains osseuses, tête aveugle dégagée, 7 loques.

**Si ton GPU est Intel/Arc ou un pilote logiciel** : SDFGI + brouillard volumétrique sont coupés
automatiquement au démarrage (causes connues de surfaces noires). Nouvelle touche **F2** :
bascule Haute/Basse qualité en jeu (un message s'affiche).

**À vérifier en jeu** : sol partout, plafond, murs sans trous, flèche plate devant toi,
monstre dans le couloir (pose de la capture n°4 : approche-le en allumant la lampe G).
