# LE 31 — horreur VHS, 31 octobre 1997

Tu te réveilles dans une maison vide. **Quelque chose y est aussi.**
Fais le tour (5 notes à trouver), trouve la sortie, et surtout : ne te fais pas attraper.

Godot **4.3** · projet complet (ouvrir ce dossier dans Godot, F5). Aucune dépendance externe,
aucun budget, tout est libre de droits. **Version en cours : v13 « CLAIRVOYANCE ».**

## Contenu de la v13
- **Monstre 3D réaliste** (généré par IA — TRELLIS.2, licence MIT) : 96 251 triangles, peau texturée
  1024², 2,35 m, silhouette voûtée. Animé : jambes, tête, tangage du corps.
- Sons 3D logés dans le corps du monstre : **souffle**, **grognement** (en chasse), **reniflement**
  (quand il te cherche à moins de 5,5 m).
- Marche et patrouille **orientées correctement** (le monstre marchait à l'envers depuis la v11).
- **Repli sûr** : le monstre d'origine (entièrement procédural) reste dans le jeu et reprend la main
  tout seul si les fichiers du modèle sont absents — ou à la demande avec `--dbg=nomodel`.
- Marqueur de version en jeu : **v13 CLAIRVOYANCE** (coin haut-droit).

## Commandes utiles
| But | Commande |
|---|---|
| Qualité graphique haute | `F2` (le preset sûr Intel/Arc coupe SDFGI + fog volumétrique) |
| Comparer les deux monstres | lancer avec `--dbg=nomodel` |
| Vérifier l'intégrité du monde | lancer avec `--dbg=audit` |
| Bot automatique (test de partie) | `--dbg=quiet --seed=5` |

Rappel des commandes : **ZQSD** marcher, **Maj** courir, **C** s'accroupir, **E** interagir,
**Tab** notes, **Échap** pause.

## Interdits respectés
Aucune référence aux Backrooms, pas d'itch.io, aucune musique commerciale, aucune dépendance payante.

🌐 **fr** — jeu jouable sur PC (Windows/Linux), manette non requise.
