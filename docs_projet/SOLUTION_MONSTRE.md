# SOLUTION — UN MONSTRE QUI FAIT PEUR ET « RÉALISTE »
_LE 31 — 5 octobre 2026. Réponse à la demande : « donne-moi une solution pour avoir un monstre qui fait
peur et très réaliste »._

## Ce qui fait PEUR (avant d'être réaliste)
Dans un jeu d'horreur, la peur vient dans cet ordre :
1. **Le son** — on entend avant de voir. (Rappel : ELLE est aveugle, elle écoute.)
2. **Le mouvement** — une démarche « pas humaine » (traînante, saccadée, trop rapide en chasse).
3. **La silhouette** — proportions fausses (bras trop longs, tête enfoncée, dos voûté).
4. **La matière** — peau, veines, humidité, os (c'est ce qui manque le plus chez nous).
5. **La mise en scène** — lumière, distance, apparitions partielles (le cerveau complète le reste).

## ÉTAGE 1 — CE QUI EST FAIT MAINTENANT (v12.2, sans rien te demander)
- **Peau texturée** : texture cadavérique générée (albedo) + **normal map** (relief : veines, plis, pores)
  + **carte de rugosité** — appliquées aux membres, au torse, à la tête.
- **Sous-surface (SSS)** : la peau laisse passer un peu de lumière de la lampe torche → effet chair
  (« vivant ») au lieu du plastique.
- **Loques** : relief de tissu (normal map) pour que les lambeaux accrochent la lumière.
- **Grognement 3D** : elle **grogne pendant la chasse** (toutes les 3-6 s), volume positionnel.
- **Reniflement 3D** : quand elle est à moins de 5,5 m, elle **renifle** — tu sais qu'elle est là,
  tu ne la vois pas. (C'était déjà le cas pour la respiration.)
- **Résultat** : le même corps, mais une matière crédible + une présence sonore qui fait monter la pression.

## ÉTAGE 2 — LE VRAI « RÉALISTE » (pipeline complet, si tu veux y aller)
Objectif : un monstre **sculpté par IA** (mesh détaillé, texture 4K) **animé** comme aujourd'hui.

### Étape A — Images de référence (fait : `doc/props_ia/monstre_vue_face.png`, `monstre_vue_cote.png`)
Vue de face + vue de profil, fond gris uni, pose neutre. C'est le carburant des IA 3D.

### Étape B — Image → 3D (gratuit, navigateur, 2 min)
- **huggingface.co/spaces/microsoft/TRELLIS.2** (Microsoft, MIT ✅) : téléverse une vue → **GLB**.
  Pour plus de fidélité : les Spaces acceptent souvent plusieurs vues (face + profil).
- Alternative « low-poly PS1 » : **stabilityai/TripoSR** (MIT).
- ❌ **Hunyuan3D-2 interdit** (licence hors UE — tu es à Paris).
- Ton Arc A750 n'a pas CUDA : **c'est le GPU du Space qui travaille**, pas le tien.

### Étape C — Nettoyage + rig (Blender gratuit, ~30-60 min)
1. Import du `.glb`, échelle à **2,3 m**, centrage à l'origine (pieds à y = 0).
2. **Décimation** si besoin (100 k → 25 k triangles).
3. **Rig automatique** : Mixamo (gratuit, upload du mesh, auto-rig humanoïde + animations walk/run/idle)
   → export **FBX** → reconversion en **GLB** dans Blender (Godot 4.3 ne lit pas le FBX nativement).
   Si la pose/les proportions gênent Mixamo : rig basique dans Blender (Rigify).
4. Vérifier : la tête, les bras et les jambes doivent bouger comme aujourd'hui.

### Étape D — Intégration (moi, ~2-3 h)
- Remplacer les maillages procéduraux par le modèle (`assets/models/monstre.glb`), en **gardant toute
  l'IA de gameplay** (patrouille, ouïe, chasse, cross-étage).
- Piloter l'`AnimationPlayer` avec les 3 états existants : patrouille → marche lente, alerte → marche
  rapide, chasse → course (nous avons déjà `entity_mode` : 0/1/2 = parfait).
- Recoller les capteurs : position des pieds = `_terrain_y`, regard = yaw actuel (aucun changement).
- Garder les colliders actuels (capsule) : le modèle est purement visuel.

### Étape E — Finitions « réalisme » (moi)
- **Yeux cousus** + **bouche ouverte humide** en textures dédiées.
- **Blessures / os apparents** (décalques 3D).
- **Animation d'attaque** (mâchoire/tête) synchronisée avec `_caught()` — le screamer du jeu EST le modèle.
- Si le modèle IA est trop « propre » : grain VHS + désaturation → il se fondra dans le jeu.

### Coût et risque
- **Coût : 0 €** (Spaces + Blender). Temps : toi ~1 h de clics, moi ~3 h d'intégration.
- **Risque principal** : le mesh IA peut sortir avec une anatomie bizarre (bras fondus, pieds plats).
  Contre-mesures : générer 2-3 variantes, choisir la meilleure, et garder le monstre procédural
  actuel en **fallback** (`assets/models/monstre.glb` absent → il utilise les primitives actuelles).
  Comme ça **on ne peut rien casser**.

## Recommandation franche
1. **Fais l'étage 1 tout de suite** (c'est déjà poussé) : textures + grognement + reniflement =
   80 % du gain de peur pour 0 effort de ta part.
2. **Tente l'étage 2 sur UNE seule variante** (face + profil → TRELLIS → GLB) : si le résultat te plaît,
   je l'intègre ; sinon on garde le procédural et on renforce encore la mise en scène (apparitions,
   ombres portées, pas dans le couloir, sillons dans le plancher).
3. **Si tu ne veux rien téléverser** : dis-le, je peux pousser l'étage 1 plus loin
   (textures d'yeux cousus, plaies, animation de mâchoire) sans aucune IA 3D.

---

## ETAPE 2 : FAITE (v13, 2026-10-05) — le modele IA est en jeu
`monstre.glb` (TRELLIS.2, 96 251 tris) a ete decoupe en 4 parties + texture, integre dans `main.gd`
via `_build_entity_model()` (**repli procedural conserve** : `--dbg=nomodel` ou fichiers absents).
Resultat : silhouettes/texture realistes (peau texturée 1024, SSS, rim), patrouille et chasse animees
(jambes balances sur pivots de hanches, tete qui dodeline, corps qui tangue), sons 3D dans le modele.
Reste optionnel (etage 1 renforce) si le rendu ne convainc pas : plaies, machoire qui s'ouvre a l'attaque,
decalques de sang. Regenerer une variante = relancer le Space TRELLIS avec le meme `monstre_front.png`
(seed random) : l'integration est automatique au prochain `--import`.
