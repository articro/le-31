# -*- coding: utf-8 -*-
"""LE 31 — rendu hors-ligne du monstre rigge (z-buffer numpy) pour juger la qualite
   du skinning sans lancer Godot. Sortie : work/rig_pose1.png, rig_pose2.png ..."""
import json, struct, sys
import numpy as np
from PIL import Image

GLB = "/home/user/hantise/assets/models/monstre_rig.glb"
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
UV = acc(prim["attributes"]["TEXCOORD_0"]).astype(np.float64)
NR = acc(prim["attributes"]["NORMAL"]).astype(np.float64)
JN = acc(prim["attributes"]["JOINTS_0"]).astype(int)
WG = acc(prim["attributes"]["WEIGHTS_0"]).astype(np.float64)
IDX = acc(prim["indices"]).astype(np.int64).ravel().reshape(-1, 3)
NAMES = [J["nodes"][i]["name"] for i in J["skins"][0]["joints"]]
NB = len(NAMES)
nodes = {n.get("name"): n for n in J["nodes"] if "name" in n}
parent = {}
for n in J["nodes"]:
    for c in n.get("children", []):
        parent[J["nodes"][c].get("name")] = n.get("name", "")
rest_t = {nm: np.array(nodes[nm].get("translation", [0, 0, 0]), dtype=np.float64) for nm in NAMES}

# ---- texture webp -> array
import os
    TEXP = "/home/user/hantise/assets/models/monstre_skin.png"
    if not os.path.exists(TEXP):
        TEXP = "/home/user/hantise/assets/models/monstre2_tex.png"
    img = np.array(Image.open(TEXP).convert("RGB"), dtype=np.float64) / 255.0
IH, IW = img.shape[:2]

def rot(axis, a):
    c, s = np.cos(a), np.sin(a); x, y, z = axis / (np.linalg.norm(axis) + 1e-12)
    return np.array([[c+x*x*(1-c), x*y*(1-c)-z*s, x*z*(1-c)+y*s],
                     [y*x*(1-c)+z*s, c+y*y*(1-c), y*z*(1-c)-x*s],
                     [z*x*(1-c)-y*s, z*y*(1-c)+x*s, c+z*z*(1-c)]])

def pose(T):
    """T : {os: list[(axe, angle)]} -> matrices (translation globale, rotation globale) et sommets deformes"""
    Rl = {}
    for nm in NAMES:
        R = np.eye(3)
        for ax, an in T.get(nm, []):
            R = R @ rot(np.array(ax, dtype=np.float64), an)
        Rl[nm] = R
    Tg, Rg = {}, {}
    for nm in NAMES:
        p = parent.get(nm, "")
        Rg[nm] = (Rg[p] @ Rl[nm]) if p in Rg else Rl[nm]
        t = rest_t[nm]
        Tg[nm] = ((Tg[p] + Rg[p] @ t) if p in Tg else t)
    out = np.zeros_like(P); nout = np.zeros_like(P)
    for k in range(4):
        jn, w = JN[:, k], WG[:, k]
        for j in np.unique(jn[w > 1e-5]):
            m = (jn == j) & (w > 1e-5)
            Tb, Rb = Tg[NAMES[j]], Rg[NAMES[j]]
            out[m] += w[m, None] * (Tb + (P[m] - Tb) @ Rb)
            nout[m] += w[m, None] * (NR[m] @ Rb)
    nout /= np.maximum(np.linalg.norm(nout, axis=1, keepdims=True), 1e-9)
    return out, nout

def render(V, N, path, W=460, H=680, yaw=0.0, pitch=-0.05, zoom=1.02, bg=(0.055, 0.05, 0.06)):
    # camera : regarde vers -Z apres rotation yaw/pitch, placee devant le personnage
    Ry = rot(np.array([0, 1.0, 0]), yaw); Rx = rot(np.array([1.0, 0, 0]), pitch)
    Rcam = Rx @ Ry
    Vc = V @ Rcam.T
    c = Vc.mean(axis=0)
    Vc[:, 0] -= c[0]; Vc[:, 2] -= c[2]
    # projection perspective simple
    f = 1.15
    z = Vc[:, 2] + 2.2
    sx = (Vc[:, 0] * f / z) * (H / 2.0) * zoom + W * 0.5
    sy = (-(Vc[:, 1] - c[1]) * f / z) * (H / 2.0) * zoom + H * 0.52
    depth = -z
    buf = np.full((H, W, 3), bg, dtype=np.float64)
    zb = np.full((H, W), 1e9, dtype=np.float64)
    # eclairage : lampe au-dessus/devant + lumiere d'appoint froide
    L1 = np.array([0.35, 0.75, 0.55]); L1 /= np.linalg.norm(L1)
    L2 = np.array([-0.6, 0.15, 0.4]); L2 /= np.linalg.norm(L2)
    tri = IDX
    n = len(tri)
    for t in range(n):
        i0, i1, i2 = tri[t]
        x0, y0 = sx[i0], sy[i0]; x1, y1 = sx[i1], sy[i1]; x2, y2 = sx[i2], sy[i2]
        minx = max(int(min(x0, x1, x2)), 0); maxx = min(int(max(x0, x1, x2)) + 1, W - 1)
        miny = max(int(min(y0, y1, y2)), 0); maxy = min(int(max(y0, y1, y2)) + 1, H - 1)
        if maxx <= minx or maxy <= miny:
            continue
        area = (x1 - x0) * (y2 - y0) - (x2 - x0) * (y1 - y0)
        if abs(area) < 1e-9:
            continue
        xs = np.arange(minx, maxx + 1) + 0.5
        ys = np.arange(miny, maxy + 1) + 0.5
        X, Y = np.meshgrid(xs, ys)
        w0 = ((x1 - X) * (y2 - Y) - (x2 - X) * (y1 - Y)) / area
        w1 = ((x2 - X) * (y0 - Y) - (x0 - X) * (y2 - Y)) / area
        w2 = 1.0 - w0 - w1
        inside = (w0 >= 0) & (w1 >= 0) & (w2 >= 0)
        if not inside.any():
            continue
        zz = w0 * depth[i0] + w1 * depth[i1] + w2 * depth[i2]
        vb = zb[miny:maxy + 1, minx:maxx + 1]
        cb = buf[miny:maxy + 1, minx:maxx + 1]
        m = inside & (zz < vb)
        if not m.any():
            continue
        u = w0 * UV[i0, 0] + w1 * UV[i1, 0] + w2 * UV[i2, 0]
        v = w0 * UV[i0, 1] + w1 * UV[i1, 1] + w2 * UV[i2, 1]
        px = np.clip((np.mod(u, 1.0)) * (IW - 1), 0, IW - 1).astype(int)
        py = np.clip((np.mod(v, 1.0)) * (IH - 1), 0, IH - 1).astype(int)
        col = img[py, px]
        nn = (w0[:, :, None] * N[i0] + w1[:, :, None] * N[i1] + w2[:, :, None] * N[i2])
        nn /= np.maximum(np.linalg.norm(nn, axis=2, keepdims=True), 1e-9)
        lam = np.clip(nn @ L1, 0, 1) * 0.85 + np.clip(nn @ L2, 0, 1) * 0.35 + 0.16
        rgb = col * lam[:, :, None]
        cb[m] = rgb[m]          # ecriture dans la vue -> modifie bien buf
        vb[m] = zz[m]
    out = (np.clip(buf, 0, 1) ** (1 / 2.2) * 255).astype(np.uint8)
    Image.fromarray(out).save(path)
    print("rendu :", path)

REST = {}
P1 = {  # marche : jambe avant flechie, bras opposes, buste en avant
    "hips":  [((1, 0, 0), 0.10)],
    "chest": [((1, 0, 0), 0.12), ((0, 0, 1), 0.04)],
    "neck":  [((1, 0, 0), 0.18)],
    "head":  [((1, 0, 0), -0.10)],
    "upperarmL": [((1, 0, 0), 0.75)], "forearmL": [((1, 0, 0), -0.65)],
    "upperarmR": [((1, 0, 0), -0.80)], "forearmR": [((1, 0, 0), -0.55)],
    "thighL": [((1, 0, 0), -0.75)], "shinL": [((1, 0, 0), 0.95)], "footL": [((1, 0, 0), 0.25)],
    "thighR": [((1, 0, 0), 0.55)], "shinR": [((1, 0, 0), -0.35)], "footR": [((1, 0, 0), -0.20)],
}
P2 = {  # poursuite : bras leves vers l'avant, dos voute, tete penchee
    "hips":  [((1, 0, 0), 0.14)],
    "spine": [((1, 0, 0), 0.16)],
    "chest": [((1, 0, 0), 0.22)],
    "neck":  [((1, 0, 0), 0.30), ((0, 1, 0), 0.10)],
    "head":  [((1, 0, 0), 0.12)],
    "clavL": [((0, 0, 1), -0.18)], "clavR": [((0, 0, 1), 0.18)],
    "upperarmL": [((1, 0, 0), -1.25), ((0, 0, 1), 0.35)], "forearmL": [((1, 0, 0), -1.35), ((0, 0, 1), 0.45)],
    "upperarmR": [((1, 0, 0), -1.15), ((0, 0, 1), -0.30)], "forearmR": [((1, 0, 0), -1.45), ((0, 0, 1), -0.40)],
    "thighL": [((1, 0, 0), -0.95)], "shinL": [((1, 0, 0), 1.25)], "footL": [((1, 0, 0), 0.35)],
    "thighR": [((1, 0, 0), 0.65)], "shinR": [((1, 0, 0), -0.45)], "footR": [((1, 0, 0), -0.25)],
}
V, N = pose(REST)
render(V, N, "/home/user/work/rig_repos.png", yaw=0.0)
V, N = pose(P1)
render(V, N, "/home/user/work/rig_marche.png", yaw=0.35)
V, N = pose(P2)
render(V, N, "/home/user/work/rig_chasse.png", yaw=0.55)
