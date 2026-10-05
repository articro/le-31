# POUR UNE NOUVELLE CONVERSATION — état LE 31 au 2026-10-05 (**v12 prête, v11 sur GitHub**)
_À copier-coller tel quel dans une nouvelle session si besoin._

---

Projet LE 31 (Godot 4.3, repo `articro/le-31`, miroir mémoire `articro/le-31-memoire`).
**La v11 est DÉJÀ CODÉE ET VALIDÉE (audit vert) dans le workspace `/home/user` d'une autre session.**
Ne pas refaire ce travail : soit tu y as accès (workspace partagé), soit demande les fichiers.

Où est quoi :
- Code patché : `/home/user/hantise/scripts/main.gd` (3 082 lignes) ; sauvegardes :
  `/home/user/doc/checkpoints/main_v10_ref.gd` (v10), `main_v11a.gd`, `main_v11b.gd` (v11 finale).
- Paquet de test immédiat : `/home/user/LE31_v11_main.gd.zip` (32 Ko → à extraire sur un v10).
- Patch reproductible : `/home/user/patch_v11a.py` ; script de publication : `/home/user/push_v11.sh <PAT>`.
- Notes : `doc/release_notes_v11.md`, `doc/PLAN_V11.md`, `doc/le31_bugs_2026-10-04/` (captures de bug),
  `doc/art/monstre_v10_vs_v11.png` (aperçu avant/après), `doc/matrice_v11.log` (validation bots).

Ce que la v11 corrige (validé) :
1. **Bug racine des captures du 04/10** : « sols », plafond et plusieurs murs étaient des plans
   VERTICAUX (normale mesurée (−1,0,0)) → passés en **boîtes pleines** ; dalles de sol par pièce ;
   plafond = dalles d'étage (trémie escalier ouverte) ; tapis/lattes/flaque remis à plat.
2. Flèche au sol : horizontale, bon sens (UV mesurées : « haut » du plan = +Z local), discrète.
3. Monstre redessiné (2,3 m voûté, tête aveugle dégagée, bras longs, mains osseuses, loques).
   Animation conservée (LegL/LegR/ArmL/ArmR/Head).
4. Preset SÛR auto : GPU Intel/Arc/llvmpipe → SDFGI + fog volumétrique coupés au démarrage ; **F2** = qualité.
- Audit : **AUDIT ALL OK** (122 bodies).

Le seul blanc : `horreur_plan_halloween2026.md` **§S9 n'existe plus nulle part** (ni workspace, ni repo jeu,
ni miroir public) — perdu avec les wipes. Travailler sur la mémoire seule, c'est suffisant.

Pièges sandbox (pour la nouvelle session) :
- 2 vCPU / ~1,9 Go RAM → **aucun rendu de shots possible** (llvmpipe = OOM kill). La validation visuelle
  se fait sur le PC de l'utilisateur (Intel Arc A750) : `--dbg=shot` ou Win+Alt+R.
- `/home/user/.cache` (binaire Godot) est effacé à chaque snapshot → re-télécharger au besoin ;
  vérifier le binaire AVANT de croire un `--check-only`.
- Tuer Godot : `pkill -f "[G]odot_v4.3-stable"` (le nom est tronqué à 15 car. pour `pkill -x`).
- Ne jamais lancer 2 bots Godot en parallèle (ça double le temps et sature la RAM).

## v12 « ÉLARGIE » — prête, pas encore poussée (2026-10-05)
Fichiers : `LE31_v12_main.gd` / `LE31_v12_main.gd.zip` (test immédiat) · `doc/checkpoints/main_v12.gd` ·
`doc/release_notes_v12.md` · `doc/art/props_ia_planche.png` · `doc/PROPS_IA_GUIDE.md` · `doc/props_ia/` (4 images).
Publication : `bash MAKE_ZIP_V12.sh` puis `bash push_v12.sh <PAT>` (PAT à redemander à l'utilisateur).
Contenu : flèche supprimée · lampe 4.6/13 m/42° · ESCALIER RÉPARÉ (volée reculée + déclencheurs larges
sans condition de direction) · couloir élargi 2,4 → 4,0 m · screamer refait (flash/secousse/zoom, son doublé,
1,6 s) · monstre + détails (genoux, orteils, côtes, vertèbres, tendons, cheveux) · accroupissement (C,
bruit 0,07) · 5 notes à trouver (HUD « NOTES n/5 »).
Validation : AUDIT ALL OK (122 bodies) · bot quiet seed 5 = WIN (1 prise) · matrice smart/walk/blind en cours.
