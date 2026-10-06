# -*- coding: utf-8 -*-
"""LE 31 — tools/skin_tex.py
Peint la peau de la creature en espace UV (aucun risque pour le maillage).

  1. CARTE DE CAVITE (occlusion approx.) : pour chaque sommet, on mesure la concavite
     locale (position relative a la moyenne de ses voisins, projetee sur la normale).
     Les creux (orbites, bouche, narines, aisselles, plis du cou, entre les orteils)
     s'assombrissent tout seuls — c'est ce qui fait lire un visage.
  2. ORBITES renforcees : la zone profonde du visage devient un creux noir (regard vide).
  3. EXTREMITES refroidies et assombries (mains, pieds, visage) : le sang s'en va.
  4. CRASSE : bruit basse frequence + assombrissement des parties basses.
  5. TEINTE cadavre (verte/terne) au lieu du beige argile d'origine.

Sortie : assets/models/monstre_skin.png  (relance tools/rig_monstre.py ensuite)
"""
import json, struct, io
import numpy as np
from PIL import Image
from scipy.ndimage import gaussian_filter
from scipy.spatial import cKDTree

GLB = "/home/user/hantise/assets/models/monstre_rig.glb"
OUT = "/home/user/hantise/assets/models/monstre_skin.png"
S = 2048

d = open(GLB, "rb").read()
off, ch = 12, []
while off < len(d):
    cl, ct = struct.unpack("<II", d[off:off + 8]); ch.append((ct, off + 8, cl)); off += 8 + cl
J = json.loads(d[ch[0][1]:ch[0][1] + ch[0][2]].decode()); BIN = d[ch[1][1]:ch[1][1] + ch[1][2]]

def acc(i):
    a = J["accessors"][i]; bv = J["bufferViews"][a["bufferView"]]
    o = bv.get("byteOffset", 0) + a.get("byteOffset", 0); n = a["count"]
    t = {"VEC3": 3, "VEC2": 2, "VEC4": 4, "SCALAR": 1, "MAT4": 16}[a["type"]]
    dt = {5126: np.float32, 5125: np.uint32, 5123: np.uint16}[a["componentType"]]
    return np.frombuffer(BIN, dtype=dt, count=n * t, offset=o).reshape(n, t)

prim = J["meshes"][0]["primitives"][0]
P = acc(prim["attributes"]["POSITION"]).astype(np.float64)
NR = acc(prim["attributes"]["NORMAL"]).astype(np.float64)
UV = acc(prim["attributes"]["TEXCOORD_0"]).astype(np.float64)
JN = acc(prim["attributes"]["JOINTS_0"]).astype(int)
WG = acc(prim["attributes"]["WEIGHTS_0"]).astype(np.float64)
NAMES = [J["nodes"][i]["name"] for i in J["skins"][0]["joints"]]
IDX = {n: i for i, n in enumerate(NAMES)}
_bv = J["bufferViews"][J["images"][0]["bufferView"]]
raw = BIN[_bv.get("byteOffset", 0): _bv.get("byteOffset", 0) + _bv["byteLength"]]
base = Image.open(io.BytesIO(raw)).convert("RGB").resize((S, S), Image.LANCZOS)
tex = np.asarray(base, dtype=np.float64) / 255.0
print("texture de base :", base.size)

# ---------------------------------------------------------------- 1) carte de cavite
tree = cKDTree(P)
_, nn = tree.query(P, k=13, workers=-1)      # 12 voisins
nbrs = nn[:, 1:]
moy = P[nbrs].mean(axis=1)
cav = np.einsum("ij,ij->i", moy - P, NR) / 0.012      # >0 : le sommet est dans un creux
cav = np.clip(cav, -1.5, 2.5)
print("cavite : moyenne %.3f | 2%% les plus creux %.3f | 2%% les plus saillants %.3f"
      % (cav.mean(), np.percentile(cav, 98), np.percentile(cav, 2)))

def splat(vals, sigma, norm=True):
    m = np.zeros((S, S)); c = np.zeros((S, S))
    px = np.clip((UV[:, 0] % 1.0) * (S - 1), 0, S - 1).astype(int)
    py = np.clip((UV[:, 1] % 1.0) * (S - 1), 0, S - 1).astype(int)
    np.add.at(m, (py, px), vals)
    np.add.at(c, (py, px), 1.0)
    np.divide(m, np.maximum(c, 1.0), out=m)
    m = gaussian_filter(m, sigma)
    if norm and m.max() > 1e-9:
        # les sommets sont des points isoles dans l'atlas : on renormalise pour que
        # l'intensite relative soit conservee (sinon tout est divise par 100)
        m = m / m.max()
    return m

# loft de la cavite : seuil bas pour n'assombrir que les vrais creux
cav_pos = np.clip(cav, 0.0, 2.0) / 2.0
m_cav = splat(cav_pos, 5.0)
m_ridge = splat(np.clip(-cav, 0.0, 1.0) / 1.0, 5.0)
m_cav = np.clip((m_cav - 0.18) / 0.82, 0, 1)
print("masque de creux en UV : %.2f %% de la surface" % (100.0 * (m_cav > 0.3).mean()))

# ---------------------------------------------------------------- groupes d'os
def bone_w(b):
    w = np.zeros(len(P))
    for k in range(4):
        w += WG[:, k] * (JN[:, k] == IDX[b])
    return w

w_head = bone_w("head")
w_hand = bone_w("handL") + bone_w("handR")
w_foot = bone_w("footL") + bone_w("footR") + bone_w("toeL") + bone_w("toeR")

# ---------------------------------------------------------------- 2) orbites renforcees
# creux les plus profonds de la face, gauche et droite separement
face = (w_head > 0.5) & (P[:, 2] < -0.035)
sock = np.zeros(len(P))
for cote in (-1.0, 1.0):
    sel = face & (np.sign(P[:, 0]) == np.sign(cote)) & (np.abs(P[:, 0]) > 0.008)
    if sel.sum() == 0:
        continue
    # les 25 % les plus creux de ce cote
    seuil = np.percentile(cav[sel], 75)
    sock[sel & (cav >= seuil)] = 1.0
m_sock = np.clip(splat(sock, 7.5) * 1.7, 0, 1)
print("orbites : %d sommets, masque UV %.2f %%" % (int(sock.sum()), 100.0 * (m_sock > 0.3).mean()))

# ---------------------------------------------------------------- 3) extremites
m_hand = np.clip(splat(w_hand, 6.0) * 2.6, 0, 1)
m_foot = np.clip(splat(w_foot, 6.0) * 2.2, 0, 1)
m_face = np.clip(splat(np.where(w_head > 0.8, 0.6, 0.0), 9.0) * 1.8, 0, 1)

# ---------------------------------------------------------------- 4) crasse
rng = np.random.default_rng(31)
def bruit(blur, zoom):
    n = gaussian_filter(rng.random((max(2, S // zoom), max(2, S // zoom))), blur)
    n = (n - n.min()) / (n.max() - n.min() + 1e-9)
    return np.asarray(Image.fromarray((n * 255).astype(np.uint8)).resize((S, S), Image.BICUBIC), dtype=np.float64) / 255.0
n1 = bruit(9.0, 4); n2 = bruit(3.0, 8)
yv = np.clip(splat(1.0 - np.clip((P[:, 1] - P[:, 1].min()) / 0.55, 0, 1), 10.0), 0, 1)

# ---------------------------------------------------------------- composition
mult = np.ones((S, S, 3))
crasse = 0.90 + 0.10 * n1 + 0.05 * n2 - 0.18 * yv
mult *= crasse[:, :, None]
# creux (occlusion) : jusqu'a -78 % dans les replis
occ = 1.0 - 0.78 * np.power(m_cav, 1.15)
mult *= occ[:, :, None]
# aretes saillantes : +8 % (lisere de lumiere, vend la forme)
mult *= (1.0 + 0.08 * m_ridge)[:, :, None]
# extremites refroidies/assombries
for m, force in ((m_hand, 0.34), (m_foot, 0.32), (m_face, 0.16)):
    mult *= np.stack([1.0 - force * m * 1.05, 1.0 - force * m * 0.92, 1.0 - force * m * 0.80], axis=2)
# orbites : creux noirs (regard vide)
d_sock = np.clip(m_sock * m_sock * 1.35, 0, 1)
mult *= np.stack([1.0 - 0.94 * d_sock, 1.0 - 0.96 * d_sock, 1.0 - 0.94 * d_sock], axis=2)

out = np.clip(tex * mult, 0, 1)
out = np.clip(out * np.array([1.02, 0.99, 0.94])[None, None, :], 0, 1)   # teinte cadavre
Image.fromarray((out * 255).astype(np.uint8)).save(OUT)
lum = out.mean(axis=2)
print("luminosite : moyenne %.3f (base %.3f) | creux %.3f | orbites %.3f | mains %.3f"
      % (lum.mean(), tex.mean(),
         lum[m_cav > 0.5].mean() if (m_cav > 0.5).any() else -1,
         lum[m_sock > 0.5].mean() if (m_sock > 0.5).any() else -1,
         lum[m_hand > 0.5].mean() if (m_hand > 0.5).any() else -1))
print("ecrit", OUT)
