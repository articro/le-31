# LE 31 — DESIGN TENSION v21 (mécaniques, jumpscares, sound design)
_6 oct. 2026. Règle : zéro copie. On extrait des PRINCIPES (gestion de ressource, doute,
absence, information asymétrique, son spatial) et on les combine autrement._

Notre identité : VHS 31 OCT 1997 · ELLE est aveugle, elle entend ton cœur · caméscope Hi8.
Toutes les idées ci-dessous servent cette identité.

---

## A. Mécaniques de tension (nouvelles, combinées)

### A1. Souffle retenu (risque/récompense)
- Caché ou accroupi près d'elle : maintenir C = retenir son souffle → bruit 0.
- Mais le cœur monte : après ~6 s, si tu n'as pas relâché → hoquet sonore (pic de bruit 1.2).
- Relâcher doucement = souffle audible 0.3. → le silence devient un choix minuté, pas un état.
_Principe : transformer l'immobilité (statique) en ressource qui se vide._

### A2. La poupée regarde (indicateur analogique)
- La poupée de porcelaine tourne lentement la tête vers ELLE quand elle est à < 10 m (même à travers les murs).
- La voir du coin de l'œil = information de direction sans HUD, 100 % diégétique, 100 % malaisant.
_Principe : l'information de menace passe par le décor, pas par l'interface._

### A3. Témoins électriques (le décor te trahit)
- TV CRT : passer devant allumé-la en statique (pic de bruit) SAUF si accroupi → les props deviennent des mines sonores à négocier.
- Horloge : carillon aux heures du jeu (23h15, 23h30…) = bruit fort LOCALISÉ ailleurs → elle va vers l'horloge, pas vers toi : fenêtre de 6 s pour traverser une pièce. Le décor devient appât.
- Le magnétoscope clignote plus vite quand elle est dans la pièce (le voir = savoir).
_Principe : chaque objet décoratif porte une règle sonore ; le décor = partition._

### A4. Batterie partagée, lumière = choix
- La lampe torche passe sur batterie (même réserve que le caméscope, piles rares).
- Dans le noir complet : TES grincements de plancher augmentent (tu tâtonnes, bruit ×1.5) mais tu es imprévisible ; lumière = moins de bruit pour toi, mais trajectoire devinable (elle apprend la dernière position bruyante).
_Principe : la lumière n'est pas un bonus, c'est une devise qu'on dépense._

### A5. Calme au lieu de « santé mentale »
- Pas de barre de folie. « Calme » invisible : proximité d'elle + blackouts + chasses le font baisser.
- Calme bas = grain VHS + audio assourdi + FAUX sons 3D (chuchotements à des endroits où elle n'est pas).
- Remonte en restant immobile dans une pièce éclairée loin d'elle.
- Conséquence : à calme bas, tu ne peux plus te fier à tes oreilles → la mécanique centrale (l'ouïe) se dégrade = peur de perdre son seul sens utile.
_Principe : la punition n'est pas la mort, c'est la perte de fiabilité de l'information._

### A6. Cachettes : le rituel de la poignée
- Cachettes toujours sûres par défaut (fair play), MAIS si elle t'a VU entrer (bruit > 0.5 au moment d'entrer) : elle vient, la poignée tourne (son + vibration écran), 3 s ; si tu fais un input pendant ça → elle ouvre. Sinon elle repart.
_Principe : la cachette n'est pas un bouton « invisible », c'est une épreuve de sang-froid._

---

## B. Jumpscares originaux (pas « un monstre qui crie »)

### B1. Le miroir en retard
- Reflet (vitres, TV éteinte, miroir sdb) rendu avec 0,8 s de retard. Parfois le reflet bouge sans toi.
- 9 fois sur 10 : rien. La 10e : dans le reflet, elle est derrière toi, immobile, tête penchée. Tu te retournes : elle est là, mais DORMANTE tant que tu ne cours pas. Le jumpscare est une révélation, pas un cri.

### B2. Le jumpscare d'absence
- Coupe TOUTE la nappe sonore (drone, vent, maison) → silence numérique total, REC figé.
- Le cerveau du joueur fabrique la menace. Après 4-8 s, un seul son minuscule (un craquement réel, diégétique) → retour du mix. Le pic de peur est dans le silence, pas dans le son.

### B3. Le rembobinage témoin
- Via le viseur Hi8, le rembobinage (R) montre tes 20 dernières secondes : parfois on y voit une silhouette à 2 m derrière toi que tu n'as PAS vue en direct. Pas de cri : elle te suivait sans te chasser. Information rétroactive = paranoïa.

### B4. Désensibiliser puis frapper
- Pendant une chasse longue, flash 2 images (subliminal) de son visage sans son, au bord de l'écran.
- Le vrai sting n'arrive que 8-12 s plus tard, au moment où tu as « oublié » le flash.

### B5. La porte refermée
- Une porte que tu as ouverte est refermée quand tu reviens. L'ouvrir = elle est derrière, debout, endormie debout (nouvel état). Recule sans bruit et elle ne se réveille pas ; cours et le jumpscare est mérité.
_Principe transversal : le jumpscare doit être une information ou une conséquence, jamais un réflexe de cri._

---

## C. Sound design

1. **Son cœur à elle** : en mode chasse, son cœur 3D (pas le tien) — tu ENTENDS qu'elle chasse avant de la voir ; battement plus lent que le tien (40 BPM) = signature.
2. **Pas menteurs** : 1 fois/90 s, écho de TES pas décalé de 0,4 s, 3 dB plus bas. Doute immédiat.
3. **Silences intelligents** : après chaque sting, mix à -30 dB pendant 8-15 s (même le vent) → le retour de la nappe = soulagement conditionné.
4. **Frottement de loques** : quand elle tourne près de toi (< 4 m), frottement de tissu 3D pané = indicateur de direction sans la voir.
5. **Boîte à musique cassée** : 3 notes très basses, parfois, UNIQUEMENT pendant sa dormance → quand la mélodie s'arrête, elle est réveillée. Tell audio diégétique de la dormance (remplace le timer invisible).
6. **Chuchotements directionnels faux** : seulement à calme bas (A5) : chuchotements à l'opposé de sa position réelle.
7. **Carillon d'horloge** (A3) : événement sonore fort, localisé, exploitable = le son devient un outil, pas juste une ambiance.
8. **Tick de la pile faible** : sous 20 % de batterie, le bip existant + nouveau : le tic-tac de l'horloge du couloir se désynchronise (battement) quand elle entre dans la maison → fusion ambiance/info.

---

## D. Ordre d'implémentation proposé (petits steps)
- **v21d** : A2 (poupée qui regarde) + B5 porte refermée + C5 boîte à musique de dormance. (diégétique, peu de code, fort rendu)
- **v21e** : A1 souffle retenu + A4 batterie torche partagée.
- **v21f** : A3 témoins (TV/horloge) + C1/C4 (cœur d'elle, frottement).
- **v21g** : A5 calme + faux sons + B1/B2/B3/B4 (visuels viseur/miroir).
- **v21h** : A6 rituel de la poignée.
Puis extérieur nuit + 8 trophées + release v21 finale.

## E. Décors open-source (réponse à la demande)
Sources CC0 compatibles « zéro budget + identité VHS » :
- **Poly Haven** (polyhaven.com) : props photogrammés CC0 (meubles vieux, électroménager rétro) — textures 2K/4K PBR, parfait pour le salon/cuisine.
- **Kenney** (kenney.nl, CC0) : low-poly propre si besoin de volume rapide.
- **ambientCG** : matériaux sols/murs vieillissants (papier peint, carrelage sale).
Règle : on n'importe que des props UNITAIRES (pas de scènes entières), on retire les LOD lourds,
on garde la palette sombre 1997, et on garde NOS textures procédurales pour murs/sols (identité).
Le monstre reste 100 % maison (jamais d'asset externe sur « ELLE »).
