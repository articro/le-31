# -*- coding: utf-8 -*-
"""LE 31 — extrait l'enveloppe de la semelle (points de contact du pied) depuis monstre_rig.glb
   et l'ecrit dans assets/models/monstre_sole.json (utilise par le jeu pour poser les pieds).
   A relancer apres toute regeneration du rig."""
import json, struct, numpy as np

GLB = "/home/user/hantise/assets/models/monstre_rig.glb"
OUT = "/home/user/hantise/assets/models/monstre_sole.json"
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
JN = acc(prim["attributes"]["JOINTS_0"]).astype(int)
WG = acc(prim["attributes"]["WEIGHTS_0"]).astype(np.float64)
IBM = acc(J["skins"][0]["inverseBindMatrices"]).reshape(-1, 4, 4).astype(np.float64)
NAMES = [J["nodes"][i]["name"] for i in J["skins"][0]["joints"]]
IDX = {n: i for i, n in enumerate(NAMES)}
res = {}
for side in ("L", "R"):
    ib = IBM[IDX["foot" + side]]
    ph = P @ ib[:3, :3].T + ib[:3, 3]
    wf = np.zeros(len(P)); wt = np.zeros(len(P))
    for k in range(4):
        wf += WG[:, k] * (JN[:, k] == IDX["foot" + side])
        wt += WG[:, k] * (JN[:, k] == IDX["toe" + side])
    sel = ph[(wf + wt) > 0.60]
    sel = sel[sel[:, 1] < -0.05]
    cxz = sel[:, [0, 2]]; c = cxz.mean(0)
    ang = np.arctan2(cxz[:, 1] - c[1], cxz[:, 0] - c[0])
    hull = []
    for k in range(90):
        a0 = -np.pi + k * 2 * np.pi / 90
        m2 = (ang >= a0) & (ang < a0 + 2 * np.pi / 90)
        if m2.sum() == 0:
            continue
        sub = sel[m2]
        r = np.hypot(sub[:, 0] - c[0], sub[:, 2] - c[1])
        hull.append(sub[np.argmax(r)])
    hull = np.array(hull)
    res["foot" + side] = {"hull": [[round(float(v[0]), 5), round(float(v[1]), 5), round(float(v[2]), 5)] for v in hull],
                          "y_min": float(sel[:, 1].min())}
    print("pied %s : %d points de semelle, enveloppe %d" % (side, len(sel), len(hull)))
json.dump(res, open(OUT, "w"), indent=1)
print("ecrit", OUT)
