# -*- coding: utf-8 -*-
"""
LE 31 — rig_creature.py (v27)
Rigge les creatures "next" (meshs statiques en T-pose, face +Z, sans squelette) :
  * squelette humanoid 20 os (MEMES noms que monstre_rig.glb -> animation codee partagee)
  * poids de sommets par gates anatomiques + lissage laplacien (comme rig_monstre.py)
  * bascule 180 degres a l'export : la face regarde -Z (convention Godot / code jeu)
  * normalisation : hauteur 1.0, pieds a y=0 (l'echelle du jeu = taille en metres)
Sortie par creature : <nom>_rig.glb + <nom>_rig_bones.json + <nom>_sole.json

Usage : python3 tools/rig_creature.py [enfant|rampant|marionnette|tous]
Verification visuelle : planches dans /home/user/renders/rig_<nom>.png
Aucune dependance hors numpy/scipy/Pillow.
"""
import json, struct, sys, os
import numpy as np
from scipy.spatial import cKDTree

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RENDERS = "/home/user/renders"

# ------------------------------------------------------------------ lecture / ecriture glb
def read_glb(path):
    d = open(path, "rb").read()
    assert d[:4] == b"glTF", "pas un GLB: %s" % path
    off, chunks = 12, []
    while off < len(d):
        cl, ct = struct.unpack("<II", d[off:off + 8])
        chunks.append((ct, off + 8, cl))
        off += 8 + cl
    J = json.loads(d[chunks[0][1]:chunks[0][1] + chunks[0][2]].decode("utf-8"))
    BIN = d[chunks[1][1]:chunks[1][1] + chunks[1][2]]
    return J, BIN

def accessor(J, BIN, i):
    a = J["accessors"][i]
    bv = J["bufferViews"][a["bufferView"]]
    o = bv.get("byteOffset", 0) + a.get("byteOffset", 0)
    n = a["count"]
    t = {"VEC3": 3, "VEC2": 2, "VEC4": 4, "SCALAR": 1, "MAT4": 16}[a["type"]]
    dt = {5126: np.float32, 5125: np.uint32, 5123: np.uint16, 5121: np.uint8}[a["componentType"]]
    return np.frombuffer(BIN, dtype=dt, count=n * t, offset=o).reshape(n, t)

def load_primitive(path):
    """retourne (P, UV, NRM, IDX) du premier mesh"""
    J, BIN = read_glb(path)
    prim = J["meshes"][0]["primitives"][0]
    P = accessor(J, BIN, prim["attributes"]["POSITION"]).astype(np.float64)
    UV = accessor(J, BIN, prim["attributes"]["TEXCOORD_0"]).astype(np.float64) if "TEXCOORD_0" in prim["attributes"] else np.zeros((len(P), 2))
    NRM = accessor(J, BIN, prim["attributes"]["NORMAL"]).astype(np.float64) if "NORMAL" in prim["attributes"] else np.zeros_like(P)
    IDX = accessor(J, BIN, prim["indices"]).astype(np.int64).ravel() if "indices" in prim else np.arange(len(P))
    return P, UV, NRM, IDX.reshape(-1, 3)

# ------------------------------------------------------------------ creatures
# reperes mesures sur les maillages (espace source, face +Z, T-pose).
# y_joint : hauteur ; x_joint : |x| (cote gauche ; miroir automatique) ; z_joint : avant(+)/arriere(-)
CREATURES = {
    # --- l'Enfant de cendre : y [-1.000, 0.994], mains |x|~0.93, bras a y~0.41
    "enfant": {
        "src": "assets/next/enfant_cendre.glb",
        "dst": "assets/models/enfant_rig.glb",
        "joints": {
            "hips":     (0.070, -0.040, -0.010),
            "spine":    (0.000,  0.150, -0.005),
            "chest":    (0.000,  0.310,  0.000),
            "neck":     (0.000,  0.520,  0.010),
            "head":     (0.000,  0.640,  0.020),
            "headtip":  (0.000,  0.950,  0.020),
            "clavL":    (0.030,  0.445,  0.000),
            "shoulderL":(0.115,  0.445, -0.010),
            "elbowL":   (0.420,  0.415, -0.020),
            "wristL":   (0.700,  0.405, -0.010),
            "handL":    (0.820,  0.410, -0.010),
            "hipL":     (0.075, -0.050, -0.010),
            "kneeL":    (0.100, -0.450,  0.000),
            "ankleL":   (0.145, -0.880, -0.040),
            "toeL":     (0.150, -0.965,  0.080),
            "toetipL":  (0.150, -0.985,  0.150),
        },
    },
    # --- le Rampant : meme famille, y [-0.922, 0.917]
    "rampant": {
        "src": "assets/next/monstre_rempant.glb",
        "dst": "assets/models/rampant_rig.glb",
        "joints": {
            "hips":     (0.070, -0.020, -0.010),
            "spine":    (0.000,  0.160, -0.005),
            "chest":    (0.000,  0.330,  0.000),
            "neck":     (0.000,  0.540,  0.010),
            "head":     (0.000,  0.660,  0.020),
            "headtip":  (0.000,  0.890,  0.020),
            "clavL":    (0.030,  0.465,  0.000),
            "shoulderL":(0.115,  0.465, -0.010),
            "elbowL":   (0.430,  0.435, -0.020),
            "wristL":   (0.720,  0.425, -0.010),
            "handL":    (0.850,  0.430, -0.010),
            "hipL":     (0.075, -0.030, -0.010),
            "kneeL":    (0.100, -0.430,  0.000),
            "ankleL":   (0.140, -0.820, -0.040),
            "toeL":     (0.145, -0.895,  0.080),
            "toetipL":  (0.145, -0.912,  0.150),
        },
    },
    # --- la Marionnette : meme famille, y [-0.891, 0.879]
    "marionnette": {
        "src": "assets/next/monstre_marionnette.glb",
        "dst": "assets/models/marionnette_rig.glb",
        "joints": {
            "hips":     (0.065, -0.020, -0.010),
            "spine":    (0.000,  0.150, -0.005),
            "chest":    (0.000,  0.310,  0.000),
            "neck":     (0.000,  0.510,  0.010),
            "head":     (0.000,  0.630,  0.020),
            "headtip":  (0.000,  0.850,  0.020),
            "clavL":    (0.030,  0.440,  0.000),
            "shoulderL":(0.110,  0.440, -0.010),
            "elbowL":   (0.420,  0.415, -0.020),
            "wristL":   (0.710,  0.410, -0.010),
            "handL":    (0.840,  0.415, -0.010),
            "hipL":     (0.070, -0.030, -0.010),
            "kneeL":    (0.095, -0.420,  0.000),
            "ankleL":   (0.135, -0.790, -0.040),
            "toeL":     (0.140, -0.860,  0.080),
            "toetipL":  (0.140, -0.880,  0.150),
        },
    },
}

# os = (nom, parent, cle_tete, cle_queue) — memes noms que monstre_rig (code jeu partage)
BONES = [
    ("hips",      None,      "hips",      "spine"),
    ("spine",     "hips",    "spine",     "chest"),
    ("chest",     "spine",   "chest",     "neck"),
    ("neck",      "chest",   "neck",      "head"),
    ("head",      "neck",    "head",      "headtip"),
    ("clavL",     "chest",   "clavL",     "shoulderL"),
    ("upperarmL", "clavL",   "shoulderL", "elbowL"),
    ("forearmL",  "upperarmL","elbowL",   "wristL"),
    ("handL",     "forearmL","wristL",    "handL"),
    ("clavR",     "chest",   "clavR",     "shoulderR"),
    ("upperarmR", "clavR",   "shoulderR", "elbowR"),
    ("forearmR",  "upperarmR","elbowR",   "wristR"),
    ("handR",     "forearmR","wristR",    "handR"),
    ("thighL",    "hips",    "hipL",      "kneeL"),
    ("shinL",     "thighL",  "kneeL",     "ankleL"),
    ("footL",     "shinL",   "ankleL",    "toeL"),
    ("toeL",      "footL",   "toeL",      "toetipL"),
    ("thighR",    "hips",    "hipR",      "kneeR"),
    ("shinR",     "thighR",  "kneeR",     "ankleR"),
    ("footR",     "shinR",   "ankleR",    "toeR"),
    ("toeR",      "footR",   "toeR",      "toetipR"),
]
NAMES = [b[0] for b in BONES]
NB = len(BONES)


def mir_joints(J2):
    out = dict(J2)
    for k, v in J2.items():
        if k.endswith("L"):
            out[k[:-1] + "R"] = (-v[0], v[1], v[2])
    return out


# ------------------------------------------------------------------ poids
def sstep(t):
    t = np.clip(t, 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)

def gate(v, lo, hi, soft):
    return sstep((v - (lo - soft)) / soft) * sstep(((hi + soft) - v) / soft)


def build_gates(J2):
    """gates anatomiques derivees des reperes (espace source)"""
    def y(k): return J2[k][1]
    def ax(k): return abs(J2[k][0])
    G = {}
    G["hips"]     = [("y", y("hipL") - 0.10, y("spine") + 0.04, 0.07), ("ax", -9.0, ax("shoulderL") * 0.62, 0.06)]
    G["spine"]    = [("y", y("hips") + 0.02, y("chest") + 0.05, 0.08), ("ax", -9.0, ax("shoulderL") * 0.70, 0.07)]
    G["chest"]    = [("y", y("spine") - 0.06, y("neck") + 0.02, 0.09), ("ax", -9.0, ax("shoulderL") * 0.95, 0.08)]
    G["neck"]     = [("y", y("chest") + 0.02, y("head") + 0.06, 0.06), ("ax", -9.0, ax("shoulderL") * 0.45, 0.05)]
    G["head"]     = [("y", y("neck") - 0.02, 9.0, 0.08)]
    G["clavL"]    = [("y", y("chest") - 0.02, y("head") - 0.02, 0.07), ("ax", -9.0, ax("elbowL") * 0.55, 0.06), ("x", 0.005, 9.0, 0.04)]
    G["upperarmL"] = [("y", y("elbowL") - 0.14, y("shoulderL") + 0.14, 0.08),
                      ("ax", (ax("shoulderL") + ax("elbowL")) * 0.32, 9.0, 0.06), ("x", 0.02, 9.0, 0.04)]
    G["forearmL"] = [("y", y("wristL") - 0.12, y("elbowL") + 0.12, 0.07),
                     ("ax", (ax("elbowL") + ax("wristL")) * 0.42, 9.0, 0.05), ("x", 0.05, 9.0, 0.04)]
    G["handL"]    = [("y", y("handL") - 0.14, y("wristL") + 0.12, 0.06),
                     ("ax", (ax("wristL") + ax("handL")) * 0.48, 9.0, 0.05), ("x", 0.05, 9.0, 0.04)]
    G["thighL"]   = [("y", y("kneeL") - 0.12, y("hipL") + 0.10, 0.09), ("ax", -9.0, ax("hipL") + (ax("kneeL") - ax("hipL")) * 0.4 + 0.05, 0.05), ("x", -0.005, 9.0, 0.04)]
    G["shinL"]    = [("y", y("ankleL") + 0.02, y("kneeL") + 0.10, 0.08), ("x", -0.005, 9.0, 0.04)]
    G["footL"]    = [("y", -9.0, y("ankleL") + 0.03, 0.05), ("x", -0.005, 9.0, 0.03)]
    G["toeL"]     = [("y", -9.0, y("toeL") + 0.02, 0.04), ("x", -0.005, 9.0, 0.03), ("z", J2["toeL"][2] - 0.02, 9.0, 0.05)]
    for k in list(G.keys()):
        if k.endswith("L"):
            g = []
            for var, lo, hi, so in G[k]:
                if var == "x":
                    lo, hi = -hi, -lo
                g.append((var, lo, hi, so))
            G[k[:-1] + "R"] = g
    return G


def skin(P, J2, verbose=True):
    GATES = build_gates(J2)
    AX = np.abs(P[:, 0])
    MASK = {}
    for name, _p, _a, _b in BONES:
        m = np.ones(len(P))
        for var, lo, hi, so in GATES[name]:
            v = P[:, 1] if var == "y" else (P[:, 2] if var == "z" else (AX if var == "ax" else P[:, 0]))
            m *= gate(v, lo, hi, so)
        MASK[name] = m
    W = np.zeros((len(P), NB))
    for bi, (name, parent, a, b) in enumerate(BONES):
        a = np.array(J2[a]); b = np.array(J2[b])
        ab = b - a; L2 = float(ab @ ab) + 1e-9
        t = np.clip(((P - a) @ ab) / L2, 0.0, 1.0)
        dist = np.linalg.norm(P - (a + t[:, None] * ab), axis=1)
        if name in ("hips", "spine", "chest", "neck", "head"):
            dist = dist + 0.03
        W[:, bi] = MASK[name] / np.power(dist + 0.012, 6.0)
    s = W.sum(axis=1, keepdims=True)
    W = np.divide(W, np.maximum(s, 1e-12))
    tree = cKDTree(P)
    _, nn = tree.query(P, k=9, workers=-1)
    nn = nn[:, 1:]
    for _ in range(4):
        Wn = W[nn].mean(axis=1)
        W = 0.40 * W + 0.60 * Wn
        W = np.divide(W, np.maximum(W.sum(axis=1, keepdims=True), 1e-12))
    if verbose:
        orphan = (W.max(axis=1) < 0.35).sum()
        print("  poids : %d sommets, orphelins (max<0.35) = %d (%.1f%%)" % (len(P), orphan, 100.0 * orphan / len(P)))
    return W


# ------------------------------------------------------------------ export
def export_rig(name, P, NRM, UV, IDX, W, J2, y0, height, flip=True):
    cfg = CREATURES[name]
    # bascule 180 deg : la face regarde -Z (convention Godot)
    if flip:
        P = P.copy(); NRM = NRM.copy()
        P[:, 0] *= -1.0; P[:, 2] *= -1.0
        NRM[:, 0] *= -1.0; NRM[:, 2] *= -1.0
        J2 = {k: (-v[0], v[1], -v[2]) for k, v in J2.items()}
    # normalisation : hauteur 1.0, pieds a 0 (IMPORTANT : meme decalage pour le maillage ET les os,
    # sinon les rotations pivotent trop haut et le corps s'envole)
    sc = 1.0 / height
    P = (P - np.array([0.0, y0, 0.0])) * sc
    J2 = {k: (v[0] * sc, (v[1] - y0) * sc, v[2] * sc) for k, v in J2.items()}

    HEADKEY = {b[0]: b[2] for b in BONES}
    loc = {}
    for name_b, parent, a, b in BONES:
        ta = np.array(J2[a])
        tp = np.array(J2[HEADKEY[parent]]) if parent else np.zeros(3)
        loc[name_b] = ta - tp
    # pieds deja a 0 apres normalisation

    def mat4(t):
        M = np.eye(4); M[:3, 3] = t; return M

    glob = {}
    for name_b, parent, a, b in BONES:
        m = mat4(loc[name_b])
        glob[name_b] = (glob[parent] @ m) if parent else m
    IBM = np.stack([np.linalg.inv(glob[n]) for n in NAMES]).astype(np.float32).reshape(NB, 16)

    top4 = np.argsort(-W, axis=1)[:, :4]
    w4 = np.take_along_axis(W, top4, 1)
    w4 = w4 / np.maximum(w4.sum(axis=1, keepdims=True), 1e-9)
    JOINTS = top4.astype(np.uint16)
    WEIGHTS = w4.astype(np.float32)

    BIN_OUT = bytearray(); BV = []
    def add_view(data, target=None):
        while len(BIN_OUT) % 4:
            BIN_OUT.append(0)
        off = len(BIN_OUT); BIN_OUT.extend(data)
        v = {"buffer": 0, "byteOffset": off, "byteLength": len(data)}
        if target: v["target"] = target
        BV.append(v); return len(BV) - 1

    pos_f = P.astype(np.float32)
    v_pos = add_view(pos_f.tobytes(), 34962)
    v_nrm = add_view(NRM.astype(np.float32).tobytes(), 34962)
    v_uv = add_view(UV.astype(np.float32).tobytes(), 34962)
    v_jnt = add_view(JOINTS.tobytes(), 34962)
    v_wgt = add_view(WEIGHTS.tobytes(), 34962)
    v_idx = add_view(IDX.astype(np.uint32).tobytes(), 34963)
    v_ibm = add_view(IBM.tobytes())

    mins = pos_f.min(0).tolist(); maxs = pos_f.max(0).tolist()
    ACC = [
        {"bufferView": v_pos, "componentType": 5126, "count": len(P), "type": "VEC3", "min": mins, "max": maxs},
        {"bufferView": v_nrm, "componentType": 5126, "count": len(P), "type": "VEC3"},
        {"bufferView": v_uv, "componentType": 5126, "count": len(P), "type": "VEC2"},
        {"bufferView": v_jnt, "componentType": 5123, "count": len(P), "type": "VEC4"},
        {"bufferView": v_wgt, "componentType": 5126, "count": len(P), "type": "VEC4"},
        {"bufferView": v_idx, "componentType": 5125, "count": len(IDX), "type": "SCALAR"},
        {"bufferView": v_ibm, "componentType": 5126, "count": NB, "type": "MAT4"},
    ]
    NODES = [{"name": "CreatureMesh", "mesh": 0, "skin": 0}]
    for name_b, parent, a, b in BONES:
        NODES.append({"name": name_b, "translation": loc[name_b].tolist()})
    node_of = {name_b: 1 + i for i, (name_b, _p, _a, _b) in enumerate(BONES)}
    for name_b, parent, a, b in BONES:
        if parent:
            NODES[node_of[parent]].setdefault("children", []).append(node_of[name_b])
    skin_joints = [node_of[n] for n in NAMES]

    G = {
        "asset": {"version": "2.0", "generator": "LE31 rig_creature v27"},
        "scene": 0,
        "scenes": [{"nodes": [0, node_of["hips"]]}],
        "nodes": NODES,
        "meshes": [{"name": "Creature", "primitives": [{
            "attributes": {"POSITION": 0, "NORMAL": 1, "TEXCOORD_0": 2, "JOINTS_0": 3, "WEIGHTS_0": 4},
            "indices": 5, "material": 0}]}],
        "skins": [{"name": "LE31Skin", "inverseBindMatrices": 6, "joints": skin_joints, "skeleton": node_of["hips"]}],
        "materials": [{"name": "CreaturePeau", "pbrMetallicRoughness": {
            "baseColorFactor": [0.75, 0.73, 0.70, 1.0], "metallicFactor": 0.0, "roughnessFactor": 0.9}}],
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
    dst = os.path.join(ROOT, cfg["dst"])
    open(dst, "wb").write(bytes(out))
    print("  ecrit :", cfg["dst"], len(out), "octets")

    # sidecar os (meme format que monstre_rig_bones.json)
    tails = {n: t for n, _p, _a, t in [(b[0], b[1], b[2], b[3]) for b in BONES]}
    side = {"bones": [{"name": n, "parent": p,
                       "head": [float(J2[a][0]), float(J2[a][1]), float(J2[a][2])],
                       "tail": [float(J2[b][0]), float(J2[b][1]), float(J2[b][2])]}
                      for n, p, a, b in BONES],
            "hauteur_modele": 1.0, "y_min": 0.0, "face": "-Z"}
    json.dump(side, open(dst.replace(".glb", "_bones.json"), "w"), indent=1)

    # semelle : enveloppe des points de contact de chaque pied (repere local du pied)
    res = {}
    IDXn = {n: i for i, n in enumerate(NAMES)}
    P2 = pos_f.astype(np.float64)
    for side_name in ("L", "R"):
        ib = IBM[IDXn["foot" + side_name]].reshape(4, 4).astype(np.float64)
        ph = P2 @ ib[:3, :3].T + ib[:3, 3]
        wf = np.zeros(len(P2)); wt = np.zeros(len(P2))
        for k in range(4):
            wf += WEIGHTS[:, k] * (JOINTS[:, k] == IDXn["foot" + side_name])
            wt += WEIGHTS[:, k] * (JOINTS[:, k] == IDXn["toe" + side_name])
        sel = ph[(wf + wt) > 0.55]
        if len(sel) < 10:
            sel = ph[(wf + wt) > 0.30]
        if len(sel) == 0:
            res["foot" + side_name] = {"hull": [[0.02, -0.05, -0.05], [0.02, -0.05, 0.05], [-0.02, -0.02, 0.05]]}
            continue
        ylo = sel[:, 1].min()
        sel = sel[sel[:, 1] < ylo + 0.06]
        cxz = sel[:, [0, 2]]; c = cxz.mean(0)
        ang = np.arctan2(cxz[:, 1] - c[1], cxz[:, 0] - c[0])
        hull = []
        for k in range(36):
            a0 = -np.pi + k * 2 * np.pi / 36
            m2 = (ang >= a0) & (ang < a0 + 2 * np.pi / 36)
            if m2.sum() == 0:
                continue
            sub = sel[m2]
            r = np.hypot(sub[:, 0] - c[0], sub[:, 2] - c[1])
            hull.append(sub[np.argmax(r)].tolist())
        res["foot" + side_name] = {"hull": hull}
    json.dump(res, open(dst.replace(".glb", "_sole.json"), "w"))
    print("  os : %d | semelle L=%d pts R=%d pts" % (NB, len(res["footL"]["hull"]), len(res["footR"]["hull"])))
    return pos_f, JOINTS, WEIGHTS, IBM, loc


# ------------------------------------------------------------------ verification visuelle (FK + rendu)
def render(P, IDX, cam_dir, fname, w=460, h=560, label=""):
    from PIL import Image, ImageDraw
    C = (P.max(0) + P.min(0)) / 2
    cd = np.array(cam_dir, float); cd /= np.linalg.norm(cd)
    up = np.array([0, 1, 0.0])
    right = np.cross(up, cd); right /= np.linalg.norm(right)
    up2 = np.cross(cd, right)
    dist = 2.6
    E = C - cd * dist
    R = P - E
    x = R @ right; y = R @ up2; z = R @ cd
    f = 1.15 * h / 2
    px = (x / np.maximum(z, 1e-6) * f + w / 2)
    py = (-y / np.maximum(z, 1e-6) * f + h / 2)
    img = np.zeros((h, w, 3)); zb = np.full((h, w), 1e9)
    tris = IDX.reshape(-1, 3)
    v0, v1, v2 = P[tris[:, 0]], P[tris[:, 1]], P[tris[:, 2]]
    n = np.cross(v1 - v0, v2 - v0)
    ln = np.linalg.norm(n, axis=1); ln[ln == 0] = 1; n /= ln[:, None]
    light = -cd + np.array([0.3, 0.55, 0.0]); light /= np.linalg.norm(light)
    shade = np.clip(n @ light, 0, 1) * 0.55 + 0.45
    p0 = np.stack([px[tris[:, 0]], py[tris[:, 0]], z[tris[:, 0]]], 1)
    p1 = np.stack([px[tris[:, 1]], py[tris[:, 1]], z[tris[:, 1]]], 1)
    p2 = np.stack([px[tris[:, 2]], py[tris[:, 2]], z[tris[:, 2]]], 1)
    for ti in np.argsort(-z[tris].mean(1)):
        a, b, c = p0[ti], p1[ti], p2[ti]
        minx = int(max(0, np.floor(min(a[0], b[0], c[0])))); maxx = int(min(w - 1, np.ceil(max(a[0], b[0], c[0]))))
        miny = int(max(0, np.floor(min(a[1], b[1], c[1])))); maxy = int(min(h - 1, np.ceil(max(a[1], b[1], c[1]))))
        if minx > maxx or miny > maxy: continue
        gx, gy = np.meshgrid(np.arange(minx, maxx + 1), np.arange(miny, maxy + 1))
        d2 = (b[1] - c[1]) * (a[0] - c[0]) + (c[0] - b[0]) * (a[1] - c[1])
        if abs(d2) < 1e-12: continue
        l1 = ((b[1] - c[1]) * (gx - c[0]) + (c[0] - b[0]) * (gy - c[1])) / d2
        l2 = ((c[1] - a[1]) * (gx - c[0]) + (a[0] - c[0]) * (gy - c[1])) / d2
        l3 = 1 - l1 - l2
        m = (l1 >= 0) & (l2 >= 0) & (l3 >= 0)
        if not m.any(): continue
        zz = l1 * a[2] + l2 * b[2] + l3 * c[2]
        sub = zb[miny:maxy + 1, minx:maxx + 1]
        upd = m & (zz < sub)
        sub[upd] = zz[upd]
        s = min(float(shade[ti]), 1.0)
        img[miny:maxy + 1, minx:maxx + 1][upd] = np.array([s * 255, s * 240, s * 220])
    im = Image.fromarray(img.astype(np.uint8))
    d = ImageDraw.Draw(im)
    d.text((8, 8), label, fill=(255, 220, 120))
    im.save(fname)


def fk_pose(P0, JOINTS, WEIGHTS, loc, angles, fname, cam_dir=(0, 0.12, -1)):
    """angles : {os: (axe_np, angle)} — applique FK et rend (verification de la peau)"""
    NAMES_LOCAL = NAMES
    # transform globale de repos
    def mat4(t):
        M = np.eye(4); M[:3, 3] = t; return M
    rest_glob = {}
    parent_of = {b[0]: b[1] for b in BONES}
    for name_b, parent, a, b in BONES:
        m = mat4(loc[name_b])
        rest_glob[name_b] = (rest_glob[parent] @ m) if parent else m
    # poses locales
    def rot(axis, ang):
        axis = axis / np.linalg.norm(axis)
        K = np.array([[0, -axis[2], axis[1]], [axis[2], 0, -axis[0]], [-axis[1], axis[0], 0]])
        return np.eye(3) + np.sin(ang) * K + (1 - np.cos(ang)) * K @ K
    def matR(R, t):
        M = np.eye(4); M[:3, :3] = R; M[:3, 3] = t; return M
    # skinning : deform = pose_glob @ inv(rest_glob) @ inv(ibm)... plus simple :
    # vertex v dans le repere du mesh ; poids par os ; pose_glob @ rest_glob^-1 applique
    pose_glob = {}
    for name_b, parent, a, b in BONES:
        t = loc[name_b]
        if name_b in angles:
            axis, ang = angles[name_b]
            M = matR(rot(np.array(axis, float), ang), t)
        else:
            M = mat4(t)
        pose_glob[name_b] = (pose_glob[parent] @ M) if parent else M
    # matrice skinnee par sommet (top4)
    P2 = P0.astype(np.float64).copy()
    out = np.zeros_like(P2)
    for k in range(4):
        ji = JOINTS[:, k].astype(int)
        w = WEIGHTS[:, k]
        for bi in np.unique(ji):
            sel = (ji == bi) & (w > 1e-4)
            if not sel.any(): continue
            nm = NAMES_LOCAL[bi]
            D = pose_glob[nm] @ np.linalg.inv(rest_glob[nm])
            v = P2[sel]
            v4 = np.concatenate([v, np.ones((len(v), 1))], 1) @ D.T
            out[sel] += w[sel, None] * v4[:, :3]
    render(out, IDX_G, cam_dir, fname, label="")
    print("  rendu pose :", fname)


IDX_G = None

def build(name):
    global IDX_G
    cfg = CREATURES[name]
    print("== %s ==" % name)
    P, UV, NRM, IDX = load_primitive(os.path.join(ROOT, cfg["src"]))
    IDX_G = IDX
    ymin, ymax = P[:, 1].min(), P[:, 1].max()
    height = ymax - ymin
    print("  %d sommets, %d tri, hauteur source %.3f" % (len(P), len(IDX), height))
    J2 = mir_joints(cfg["joints"])
    W = skin(P, J2)
    pos_f, JOINTS, WEIGHTS, IBM, loc = export_rig(name, P, NRM, UV, IDX, W, J2, ymin, height)
    # planche de verification : repos + inclinaison chasse + bras leves
    os.makedirs(RENDERS, exist_ok=True)
    fk_pose(pos_f, JOINTS, WEIGHTS, loc, {}, os.path.join(RENDERS, "rig_%s_repos.png" % name))
    fk_pose(pos_f, JOINTS, WEIGHTS, loc,
            {"hips": ([1, 0, 0], -0.35), "chest": ([1, 0, 0], -0.45), "head": ([1, 0, 0], -0.25),
             "upperarmL": ([1, 0, 0], -0.8), "upperarmR": ([1, 0, 0], -0.8),
             "forearmL": ([1, 0, 0], -0.7), "forearmR": ([1, 0, 0], -0.7)},
            os.path.join(RENDERS, "rig_%s_chasse.png" % name))
    print()


if __name__ == "__main__":
    what = sys.argv[1] if len(sys.argv) > 1 else "tous"
    todo = list(CREATURES.keys()) if what == "tous" else [what]
    for nm in todo:
        assert nm in CREATURES, "creature inconnue : %s" % nm
        build(nm)
    print("Termine.")
