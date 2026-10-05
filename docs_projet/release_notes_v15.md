# LE 31 — version 15 « MOUVEMENT » (2026-10-05)

**Ton monstre T-pose est dans le jeu — et cette fois ses BRAS bougent vraiment.**

## Ce qui change
- **Monstre découpé en 6 parties animables** : corps, tête, **jambe gauche, jambe droite, BRAS gauche, BRAS droit**
  (99 897 triangles au total). Les bras sont séparés des épaules → ils ont leur propre mouvement.
- **Les bras pendent le long du corps** (rotation de −30° appliquée au modèle pour corriger la pose en T)
  **et balancent en marchant** ; en chasse, ils se lèvent vers l'avant, à la manière d'un prédateur.
- **Jambes resserrées** : la pose d'origine écartait les pieds de 1,12 m (pose de rigging, pas de marche) ;
  je les ai rapprochées à ~0,72 m pour une démarche crédible.
- **F3 : bascule à chaud entre les deux monstres.** Nouveau modèle (6 parties, bras animés) ↔ ancien (4 parties, v13).
  Tu changes en pleine partie, sans redémarrer — comme ça tu juges les deux à la volée.
- **Les clés sont de vraies clés 3D** : tige, anneau, panneton, deux dents — et elles **tournent lentement**
  sur elles-mêmes pour attirer l'œil dans le noir.
- Ligne de commande : `--dbg=model1` force l'ancien monstre, `--dbg=m2` vérifie la structure du nouveau.

## Validation
- `AUDIT ALL OK` (122 bodies) · bot `quiet seed 5` = **WIN** · caméra intacte (5 piles, rembobinage).
- `--dbg=m2` : corps 63 741 tri · tête 7 664 · jambes 8 472 / 8 328 · bras 5 723 / 5 969 → **99 897** ✅

## À retenir (important)
- Sur GitHub, ton fichier **`clé.glb` était en réalité une copie du monstre** (même empreinte exacte, même taille).
  La génération de la clé n'a rien produit de valide → **je la referai** (avec la TV, la poupée et l'horloge)
  dès que le quota du Space TRELLIS se recharge (limite gratuite : ~3 min de GPU par jour et par IP).
- Ton fichier `monstreTpose.glb` a été **rangé** dans `assets/models/monstre_tpose.glb` (il n'a plus à traîner à la racine).
