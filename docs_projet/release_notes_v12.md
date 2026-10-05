# NOTES DE SORTIE — LE 31 v12 « ÉLARGIE »
_2026-10-05 — répond aux captures et demandes de l'utilisateur_

## 1. Supprimé
- **La flèche au sol est SUPPRIMÉE** (demande utilisateur) : plus d'icône qui suit le joueur, plus de halo.
  Le rappel est maintenant un simple toast au 1er tour : « Trouve la clé dorée ».

## 2. Lampe torche recalibrée (trop puissante)
- `light_energy` 9,0 → **4,6** · `spot_range` 18 → **13 m** · `spot_angle` 50° → **42°**
- poussière dans le faisceau : 90 → **55** particules

## 3. ESCALIER ENFIN DÉBLOQUÉ (vrai bug trouvé)
- **Cause** : la volée de marches avait sa base à z=13,6 alors que le mur sud est à z=14 — le joueur
  était écrasé contre le mur et ne pouvait jamais entrer dans la zone de déclenchement (bande 13,1–13,85).
  L'audit passait car il **téléportait** le joueur dans la bande (angle mort du test).
- **Correctif** : volée reculée de 1,2 m (base = 12,4), rampe/rails/trémie ajustés, `RAMP_RECT` → z 7,4–12,5,
  nœuds IA ajustés, **déclencheurs larges** (x 0,65–2,4 / z 12,4–13,95 et z 6,6–8,3) **et sans condition de
  direction** (`mv.z`) — l'ancienne condition exigeait d'avancer vers −Z pile dans la bande.
  Ajout d'un **cooldown** anti-rebond (1 s) + toast « ESCALIER → ÉTAGE (2,5 s) ».

## 4. Maison ÉLARGIE
- **Couloir : z 5,8–8,2 (2,4 m) → z 5,0–9,0 (4,0 m)** — l'espace central double presque.
- Conséquence : tous les murs intérieurs, portes, piliers, cloisons, dalles de plafond recalculés.
  Les pièces (salon, cuisine, salle de bains, garage, chambres, étage) sont agrandies d'autant ;
  les 4 dalles de plafond ont été redimensionnées pour couvrir les nouvelles zones (plus de trou).
- 3 meubles/objets repositionnés (canapé, citrouille, spot de clé, 2 cachettes) pour ne pas chevaucher
  les nouveaux murs. **Audit : AUDIT ALL OK (122 bodies)** après refonte.

## 5. Screamer refait (fini le smiley)
- Nouvelle image **`assets/tex/screamer.png`** (générée, style found-footage 1997 : visage cousu,
  bouche hurlante, dents, distorsion VHS, estampille d'horodatage).
- Mise en scène : **flash rouge**, **secousse violente**, **zoom qui recule**, son `scare` **×2 couches**
  (+3 dB et −1 dB désaccordées) + `sting` → le tout **1,6 s** avant le respawn (0,55 s avant).

## 6. Monstre encore plus détaillé (2,3 m)
- Ajouts : **genoux, chevilles, 4 orteils par pied**, **5 côtes**, **6 vertèbres** apparentes,
  **clavicules + tendons de cou**, **7 mèches de cheveux** sur le crâne (en plus des 7 loques,
  paupières cousues, mâchoire fendue, dents, mains osseuses).
- Aperçu comparatif : `doc/art/monstre_v10_vs_v11.png`.

## 7. Nouvelles fonctionnalités
- **ACCROUPISSEMENT (touche C)** : vitesse 1,7 m/s, **bruit de pas 0,07** (vs 0,18 debout) — l'entité
  t'entend à ~1 m seulement — pas sonore plus discret, caméra abaissée de 42 cm, sprint interdit.
- **5 NOTES À TROUVER** (lore du 31/10/1997, +1 au HUD « NOTES n/5 ») placées : garage, salon,
  cuisine, chambre 2, étage. Chaque note déclenche un chuchotement (elle t'entend).
- HUD : ligne d'objectif et compteur de notes mis à jour ; textes FR/EN.

## 8. Modélisation IA — décision et plan
- **Non retenue pour le monstre** : les modèles IA (TRELLIS, Stable Fast 3D…) sortent des maillages
  **statiques non riggés** ; un personnage animé (2 jambes, 2 bras, tête, démarche, course) exige
  retopologie + rig Mixamo + réintégration complète du squelette — plusieurs jours de travail pour un
  gain incertain. Le monstre procédural est **plus intégré, plus léger et déjà validé en gameplay**.
- **Si un jour on modélise** (prochaine étape possible) : props **statiques** = là où l'IA gagne
  (télé CRT, horloge, poupée, fauteuil). Pipeline : image → Space Hugging Face gratuit (pas d'install,
  licence compatible UE → **pas Hunyuan3D-2, licence hors UE**) → `.glb` nettoyé sous Blender →
  Godot 4.3 l'importe nativement → collider boîte. Le monstre resterait procédural.
- **Matériel utilisateur** : Intel Arc A750 8 Go (pas de CUDA) → génération via les Spaces web gratuits,
  pas en local.

## 9. Validation
- `--dbg=audit` → **AUDIT ALL OK** (122 bodies) après chaque étape.
- Matrice bots (quiet/smart) : voir `doc/matrice_v12.log`.
- Captures in-game : impossible dans la sandbox (2 vCPU / 1,9 Go, llvmpipe = OOM) → validation par
  l'utilisateur (GPU Arc A750) ou via `--dbg=shot`.
