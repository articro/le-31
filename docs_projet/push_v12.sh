#!/usr/bin/env bash
# LE 31 — push v12 : dépôt du zip projet + tag + release + captures.
# Usage : bash push_v12.sh <PAT> [zip] [dossier_shots]
#   <PAT>  : token GitHub classic avec scope repo (collé par l'utilisateur, jamais persisté)
#   [zip]  : défaut /home/user/LE31_projet_godot_v12.zip
#   [shots]: défaut /home/user/doc/shots_v12
set -e
PAT="${1:?PAT manquant}"
ZIP="${2:-/home/user/LE31_projet_godot_v12.zip}"
SHOTS="${3:-/home/user/doc/shots_v12}"
TAG="v12"
REPO="articro/le-31"
API="https://api.github.com/repos/$REPO"
AUTH="Authorization: token $PAT"

[ -f "$ZIP" ] || { echo "ZIP introuvable: $ZIP"; exit 1; }
ZIP="$(readlink -f "$ZIP")"   # CHEMIN ABSOLU obligatoire (leçon apprise)
echo "== payload: $ZIP ($(stat -c%s "$ZIP") octets)"

WORK="/tmp/le31_push"
rm -rf "$WORK"
git clone -q "https://x-access-token:$PAT@github.com/$REPO.git" "$WORK"
cd "$WORK"
git config user.email "articro@users.noreply.github.com"
git config user.name "articro"
# on vide le contenu (hors .git) puis on dézippe à plat
find . -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
unzip -o -q "$ZIP" -d "$WORK"
# si le zip contient un dossier racine unique, on le remonte
if [ "$(ls -1 | grep -vc '\.git' )" = "1" ] && [ -d "$(ls -1 | grep -v '\.git' | head -1)" ]; then
  TOP="$(ls -1 | grep -v '\.git' | head -1)"
  if [ -f "$TOP/project.godot" ]; then
    mv "$TOP"/* "$TOP"/.[!.]* . 2>/dev/null || true
    rmdir "$TOP"
  fi
fi
[ -f project.godot ] || { echo "ERREUR: project.godot absent après unzip — commit annulé (repo préservé)"; exit 1; }
git add -A
git commit -q -m "v12 ELARGIE : sols/murs/plafond réparés (quads verticaux -> boîtes), flèche au sol discrète, monstre redessiné (2,3 m voûté), preset Intel/Arc auto + F2" || echo "(rien à committer)"
git push -q origin HEAD:main
git tag -f "$TAG" -m "v12"
git push -q -f origin "$TAG"

# ---- release ----
REL_ID=$(curl -s -H "$AUTH" "$API/releases/tags/$TAG" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d.get('id',''))" 2>/dev/null || true)
if [ -z "$REL_ID" ]; then
  REL_ID=$(curl -s -X POST -H "$AUTH" -H "Content-Type: application/json" "$API/releases" \
    -d "{\"tag_name\":\"$TAG\",\"name\":\"LE 31 $TAG — ELARGIE\",\"body\":\"Sols, murs et plafond réparés (bug racine des quads verticaux), flèche au sol, monstre redessiné, preset graphique sûr Intel/Arc.\"}" \
    | python3 -c "import sys,json;print(json.load(sys.stdin)['id'])")
  echo "release créée id=$REL_ID"
else
  echo "release existante id=$REL_ID"
fi
# assurer l'asset zip : supprimer l'ancien du même nom puis (re)uploader
OLD=$(curl -s -H "$AUTH" "$API/releases/$REL_ID/assets" | python3 -c "
import sys,json
for a in json.load(sys.stdin):
    if a['name']=='$(basename "$ZIP")': print(a['id'])
" )
[ -n "$OLD" ] && curl -s -X DELETE -H "$AUTH" "$API/releases/assets/$OLD" >/dev/null && echo "ancien asset supprimé"
curl -s -H "$AUTH" -H "Content-Type: application/zip" --data-binary @"$ZIP" \
  "https://uploads.github.com/repos/$REPO/releases/$REL_ID/assets?name=$(basename "$ZIP")" \
  | python3 -c "import sys,json;d=json.load(sys.stdin);print('upload zip ->',d.get('name'),d.get('size'))"
# captures
if [ -d "$SHOTS" ]; then
  i=1
  for f in "$SHOTS"/shot*.png; do
    [ -f "$f" ] || continue
    N=$(printf "le31_v12_%02d_%s.png" "$i" "$(basename "$f" .png | sed 's/shot//')")
    OID=$(curl -s -H "$AUTH" "$API/releases/$REL_ID/assets" | python3 -c "
import sys,json
for a in json.load(sys.stdin):
    if a['name']=='$N': print(a['id'])
")
    [ -n "$OID" ] && curl -s -X DELETE -H "$AUTH" "$API/releases/assets/$OID" >/dev/null
    curl -s -H "$AUTH" -H "Content-Type: image/png" --data-binary @"$f" \
      "https://uploads.github.com/repos/$REPO/releases/$REL_ID/assets?name=$N" >/dev/null
    echo "upload $N"
    i=$((i+1))
  done
fi
# ---- vérif obligatoire de l'arbre ----
sleep 3
echo "== blobs HEAD :"
curl -s -H "$AUTH" "$API/git/trees/HEAD?recursive=1" | python3 -c "import sys,json;t=json.load(sys.stdin);b=[x for x in t['tree'] if x['type']=='blob'];print(len(b),'blobs')"
echo "== PUSH v12 TERMINE =="
