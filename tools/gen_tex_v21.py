#!/usr/bin/env python3
# v22c : textures PBR v2 — plus de detail, moins de repetition (overwrite assets/pbr/*.png)
import numpy as np

S = 1024   # 2048 = OOM sandbox 2 Go ; 1024 suffit (nuit + VHS)
rng = np.random.default_rng(31)

def value_noise(n, cells, seed=0):
    r = np.random.default_rng(seed)
    g = r.random((cells + 1, cells + 1))
    x = np.linspace(0, cells, n, endpoint=False)
    xi = x.astype(int); xf = x - xi
    u = xf * xf * (3 - 2 * xf)
    a = g[np.ix_(xi, xi)]; b = g[np.ix_(xi, xi + 1)]
    c = g[np.ix_(xi + 1, xi)]; d = g[np.ix_(xi + 1, xi + 1)]
    return (a * (1 - u)[None, :] + b * u[None, :]) * (1 - u)[:, None] + \
           (c * (1 - u)[None, :] + d * u[None, :]) * u[:, None]

def fbm(n, c0, octs, seed):
    out = np.zeros((n, n)); amp = 1.0; tot = 0.0; c = c0
    for o in range(octs):
        out += amp * value_noise(n, c, seed + o); tot += amp
        amp *= 0.55; c *= 2
    return out / tot

def normal_from(h, strength=2.2):
    gy, gx = np.gradient(h)
    nx = -gx * strength; ny = -gy * strength
    nz = np.ones_like(nx)
    l = np.sqrt(nx * nx + ny * ny + 1)
    return np.stack([nx / l * 0.5 + 0.5, ny / l * 0.5 + 0.5, nz / l * 0.5 + 0.5], -1)

def save(name, alb, nrm, rgh, ao):
    import struct, zlib
    rgh = np.asarray(rgh, dtype=float)
    ao = np.asarray(ao, dtype=float)
    if rgh.ndim == 0:
        rgh = np.full((S, S), float(rgh))
    if ao.ndim == 0:
        ao = np.full((S, S), float(ao))
    def wr(fn, img):
        h, w, c = img.shape
        raw = b"".join(b"\x00" + img[y].astype(np.uint8).tobytes() for y in range(h))
        def chunk(t, d):
            cc = struct.pack(">I", len(d)) + t + d
            return cc + struct.pack(">I", zlib.crc32(t + d) & 0xffffffff)
        png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0)) + chunk(b"IDAT", zlib.compress(raw, 6)) + chunk(b"IEND", b"")
        open(fn, "wb").write(png)
    wr("assets/pbr/%s_albedo.png" % name, (alb * 255).clip(0, 255).astype(np.uint8))
    wr("assets/pbr/%s_normal.png" % name, (nrm * 255).clip(0, 255).astype(np.uint8))
    wr("assets/pbr/%s_rough.png" % name, np.repeat((rgh * 255).clip(0, 255).astype(np.uint8)[:, :, None], 3, -1))
    wr("assets/pbr/%s_ao.png" % name, np.repeat((ao * 255).clip(0, 255).astype(np.uint8)[:, :, None], 3, -1))
    print("saved", name)

Y, X = np.mgrid[0:S, 0:S]

# ================= SOL : planches usees =================
plank_w = S // 9
pid = (X // plank_w).astype(float)
pr = np.random.default_rng(7)
ptint = pr.random(12)
grain = fbm(S, 24, 5, 11)
streak = fbm(S, 96, 4, 12)          # fines stries du fil
knots = np.clip(1.6 - ((value_noise(S, 6, 21) - 0.5) ** 2 + (value_noise(S, 6, 22) - 0.5) ** 2) * 22, 0, 1)
gapx = (X % plank_w < 3).astype(float)
endj = ((Y + pid * 683) % 900 < 3).astype(float)   # joints bout-a-bout decales
base = 0.34 + 0.16 * ptint[(pid.astype(int) % 12)]
alb = np.zeros((S, S, 3))
v = base * (0.75 + 0.5 * grain) * (0.9 + 0.2 * streak)
alb[:, :, 0] = v * 0.62; alb[:, :, 1] = v * 0.40; alb[:, :, 2] = v * 0.22
scuff = fbm(S, 10, 4, 13)
dark = np.clip((scuff - 0.62) * 3, 0, 1) * 0.5
alb *= (1 - dark)[:, :, None]
h = grain * 0.5 + streak * 0.2 - gapx * 1.2 - endj * 1.0 - knots * 0.5
alb *= (1 - gapx * 0.8)[:, :, None] * (1 - endj * 0.7)[:, :, None]
nrm = normal_from(h, 3.0)
rgh = 0.62 + 0.25 * (1 - grain) + dark
ao = 1 - gapx * 0.6 - endj * 0.5 - dark * 0.3
save("floor", alb, nrm, np.clip(rgh, 0, 1), np.clip(ao, 0, 1))

# ================= MUR : papier peint damasse vieux =================
stripe = np.sin(X / S * 2 * np.pi * 14) * 0.5 + 0.5
motif = (np.sin(X / S * 2 * np.pi * 28) * np.sin(Y / S * 2 * np.pi * 28))
motif = np.clip(motif, 0, 1) ** 2
paper = fbm(S, 48, 4, 31)
stain = np.clip((fbm(S, 5, 4, 32) - 0.55) * 2.4, 0, 1)     # taches d'humidite
cream = np.array([0.42, 0.36, 0.27])
alb = cream[None, None, :] * (0.82 + 0.18 * paper)[:, :, None]
alb *= (1 + 0.10 * stripe + 0.14 * motif)[:, :, None]
alb *= (1 - 0.45 * stain)[:, :, None]
h = motif * 0.25 + paper * 0.2 - stain * 0.6
nrm = normal_from(h, 1.2)
rgh = 0.85 + 0.1 * stain
ao = 1 - stain * 0.35
save("wall", alb, nrm, rgh, ao)

# ================= PLAFOND : platre sale =================
pl = fbm(S, 32, 5, 41)
crack = np.clip((np.abs(value_noise(S, 24, 43) - 0.5) < 0.012).astype(float) * (fbm(S, 8, 3, 44) > 0.45), 0, 1)
stain2 = np.clip((fbm(S, 4, 4, 45) - 0.52) * 2.2, 0, 1)
g = 0.52 * (0.8 + 0.35 * pl)
alb = np.stack([g, g * 0.98, g * 0.94], -1) * (1 - 0.4 * stain2)[:, :, None]
alb *= (1 - crack * 0.5)[:, :, None]
nrm = normal_from(pl * 0.3 - crack * 1.5, 1.5)
rgh = 0.9
ao = 1 - stain2 * 0.4 - crack * 0.4
save("ceil", alb, nrm, rgh, ao)

# ================= PORTE : bois a panneaux =================
panel = ((X % (S // 2) < 40) | (Y % (S // 2) < 40)).astype(float)
graind = fbm(S, 40, 5, 51)
v = 0.30 + 0.14 * graind
alb = np.stack([v * 0.55, v * 0.36, v * 0.20], -1)
alb *= (1 - panel * 0.35)[:, :, None]
nrm = normal_from(graind * 0.3 - panel * 1.2, 2.0)
rgh = 0.5 + 0.3 * graind
ao = 1 - panel * 0.3
save("door", alb, nrm, rgh, ao)

# ================= CARRELAGE : sdb usee =================
tile_n = 8
tx = X % (S // tile_n); ty = Y % (S // tile_n)
grout = ((tx < 5) | (ty < 5)).astype(float)
tvar = np.random.default_rng(61).random((tile_n + 1, tile_n + 1))
tv = tvar[X // (S // tile_n), Y // (S // tile_n)]
g2 = 0.62 + 0.10 * tv
stain3 = np.clip((fbm(S, 6, 4, 62) - 0.5) * 2.0, 0, 1)
alb = np.stack([g2, g2 * 0.99, g2 * 0.96], -1) * (1 - 0.25 * stain3)[:, :, None]
alb *= (1 - grout * 0.6)[:, :, None]
nrm = normal_from(-grout * 1.5 + fbm(S, 60, 3, 63) * 0.1, 2.0)
rgh = 0.25 + grout * 0.6 + stain3 * 0.3
ao = 1 - grout * 0.5
save("tile", alb, nrm, np.clip(rgh, 0, 1), ao)
print("ALL TEXTURES V2 DONE")
