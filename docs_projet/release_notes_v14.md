# LE 31 — version 14 « VISEUR » (2026-10-05)

**Le caméscope Hi8 est né : c'est lui qui fait la peur.** (Choix « caméra A » validé par toi.)

## Ce qui change
- **CLIC DROIT (maintenu) ou T** : tu lèves le caméscope à l'œil. Image **verte, granuleuse**, avec
  vignette et lignes de balayage, HUD d'époque : `● REC · HI8 · 31 OCT 1997 · 23:14:07 · [BATT 74%]`.
- **Tu vois dans le noir uniquement au viseur** — mais ton champ de vision se rétrécit fortement.
  À l'œil nu, tu vois large et presque rien. C'est le choix permanent du jeu.
- **R : REMBOBINER** — tu revois la **tracée lumineuse** de la créature des **20 dernières secondes**,
  et **elle est gelée pendant 1,5 s** : la fenêtre pour fuir. Prix : **−9 % de batterie**, 7 s de
  recharge, et **le bruit du rembobinage l'attire** sur ta position.
- **Batterie = ressource** : elle se vide quand le viseur est levé, **bip** quand il reste moins de 20 %,
  et s'éteint à 0 %. **5 piles** à ramasser (+35 % chacune) disséminées dans la maison.
- **Marqueur rouge** sur la créature : visible **au viseur uniquement** — tu la repères plus loin.
- 3 sons nouveaux : **clic du caméscope**, **rembobinage de bande**, **bip de batterie faible**.

## Validation
- `AUDIT ALL OK` (122 bodies) · bot `quiet seed 5` = **WIN** · test dédié `--dbg=cam` : 5 piles créées,
  viseur actif, batterie 100 → 87,6 % après levée + rembobinage, traînée de 76 points enregistrée.

## Commandes en jeu (rappel)
ZQSD marcher · Maj courir · **Clic droit / T caméscope** · **R rembobiner** · G lampe · C s'accroupir ·
E bonbon · F sucre collant · V grain VHS · F1 HUD · F2 qualité · Échap pause.
