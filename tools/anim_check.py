# -*- coding: utf-8 -*-
"""LE 31 — controle de l'animation : mesure objectivement le patinage des pieds,
   la penetration dans le sol et le decollement, puis rend une planche d'images."""
import json, struct, math, sys
import numpy as np
from PIL import Image
sys.path.insert(0, "/home/user/tools")
import anim_ref as A

GLB = "/home/user/hantise/assets/models/monstre_rig.glb"
d = open(GLB, "rb").read(); off, ch = 12, []
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
nodes = {n.get("name"): n for n in J["nodes"] if "name" in n}
parent = {}
for n in J["nodes"]:
    for c in n.get("children", []):
        parent[J["nodes"][c].get("name")] = n.get("name", "")
rest_t = {nm: np.array(nodes[nm].get("translation", [0, 0, 0]), dtype=np.float64) for nm in NAMES}

# pieds : les points les plus bas du maillage en repos, separes par cote
low = np.where(P[:, 1] < 0.02)[0]
footL = low[P[low, 0] < 0]
footR = low[P[low, 0] >= 0]
print("points de semelle : gauche %d, droit %d" % (len(footL), len(footR)))

def rotm(axis, a):
    c, s = math.cos(a), math.sin(a)
    x, y, z = axis
    nx = math.sqrt(x * x + y * y + z * z) + 1e-12
    x, y, z = x / nx, y / nx, z / nx
    return np.array([[c + x*x*(1-c), x*y*(1-c) - z*s, x*z*(1-c) + y*s],
                     [y*x*(1-c) + z*s, c + y*y*(1-c), y*z*(1-c) - x*s],
                     [z*x*(1-c) - y*s, z*y*(1-c) + x*s, c + z*z*(1-c)]])

def build(POSE, hips_off):
    """POSE : {os: [(axe, angle), ...]} ; rend positions globales des os + matrice de peau"""
    Rl = {}
    for nm in NAMES:
        M = np.eye(3)
        for ax, an in POSE.get(nm, []):
            M = M @ rotm(ax, an)
        Rl[nm] = M
    Tg, Rg = {}, {}
    for nm in NAMES:
        p = parent.get(nm, "")
        Rg[nm] = (Rg[p] @ Rl[nm]) if p in Rg else Rl[nm]
        t = rest_t[nm].copy()
        if nm == "hips":
            t = t + np.array([0, hips_off, 0])
        Tg[nm] = ((Tg[p] + Rg[p] @ t) if p in Tg else t)
    return Tg, Rg

def skin(Tg, Rg):
    out = np.zeros_like(P)
    for k in range(4):
        jn, w = JN[:, k], WG[:, k]
        for j in np.unique(jn[w > 1e-5]):
            m = (jn == j) & (w > 1e-5)
            T, R = Tg[NAMES[j]], Rg[NAMES[j]]
            out[m] += w[m, None] * (T + (R @ (P[m] - T).T).T)   # R applique en COLONNE (v @ R = transpose)
    return out

def simulate(mode, speed, seconds, scale=2.8, fps=30, look=0.0):
    c = A.Canaux()
    dt = 1.0 / fps
    z = 0.0
    frames = []
    t = 0.0
    for i in range(int(seconds * fps)):
        POSE, hips = A.anim_step(c, dt, t, mode, speed, look, 0.0, scale)
        A.GAIT_SNAPSHOT = c.v["gait"] if hasattr(A, "GAIT_SNAPSHOT") else c.v["gait"]
        Tg, Rg = build(POSE, hips)
        V = skin(Tg, Rg) * scale + np.array([0.0, 0.0, z])
        frames.append((t, V.copy()))
        z -= speed * dt
        t += dt
    return frames

def mesure(frames, nom, mode=2):
    """verifie que le pied en appui ne patine pas : on ne compare que les phases d'appui"""
    c = A.Canaux()
    dt = 1.0 / 30.0
    deriv = []
    pen = []; flot = []
    prev = None
    for t, V in frames:
        lz = V[footL]; rz = V[footR]
        yl = lz[:, 1]; yr = rz[:, 1]
        pen.append(min(yl.min(), yr.min()))                 # < 0 = dans le sol
        if min(yl.min(), yr.min()) < -0.03:
            print("   t=%.2f PENETRATION %.3f  (G %.3f / D %.3f)" % (
                t, min(yl.min(), yr.min()), yl.min(), yr.min()))
        if prev is not None:
            g = prev[2]
            for sid, (pts_now, pts_old) in enumerate(((lz, prev[0]), (rz, prev[1]))):
                ph = (g + (0.0 if sid == 0 else 0.5)) % 1.0
                if ph >= 0.60:      # pied en balancier : il doit bouger
                    continue
                np_now = pts_now[pts_now[:, 1] < 0.02]
                np_old = pts_old[pts_old[:, 1] < 0.02]
                if len(np_now) == 0 or len(np_old) == 0:
                    continue
                dd = np.sqrt(((np_now[:, None, :2] - np_old[None, :, :2]) ** 2).sum(-1))
                deriv.append(float(dd.min(axis=1).max()))
        prev = (lz, rz, A.GAIT_SNAPSHOT)
        # contact : le pied pose doit toucher le sol (min y proche de 0)
        flot.append(min(yl.min(), yr.min()))
    if deriv:
        print("[%s] penetration max %.4f m | pied le plus haut au contact %.4f m | patinage en appui : moyen %.4f m/image, max %.4f"
              % (nom, min(pen), max(flot), float(np.mean(deriv)), float(np.max(deriv))))
    else:
        print("[%s] penetration max %.4f m | pied le plus haut au contact %.4f m" % (nom, min(pen), max(flot)))
    return float(np.mean(deriv)) if deriv else 0.0

def render_frame(V, path, W=300, H=430, yaw=0.6, pitch=-0.06, bg=(0.045, 0.042, 0.05), cru=0.0, zoom=1.0, cy=0.0):
    Ry = rotm((0, 1.0, 0), yaw); Rx = rotm((1.0, 0, 0), pitch); Rc = Rx @ Ry
    Vc = V @ Rc.T
    Vc[:, 0] -= Vc[:, 0].mean(); Vc[:, 2] -= Vc[:, 2].mean()
    f = 1.0
    zz = Vc[:, 2] + 2.4
    c1 = Vc[:, 1].mean() + cy
    sx = (Vc[:, 0] * f / zz) * (H / 2) * 0.62 * zoom + W * 0.5
    sy = (-(Vc[:, 1] - c1) * f / zz) * (H / 2) * 0.62 * zoom + H * 0.52
    buf = np.full((H, W, 3), bg); zb = np.full((H, W), 1e9)
    L1 = np.array([0.4, 0.8, 0.5]); L1 /= np.linalg.norm(L1)
    L2 = np.array([-0.5, 0.2, 0.4]); L2 /= np.linalg.norm(L2)
    import os
    TEXP = "/home/user/hantise/assets/models/monstre_skin.png"
    if not os.path.exists(TEXP):
        TEXP = "/home/user/hantise/assets/models/monstre2_tex.png"
    img = np.array(Image.open(TEXP).convert("RGB"), dtype=np.float64) / 255.0
    IH, IW = img.shape[:2]
    for i0, i1, i2 in IDX:
        x0, y0 = sx[i0], sy[i0]; x1, y1 = sx[i1], sy[i1]; x2, y2 = sx[i2], sy[i2]
        minx = max(int(min(x0, x1, x2)), 0); maxx = min(int(max(x0, x1, x2)) + 1, W - 1)
        miny = max(int(min(y0, y1, y2)), 0); maxy = min(int(max(y0, y1, y2)) + 1, H - 1)
        if maxx <= minx or maxy <= miny: continue
        area = (x1 - x0) * (y2 - y0) - (x2 - x0) * (y1 - y0)
        if abs(area) < 1e-9: continue
        xs = np.arange(minx, maxx + 1) + .5; ys = np.arange(miny, maxy + 1) + .5
        X, Y = np.meshgrid(xs, ys)
        w0 = ((x1 - X) * (y2 - Y) - (x2 - X) * (y1 - Y)) / area
        w1 = ((x2 - X) * (y0 - Y) - (x0 - X) * (y2 - Y)) / area
        w2 = 1 - w0 - w1
        ins = (w0 >= 0) & (w1 >= 0) & (w2 >= 0)
        if not ins.any(): continue
        zc = w0 * (-zz[i0]) + w1 * (-zz[i1]) + w2 * (-zz[i2])
        vb = zb[miny:maxy + 1, minx:maxx + 1]; cb = buf[miny:maxy + 1, minx:maxx + 1]
        m = ins & (zc < vb)
        if not m.any(): continue
        u = w0 * UV[i0, 0] + w1 * UV[i1, 0] + w2 * UV[i2, 0]
        v = w0 * UV[i0, 1] + w1 * UV[i1, 1] + w2 * UV[i2, 1]
        px = np.clip(np.mod(u, 1) * (IW - 1), 0, IW - 1).astype(int)
        py = np.clip(np.mod(v, 1) * (IH - 1), 0, IH - 1).astype(int)
        col = img[py, px]
        nn = w0[:, :, None] * NR[i0] + w1[:, :, None] * NR[i1] + w2[:, :, None] * NR[i2]
        nn /= np.maximum(np.linalg.norm(nn, axis=2, keepdims=True), 1e-9)
        lam = np.clip(nn @ L1, 0, 1) * 0.8 + np.clip(nn @ L2, 0, 1) * 0.35 + 0.14
        cb[m] = (col * lam[:, :, None])[m]
        vb[m] = zc[m]
    out = (np.clip(buf, 0, 1) ** (1 / 2.2) * 255).astype(np.uint8)
    Image.fromarray(out).save(path)

if __name__ == "__main__":
    mode = int(sys.argv[1]) if len(sys.argv) > 1 else 2
    speed = float(sys.argv[2]) if len(sys.argv) > 2 else 3.6
    nom = {0: "rode", 1: "alerte", 2: "chasse", 3: "recul", 4: "bond"}[mode]
    frames = simulate(mode, speed, 2.6, look=0.0)
    mesure(frames, "%s %.1f m/s" % (nom, speed))
    idx = np.linspace(0, len(frames) - 1, 8).astype(int)
    tiles = []
    for k, i in enumerate(idx):
        p = "/home/user/work/anim_%s_%d.png" % (nom, k)
        render_frame(frames[i][1], p, yaw=0.55 if mode != 0 else 0.2)
        tiles.append(np.array(Image.open(p)))
    strip = np.concatenate(tiles, axis=1)
    Image.fromarray(strip).save("/home/user/work/anim_%s_film.png" % nom)
    print("planche :", "/home/user/work/anim_%s_film.png" % nom)
