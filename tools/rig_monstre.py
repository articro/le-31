# -*- coding: utf-8 -*-
"""
LE 31 — rig_monstre.py
Transforme le mesh TRELLIS brut (monstre_tpose.glb, 99 897 tri, A-pose, un seul morceau)
en personnage SKINNÉ : squelette 22 os + poids de sommets calcules + lissage laplacien.
Sortie : monstre_rig.glb (mesh + skin + squelette) pret pour Godot (Skeleton3D).

Aucune dependance externe hors numpy/scipy.
"""
import json, struct, sys
import numpy as np
from scipy.spatial import cKDTree

SRC = "/home/user/hantise/assets/models/monstre_tpose.glb"
DST = "/home/user/hantise/assets/models/monstre_rig.glb"

# ------------------------------------------------------------------ lecture glb
def read_glb(path):
    d = open(path, "rb").read()
    assert d[:4] == b"glTF", "pas un GLB"
    off, chunks = 12, []
    while off < len(d):
        cl, ct = struct.unpack("<II", d[off:off + 8])
        chunks.append((ct, off + 8, cl))
        off += 8 + cl
    J = json.loads(d[chunks[0][1]:chunks[0][1] + chunks[0][2]].decode("utf-8"))
    BIN = d[chunks[1][1]:chunks[1][1] + chunks[1][2]]
    return J, BIN, d

def accessor(J, BIN, i):
    a = J["accessors"][i]
    bv = J["bufferViews"][a["bufferView"]]
    o = bv.get("byteOffset", 0) + a.get("byteOffset", 0)
    n, t = a["count"], {"VEC3": 3, "VEC2": 2, "SCALAR": 1}[a["type"]]
    dt = {5126: np.float32, 5125: np.uint32, 5123: np.uint16}[a["componentType"]]
    return np.frombuffer(BIN, dtype=dt, count=n * t, offset=o).reshape(n, t)

J, BIN, RAW = read_glb(SRC)
P = accessor(J, BIN, 1).astype(np.float64)   # positions
UV = accessor(J, BIN, 2).astype(np.float32)  # uv
NRM = accessor(J, BIN, 3).astype(np.float32) # normales
IDX = accessor(J, BIN, 0).astype(np.uint32).ravel()
IMG = J["images"][0]                          # texture webp embarquee
# retrouver les octets de l'image
_bv = J["bufferViews"][IMG["bufferView"]]
_img_raw = BIN[_bv.get("byteOffset", 0): _bv.get("byteOffset", 0) + _bv["byteLength"]]
# Godot ne sait pas lire le WEBP dans un glTF : on reencode en PNG (sinon la creature sort grise)
import io as _io
from PIL import Image as _Im
_buf = _io.BytesIO(); _Im.open(_io.BytesIO(_img_raw)).convert("RGB").save(_buf, "PNG", optimize=True)
_img_bytes = _buf.getvalue()
_mime = "image/png"
print("mesh : %d sommets, %d triangles, texture reencodee PNG (%d octets)" % (len(P), len(IDX) // 3, len(_img_bytes)))

# ------------------------------------------------------------------ squelette
# Reperes : espace GLB d'origine = hauteur 1.0 (y de -0.5 pieds a +0.5 crane), le visage regarde +Z.
J2 = {
    "hips":     (0.000, -0.085,  0.000),
    "spine":    (0.000, -0.030,  0.000),
    "chest":    (0.000,  0.095,  0.000),
    "neck":     (0.000,  0.285,  0.000),
    "head":     (0.000,  0.350, -0.005),
    "headtip":  (0.000,  0.505,  0.000),
    "clavL":    (0.030,  0.275,  0.000),
    "shoulderL":(0.115,  0.288, -0.010),
    "elbowL":   (0.345,  0.080,  0.020),
    "wristL":   (0.372,  0.005,  0.022),
    "handL":    (0.378, -0.045,  0.022),
    "hipL":     (0.058, -0.085,  0.000),
    "kneeL":    (0.135, -0.250, -0.025),
    "ankleL":   (0.169, -0.410, -0.028),
    "toeL":     (0.185, -0.478,  0.040),
    "toetipL":  (0.190, -0.492,  0.085),
    # machoire : le pivot est a la ligne de bouche (y = 0.355 en espace source),
    # la queue descend vers le menton et l'avant (visage vers +Z dans cet espace)
    "jaw":      (0.000,  0.356,  0.008),
    "jawtip":   (0.000,  0.312,  0.048),
}
def mir(k):
    x, y, z = J2[k]
    return (-x, y, z)
for k in list(J2.keys()):
    if k.endswith("L"):
        J2[k[:-1] + "R"] = mir(k)

# os = (nom, parent, tete, queue)
BONES = [
    ("hips",      None,     J2["hips"],     J2["spine"]),
    ("spine",     "hips",   J2["spine"],    J2["chest"]),
    ("chest",     "spine",  J2["chest"],    J2["neck"]),
    ("neck",      "chest",  J2["neck"],     J2["head"]),
    ("head",      "neck",   J2["head"],     J2["headtip"]),
    ("clavL",     "chest",  J2["clavL"],    J2["shoulderL"]),
    ("upperarmL", "clavL",  J2["shoulderL"],J2["elbowL"]),
    ("forearmL",  "upperarmL", J2["elbowL"],J2["wristL"]),
    ("handL",     "forearmL",  J2["wristL"],J2["handL"]),
    ("clavR",     "chest",  J2["clavR"],    J2["shoulderR"]),
    ("upperarmR", "clavR",  J2["shoulderR"],J2["elbowR"]),
    ("forearmR",  "upperarmR", J2["elbowR"],J2["wristR"]),
    ("handR",     "forearmR",  J2["wristR"],J2["handR"]),
    ("thighL",    "hips",   J2["hipL"],     J2["kneeL"]),
    ("shinL",     "thighL", J2["kneeL"],    J2["ankleL"]),
    ("footL",     "shinL",  J2["ankleL"],   J2["toeL"]),
    ("toeL",      "footL",  J2["toeL"],     J2["toetipL"]),
    ("thighR",    "hips",   J2["hipR"],     J2["kneeR"]),
    ("shinR",     "thighR", J2["kneeR"],    J2["ankleR"]),
    ("footR",     "shinR",  J2["ankleR"],   J2["toeR"]),
    ("toeR",      "footR",  J2["toeR"],     J2["toetipR"]),
    ("jaw",       "head",   J2["jaw"],      J2["jawtip"]),
]
NAMES = [b[0] for b in BONES]
NB = len(BONES)
print("squelette : %d os" % NB)

# ------------------------------------------------------------------ poids
# ------------------------------------------------------------------ masques progressifs
# Chaque os ne peut influencer qu'une zone, mais les bords de cette zone sont LISSES
# (fondu sur plusieurs cm) : c'est ce qui evite les dechirures aux hanches/epaules.
def sstep(t):
    t = np.clip(t, 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)

# os sans masque de distance : leur poids est attribue par transfert explicite plus bas
SANS_MASQUE = ("jaw",)


def gate(v, lo, hi, soft):
    a = sstep((v - (lo - soft)) / soft)
    b = sstep(((hi + soft) - v) / soft)
    return a * b

AX = np.abs(P[:, 0])
GATES = {
    "hips":  [("y", -0.22, 0.050, 0.06), ("ax", -1.0, 0.130, 0.06)],
    "spine": [("y", -0.07, 0.190, 0.07), ("ax", -1.0, 0.150, 0.07)],
    "chest": [("y",  0.01, 0.310, 0.08), ("ax", -1.0, 0.170, 0.08)],
    "neck":  [("y",  0.21, 0.360, 0.07), ("ax", -1.0, 0.100, 0.05)],
    "head":  [("y",  0.28, 3.000, 0.10)],
    "clavL":    [("y", 0.21, 0.340, 0.07), ("ax", -1.0, 0.210, 0.06), ("x", -0.020, 9.0, 0.04)],
    "upperarmL":[("y", -0.05, 0.340, 0.08), ("ax", 0.085, 9.0, 0.05), ("x", -0.020, 9.0, 0.04)],
    "forearmL": [("y", -0.11, 0.180, 0.07), ("ax", 0.190, 9.0, 0.05), ("x", 0.050, 9.0, 0.05)],
    "handL":    [("y", -0.15, 0.100, 0.06), ("ax", 0.270, 9.0, 0.04), ("x", 0.050, 9.0, 0.05)],
    "thighL":   [("y", -0.33, 0.050, 0.07), ("ax", 0.015, 9.0, 0.04), ("x", -0.010, 9.0, 0.04)],
    "shinL":    [("y", -0.46, -0.170, 0.06), ("x", -0.010, 9.0, 0.04)],
    "footL":    [("y", -3.0, -0.360, 0.06), ("x", -0.010, 9.0, 0.04)],
    "toeL":     [("y", -3.0, -0.440, 0.05), ("x", -0.010, 9.0, 0.04)],
}
for k in list(GATES.keys()):
    if k.endswith("L"):
        g = []
        for var, lo, hi, so in GATES[k]:
            if var == "x":
                lo, hi = -hi, -lo          # miroir
            g.append((var, lo, hi, so))
        GATES[k[:-1] + "R"] = g

MASK = {}
for name, _p, _a, _b in BONES:
    if name in SANS_MASQUE:
        m = np.zeros(len(P))
        MASK[name] = m
        continue
    m = np.ones(len(P))
    for var, lo, hi, so in GATES[name]:
        v = P[:, 1] if var == "y" else (AX if var == "ax" else P[:, 0])
        m *= gate(v, lo, hi, so)
    MASK[name] = m

pts = P.astype(np.float64)
W = np.zeros((len(P), NB), dtype=np.float64)
for bi, (name, parent, a, b) in enumerate(BONES):
    a = np.array(a, dtype=np.float64); b = np.array(b, dtype=np.float64)
    ab = b - a; L2 = float(ab @ ab) + 1e-9
    t = np.clip(((pts - a) @ ab) / L2, 0.0, 1.0)
    dist = np.linalg.norm(pts - (a + t[:, None] * ab), axis=1)
    if name in ("hips", "spine", "chest", "neck", "head"):
        dist = dist + 0.030            # le tronc est epais : influence plus douce
    W[:, bi] = MASK[name] / np.power(dist + 0.012, 6.0)

# normaliser
s = W.sum(axis=1, keepdims=True)
W = np.divide(W, np.maximum(s, 1e-12))

# lissage laplacien sur le graphe des k plus proches voisins (peau continue)
tree = cKDTree(P)
_, nn = tree.query(P, k=9, workers=-1)
nn = nn[:, 1:]
for it in range(4):
    Wn = W[nn].mean(axis=1)
    W = 0.40 * W + 0.60 * Wn
    W = np.divide(W, np.maximum(W.sum(axis=1, keepdims=True), 1e-12))

# ---- v20b : le bas du visage (levre inferieure, menton, joues basses) suit la machoire
_i_jaw = NAMES.index("jaw")
_i_head = NAMES.index("head")
_y, _z, _x = P[:, 1], P[:, 2], P[:, 0]
# fondu vertical : 0 au-dessus de la levre (y=0.372), 1 sous le menton (y=0.332)
_t = np.clip((0.372 - _y) / 0.040, 0.0, 1.0)
_t = _t * _t * (3.0 - 2.0 * _t)
# uniquement l'avant du visage (pas la nuque, pas la base du crane)
_t *= np.clip((_z + 0.030) / 0.055, 0.0, 1.0)
_t *= np.clip((0.075 - np.abs(_x)) / 0.030, 0.0, 1.0)
# le menton est porte par la NUQUE autant que par la tete : on prend aux deux
_i_neck = NAMES.index("neck")
_src = W[:, _i_head] + 0.75 * W[:, _i_neck]
_t = _t * np.clip(_src * 3.0, 0.0, 1.0)              # seuls les sommets du bas du crane
_frac = 0.90 * _t
W[:, _i_jaw] = _src * _frac
W[:, _i_head] = W[:, _i_head] * (1.0 - _frac)
W[:, _i_neck] = W[:, _i_neck] * (1.0 - 0.75 * _frac)
W = np.divide(W, np.maximum(W.sum(axis=1, keepdims=True), 1e-12))
print("machoire : %d sommets transferes (max %.2f de poids)" % (int((_t > 0.05).sum()), float(_t.max())))

# ne garder que 4 influences par sommet (limite standard)
K = 4
order = np.argsort(-W, axis=1)[:, :K]
Wk = np.take_along_axis(W, order, axis=1)
Wk = np.divide(Wk, np.maximum(Wk.sum(axis=1, keepdims=True), 1e-12))
JOINTS = order.astype(np.uint16)
WEIGHTS = Wk.astype(np.float32)
print("poids : max influences =", int((W > 1e-4).sum(axis=1).max()), "| min poids top4 =", float(Wk[:, 3].min().round(4)))

# apercu de la texture (pour choisir la teinte des dents) et poids de l'os tete
from PIL import Image as _Im2
_im2 = _Im2.open("/home/user/hantise/assets/models/monstre_skin.png").convert("RGB").resize((256, 256), _Im2.LANCZOS)
_TEX_SMALL = np.asarray(_im2, dtype=np.float64) / 255.0
_UVW_HEAD = (JOINTS == NAMES.index("head")).any(axis=1).astype(np.float64)

# ------------------------------------------------------------------ dents
# Deux arcades : le haut appartient a la tete, le bas a la machoire. Secteur angulaire
# d'une dent = triangle fuseau ; c'est grossier mais a 2,80 m et dans le noir, ca suffit.
def _uv_dent():
    """choisit une teinte d'os : on prend la zone la plus claire du crane"""
    px = np.clip((UV[:, 0] % 1.0) * (255), 0, 255).astype(int)
    py = np.clip((UV[:, 1] % 1.0) * (255), 0, 255).astype(int)
    lum = (0.30 * _TEX_SMALL[py, px, 0] + 0.59 * _TEX_SMALL[py, px, 1] + 0.11 * _TEX_SMALL[py, px, 2])
    sel = (_UVW_HEAD > 0.5)
    if sel.sum() == 0:
        return UV[0]
    i = int(np.argsort(-lum[sel])[max(0, int(sel.sum() * 0.02) - 1)])
    return UV[sel][i]


def _dent(cul, dirv, r, h):
    """retourne (sommets, normales, faces) d'une dent : 6 sommets, 8 triangles"""
    dirv = np.array(dirv, dtype=np.float64)
    dirv /= np.linalg.norm(dirv)
    # repere autour de l'axe
    tmp = np.array([0.0, 1.0, 0.0]) if abs(dirv[1]) < 0.9 else np.array([1.0, 0.0, 0.0])
    u = np.cross(dirv, tmp); u /= np.linalg.norm(u)
    w = np.cross(dirv, u)
    cul = np.array(cul, dtype=np.float64)
    apex = cul + dirv * h
    ring = [cul + u * r * np.cos(a) + w * r * np.sin(a) for a in np.linspace(0, 2 * np.pi, 5)[:4]]
    base = cul - dirv * h * 0.35
    V = [apex, base] + ring
    F = []
    for k in range(4):
        a, b = 2 + k, 2 + (k + 1) % 4
        F.append((0, a, b))          # pointe
        F.append((1, b, a))          # fond
    N = []
    for v in V:
        d = v - cul
        d /= (np.linalg.norm(d) + 1e-9)
        N.append(d)
    return V, N, F


def _uv_sombre():
    """choisit la teinte la plus sombre peinte sur le crane : c'est l'interieur de la bouche"""
    px = np.clip((UV[:, 0] % 1.0) * (255), 0, 255).astype(int)
    py = np.clip((UV[:, 1] % 1.0) * (255), 0, 255).astype(int)
    lum = (0.30 * _TEX_SMALL[py, px, 0] + 0.59 * _TEX_SMALL[py, px, 1] + 0.11 * _TEX_SMALL[py, px, 2])
    sel = (_UVW_HEAD > 0.5)
    if sel.sum() == 0:
        return UV[0]
    i = int(np.argmin(lum[sel]))
    return UV[sel][i]


_uvs = _uv_sombre()
_uvb = _uv_dent()
DV, DN, DF, DJ = [], [], [], []
_vbase = len(P)
def _ajoute_dent(cul, dirv, r, h, os_idx):
    base = len(DV)
    V, N, F = _dent(cul, dirv, r, h)
    for v, n in zip(V, N):
        DV.append(v); DN.append(n)
        DJ.append(os_idx)                      # un os par SOMMET (pas par face)
    for f in F:
        DF.append((base + f[0], base + f[1], base + f[2]))


for cote in np.linspace(-0.021, 0.021, 5):
    _ajoute_dent((cote, 0.3565, 0.030), (0.0, -1.0, 0.12), 0.0042, 0.014, _i_head)   # dent du haut
    _ajoute_dent((cote, 0.3385, 0.029), (0.0, 1.0, 0.10), 0.0038, 0.012, _i_jaw)     # dent du bas
IDS = np.array([x + _vbase for f in DF for x in f], dtype=np.uint32)
P = np.vstack([P, DV])
NRM = np.vstack([NRM, DN])
UV = np.vstack([UV, np.tile(_uvb, (len(DV), 1))])
_JOIN = np.zeros((len(DV), 4), dtype=np.uint16)
_WEI = np.zeros((len(DV), 4), dtype=np.float32)
for i, j in enumerate(DJ):
    _JOIN[i, 0] = j
    _WEI[i, 0] = 1.0
JOINTS = np.vstack([JOINTS, _JOIN])
WEIGHTS = np.vstack([WEIGHTS, _WEI])
IDX = np.concatenate([IDX, IDS])
# cavite buccale : 1 centre + 6 sommets, 6 triangles en eventail, enfoncee dans la bouche
_cav_c = np.array([0.0, 0.3500, 0.0145])
DV.append(_cav_c); DN.append(np.array([0.0, -1.0, 0.0])); DJ.append(_i_head)
_cav_base = len(DV)
for k in range(6):
    a = k * np.pi * 2.0 / 6.0
    DV.append(_cav_c + np.array([0.017 * np.cos(a), 0.0, 0.011 * np.sin(a)]))
    DN.append(np.array([np.cos(a), -0.2, np.sin(a)]))
    DJ.append(_i_head if k % 2 == 0 else _i_jaw)
for k in range(6):
    DF.append((_cav_base - 1, _cav_base + k, _cav_base + (k + 1) % 6))
DV = np.array(DV); DN = np.array(DN)      # conversion apres dents ET cavite buccale
print("dents : %d sommets, %d triangles (teinte UV %.3f, %.3f) | bouche : teinte UV %.3f, %.3f"
      % (len(DV), len(DF), _uvb[0], _uvb[1], _uvs[0], _uvs[1]))

# ------------------------------------------------------------------ bascule 180 deg : le visage regarde -Z (convention Godot)
P[:, 0] *= -1.0
P[:, 2] *= -1.0
NRM[:, 0] *= -1.0
NRM[:, 2] *= -1.0
J2b = {k: (-v[0], v[1], -v[2]) for k, v in J2.items()}

# ------------------------------------------------------------------ matrices de repos
# correspondance nom d'os -> nom du point d'articulation (dans J2)
HEADKEY = {
    "hips": "hips", "spine": "spine", "chest": "chest", "neck": "neck", "head": "head",
    "clavL": "clavL", "upperarmL": "shoulderL", "forearmL": "elbowL", "handL": "wristL",
    "thighL": "hipL", "shinL": "kneeL", "footL": "ankleL", "toeL": "toeL",
    "clavR": "clavR", "upperarmR": "shoulderR", "forearmR": "elbowR", "handR": "wristR",
    "jaw": "jaw",
    "thighR": "hipR", "shinR": "kneeR", "footR": "ankleR", "toeR": "toeR",
}
Y0 = float(P[:, 1].min())          # -0.5 : les pieds du maillage source
loc = {}
for name, parent, a, b in BONES:
    ta = np.array(J2b[HEADKEY[name]])
    tp = np.array(J2b[HEADKEY[parent]]) if parent else np.zeros(3)
    loc[name] = ta - tp
# le maillage est recentre sur les pieds (Y0 = -0.5) : l'os racine doit suivre le meme decalage,
# sinon toutes les rotations pivotent 0,5 m trop bas (bug corrige en v19).
loc["hips"] = loc["hips"] + np.array([0.0, -Y0, 0.0])
# offset du squelette : les pieds tombent a y=0 dans le modele (calcule plus haut)

def mat4(t, ident=True):
    M = np.eye(4, dtype=np.float64)
    M[:3, 3] = t
    return M

glob = {}
for name, parent, a, b in BONES:
    m = mat4(loc[name])
    glob[name] = (glob[parent] @ m) if parent else m
IBM = np.stack([np.linalg.inv(glob[name]) for name in NAMES]).astype(np.float32).reshape(NB, 16)

# ------------------------------------------------------------------ ecriture glb
BIN_OUT = bytearray()
BV = []
def add_view(data, target=None, stride=None):
    while len(BIN_OUT) % 4:
        BIN_OUT.append(0)
    off = len(BIN_OUT)
    BIN_OUT.extend(data)
    v = {"buffer": 0, "byteOffset": off, "byteLength": len(data)}
    if target: v["target"] = target
    if stride: v["byteStride"] = stride
    BV.append(v)
    return len(BV) - 1

pos_f = (P.astype(np.float32) - np.array([0, Y0, 0], dtype=np.float32)).astype(np.float32)
v_pos = add_view(pos_f.tobytes(), 34962)
v_nrm = add_view(NRM.tobytes(), 34962)
v_uv  = add_view(UV.tobytes(), 34962)
v_jnt = add_view(JOINTS.tobytes(), 34962)
v_wgt = add_view(WEIGHTS.tobytes(), 34962)
v_idx = add_view(IDX.astype(np.uint32).tobytes(), 34963)
v_ibm = add_view(IBM.tobytes())
v_img = add_view(_img_bytes)

mins = pos_f.min(axis=0).tolist(); maxs = pos_f.max(axis=0).tolist()
ACC = [
    {"bufferView": v_pos, "componentType": 5126, "count": len(P), "type": "VEC3", "min": mins, "max": maxs},
    {"bufferView": v_nrm, "componentType": 5126, "count": len(P), "type": "VEC3"},
    {"bufferView": v_uv,  "componentType": 5126, "count": len(P), "type": "VEC2"},
    {"bufferView": v_jnt, "componentType": 5123, "count": len(P), "type": "VEC4"},
    {"bufferView": v_wgt, "componentType": 5126, "count": len(P), "type": "VEC4"},
    {"bufferView": v_idx, "componentType": 5125, "count": len(IDX), "type": "SCALAR"},
    {"bufferView": v_ibm, "componentType": 5126, "count": NB, "type": "MAT4"},
]
# index des os dans les noeuds
node_of = {}
NODES = []
mesh_node = 0
NODES.append({"name": "MonstreMesh", "mesh": 0, "skin": 0})
for i, (name, parent, a, b) in enumerate(BONES):
    t = loc[name].tolist()
    NODES.append({"name": name, "translation": t})
for i, (name, parent, a, b) in enumerate(BONES):
    idx = 1 + i
    node_of[name] = idx
    if parent:
        NODES[node_of[parent]].setdefault("children", []).append(idx)
skin_joints = [node_of[n] for n in NAMES]

G = {
    "asset": {"version": "2.0", "generator": "LE31 rig_monstre (skinning par distance + lissage laplacien)"},
    "scene": 0,
    "scenes": [{"nodes": [0, node_of["hips"]]}],
    "nodes": NODES,
    "meshes": [{"name": "Monstre", "primitives": [{
        "attributes": {"POSITION": 0, "NORMAL": 1, "TEXCOORD_0": 2, "JOINTS_0": 3, "WEIGHTS_0": 4},
        "indices": 5, "material": 0}]}],
    "skins": [{"name": "LE31Skin", "inverseBindMatrices": 6, "joints": skin_joints, "skeleton": node_of["hips"]}],
    "materials": [{"name": "MonstrePeau", "pbrMetallicRoughness": {
        "baseColorTexture": {"index": 0}, "metallicFactor": 0.0, "roughnessFactor": 0.85}}],
    "textures": [{"source": 0, "sampler": 0}],
    "samplers": [{"magFilter": 9729, "minFilter": 9987, "wrapS": 10497, "wrapT": 10497}],
    "images": [{"bufferView": v_img, "mimeType": _mime}],
    "accessors": ACC,
    "bufferViews": BV,
    "buffers": [{"byteLength": len(BIN_OUT)}],
}
jb = json.dumps(G, separators=(",", ":")).encode("utf-8")
while len(jb) % 4:
    jb += b" "
out = bytearray()
out += b"glTF" + struct.pack("<II", 2, 12 + 8 + len(jb) + 8 + len(BIN_OUT))
out += struct.pack("<II", len(jb), 0x4E4F534A) + jb
out += struct.pack("<II", len(BIN_OUT), 0x004E4942) + bytes(BIN_OUT)
open(DST, "wb").write(bytes(out))
print("ecrit :", DST, len(out), "octets")

# ------------------------------------------------------------------ sidecar os
side = {
    "bones": [{"name": n, "parent": p,
               "head": [float(J2b[HEADKEY[n]][0]), float(J2b[HEADKEY[n]][1] - Y0), float(J2b[HEADKEY[n]][2])],
               "tail": [float(J2b[t][0]), float(J2b[t][1] - Y0), float(J2b[t][2])]}
              for n, p, t in [("hips","","spine"),("spine","hips","chest"),("chest","spine","neck"),
                              ("neck","chest","head"),("head","neck","headtip"),
                              ("clavL","chest","shoulderL"),("upperarmL","clavL","elbowL"),
                              ("forearmL","upperarmL","wristL"),("handL","forearmL","handL"),
                              ("clavR","chest","shoulderR"),("upperarmR","clavR","elbowR"),
                              ("forearmR","upperarmR","wristR"),("handR","forearmR","handR"),
                              ("thighL","hips","kneeL"),("shinL","thighL","ankleL"),
                              ("footL","shinL","toeL"),("toeL","footL","toetipL"),
                              ("thighR","hips","kneeR"),("shinR","thighR","ankleR"),
                              ("footR","shinR","toeR"),("toeR","footR","toetipR"),
                              ("jaw","head","jawtip")]],
    "hauteur_modele": float(max(p[1] for p in pos_f) - min(p[1] for p in pos_f)),
    "y_min": float(min(p[1] for p in pos_f)),
    "face": "-Z",
}
json.dump(side, open("/home/user/hantise/assets/models/monstre_rig_bones.json", "w"), indent=1)
print("os :", ", ".join(NAMES))
