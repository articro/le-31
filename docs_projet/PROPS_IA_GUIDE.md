# GUIDE — PASSER DES PROPS IA EN 3D (LE 31, v12)
_Objectif : transformer les images de `doc/props_ia/` en modèles 3D utilisables dans le jeu._
_Matériel : ton PC (Intel Arc A750, pas de CUDA) + ton navigateur. **Aucune installation.**_

## Pourquoi des props et pas le monstre ?
- Un **objet** (TV, horloge, poupée, table) est statique : l'IA le sort proprement, on le pose dans une
  pièce avec une simple boîte de collision → 15 minutes de travail.
- Un **personnage animé** (le monstre) doit être riggé + animé : les modèles IA sont statiques, non
  riggés, ~100 k triangles, UV sales. L'intégrer = retopologie + rig Mixamo + refonte de l'intégration.
  Le monstre procédural actuel est plus léger, plus intégré et déjà validé en jeu → on le garde.

## Étape 1 — Générer le modèle 3D (gratuit, dans le navigateur)
1. Ouvre **https://huggingface.co/spaces/microsoft/TRELLIS.2** (Microsoft, gratuit, licence MIT)
   - Miroir plus ancien mais fiable : **https://huggingface.co/spaces/Microsoft/TRELLIS**
   - Version « low-poly PS1 » (bonne pour notre style) : **https://huggingface.co/spaces/stabilityai/TripoSR**
2. Téléverse l'image du prop voulu depuis `doc/props_ia/` (fond gris uni = idéal).
3. Clique **Generate** (~10-30 s).
4. **Download GLB**.

> ⚠️ Licence : TRELLIS = MIT ✅ · TripoSR = MIT ✅ · **Hunyuan3D-2 : exclu (licence qui exclut l'UE —
> interdit pour toi, à Paris)**.
> Le Space tourne sur LEUR GPU : ton Arc A750 n'a pas CUDA, mais ce n'est pas un problème ici.

## Étape 2 — Me l'envoyer
Dépose le `.glb` dans le chat (quelques Mo, ça passe) ou donne-moi le lien.
Je m'occupe de :
1. l'import dans le projet (`assets/props/*.glb` — Godot 4.3 importe le glTF nativement) ;
2. la mise à l'échelle à la maison (ex. TV ≈ 60 cm de large, horloge ≈ 1,90 m) ;
3. la **boîte de collision** (`_furn`) pour qu'on ne puisse pas la traverser ;
4. le **look VHS** : désaturation + contraste + grain (les modèles IA sont toujours trop « propres ») ;
5. le placement dans une pièce (salon pour la TV, couloir pour l'horloge, chambre pour la poupée…) ;
6. la réduction du poids si besoin (**objectif < 10 000 triangles, textures 1 K**) pour tenir dans le zip.

## Priorité (si on ne fait pas tout)
1. **TV CRT** — lecture immédiate, parfaite dans le salon, très « 1997 ».
2. **Poupée** — le plus flippant, idéale dans la chambre ou près du placard-cachette.
3. **Horloge** — donne du relief au couloir ; bonus : un tic-tac audible = du bruit… pour ELLE.
4. **Table** — utile mais on l'a déjà en boîtes ; à garder en dernier.

## Idées d'intégration gameplay (gratuites, si le look convainc)
- La **TV** s'allume par intermittence (bruit = distraction, elle ne t'entend plus).
- L'**horloge** tic-taque : si tu passes devant au mauvais moment, tu couvres son bruit OU tu trahis le tien.
- La **poupée** peut être déplacée entre deux visites (l'IA « bouge » quand tu ne regardes pas).
