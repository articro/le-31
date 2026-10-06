# LE 31 — version 17 « DÉMARCHE » (2026-10-05)

Réponse directe à tes 4 reproches : **mouvement**, **apparition trop tôt**, **sons**, **grincement muet**.

## 1. Le monstre a maintenant des GENOUX et des COUDES (10 parties au lieu de 6)
Découpe refaite : **corps, tête, 2 cuisses, 2 tibias (avec pieds), 2 bras, 2 avant-bras (avec mains)** — 99 897 triangles.
Concrètement, ça change tout :
- **Les jambes se plient** : la cuisse avance, le genou se replie au bon moment → une vraie marche, plus un balancier de pantin.
- **Les coudes plient** : les bras ont un mouvement articulé, et en chasse ils se lèvent devant lui.
- **Le corps tangue et s'incline** en avant (0,10 rad en chasse), avec un balancement latéral synchronisé sur les pas.
- **La tête te SUIT DU REGARD** : dès qu'elle te cherche, elle tourne la tête vers toi (limite ±0,9 rad), avec un dodelinement permanent.
- **Ses pas font du bruit** : un son de pas lourd (nouveau `mstep.wav`) tombe exactement sur chaque appui — tu l'entends approcher dans le couloir, et tu sais s'il marche ou court.
- **Articulations visibles** (genoux, coudes, épaules, bassin) qui cachent les coupes et donnent l'impression d'un corps continu.
- **F3** fait défiler les 3 monstres : v17 (10 parties) → v15 (6) → v13 (4) → retour.

## 2. Elle n'apparaît plus tôt : elle DORT, et elle se réveille par toi
- La créature reste **invisible et immobile, parquée au point le plus éloigné de la carte**.
- Elle se réveille **quand tu ramasses ta première note** (ou après 75 secondes, si tu ne touches à rien).
- Au réveil : **elle repart du point le plus éloigné de toi**, avec un son de tension et un grognement lointain. Tu ne la verras pas « apparaître à côté de toi ».
- Puis la **laisse d'écoute** prend le relais : chaque bruit fort (course, latte qui grince) lui donne **ta position** pendant 6 secondes — elle vient voir, et elle sait monter les escaliers.

## 3. TOUS les sons refaits (21 fichiers)
Anciens sons : bruitages informatiques sans âme. Les nouveaux sont construits à la main, couche par couche :
| Son | Ce que tu entends maintenant |
|---|---|
| `step` / `mstep` | un vrai pas sur du bois (choc grave + frottement), et un **pas lourd de créature** |
| `creak` | **le grincement de plancher** : bois qui travaille, avec vibration et craquement sec |
| `heart` | battement de cœur lub-dub |
| `breath` | inspiration + expiration, souffle réaliste |
| `growl` | grognement grave et organique (formants + tremblement) |
| `sniff` | trois reniflements courts |
| `whisper` | chuchotements syllabiques |
| `chime` | carillon clair de ramassage |
| `key_jingle` | **trousseau de clés qui s'entrechoquent** (nouveau, au ramassage d'une clé) |
| `paper` | feuille de papier froissée (nouveau, au ramassage d'une note) |
| `scare` | cri d'effroi + impact grave |
| `sting` | montée de tension dissonante |
| `drone` / `wind` / `house` / `tension` | ambiances (rumeur, vent avec rafales, maison avec craquements aléatoires, pouls) |
| `music` | boucle sombre de 32 s (l'ambiance musicale demandée) |
| `cam_click` / `tape_rewind` / `lowbatt` | clic du caméscope, rembobinage, alerte de batterie |

## 4. Le grincement de plancher s'entend vraiment
- Son refait (120 Ko au lieu de 8 Ko) et **volume relevé de 6 dB**.
- **Nouveau déclenchement** : les lattes grincent **partout où tu marches** (pas seulement dans les zones prévues), plus souvent quand tu cours.
- Conséquence de jeu : un grincement = du bruit = **elle vient**. Marcher doucement (ou s'accroupir) est maintenant vraiment utile.

## Validation
- `AUDIT ALL OK` (122 bodies) · bot discret : WIN · bot bruyant : **se fait attraper** (la laisse fonctionne).
- `--dbg=m2` : les 10 parties se construisent (corps 63 741 tri · bras 5 723/5 969 · cuisses 8 472/8 328 · tibias · tête 7 664).
