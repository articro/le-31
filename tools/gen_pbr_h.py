# =============================================================
#  LE 31 — textures PBR 2K procédurales (albedo/normal/rough/ao)
#  Zéro asset externe : tout est calculé ici.
# =============================================================
import os
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "pbr")
os.makedirs(OUT, exist_ok=True)
N = 3072
rng = np.random.default_rng(31)


def save(arr, name):
    if arr.ndim == 2:
        arr = np.stack([arr] * 3, -1)
    elif arr.ndim == 3 and arr.shape[2] == 1:
        arr = np.repeat(arr, 3, axis=2)
    im = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8))
    im.save(os.path.join(OUT, name))
    print("->", name)


def fbm(shape, octaves=5, base=8, seed=None):
    r = np.random.default_rng(seed if seed is not None else 7)
    out = np.zeros(shape, np.float32)
    amp = 1.0
    tot = 0.0
    for o in range(octaves):
        s = base * (2 ** o)
        g = r.random((s, s), dtype=np.float32)
        im = Image.fromarray((g * 255).astype(np.uint8)).resize((shape[1], shape[0]), Image.BICUBIC)
        out += amp * (np.asarray(im, np.float32) / 255.0 - 0.5)
        tot += amp
        amp *= 0.55
    return out / tot


def normal_from_height(h, strength=2.2):
    gy, gx = np.gradient(h.astype(np.float32))
    nx = -gx * strength * N / 512.0
    ny = -gy * strength * N / 512.0
    nz = np.ones_like(nx)
    l = np.sqrt(nx * nx + ny * ny + nz * nz)
    nx, ny, nz = nx / l, ny / l, nz / l
    return np.stack([(nx * 0.5 + 0.5) * 255, (ny * 0.5 + 0.5) * 255, (nz * 0.5 + 0.5) * 255], -1)


# ============================================================ SOL : bois ====
yy, xx = np.mgrid[0:N, 0:N].astype(np.float32) / N
PL = 8                                   # 8 planches
row = np.floor(yy * PL)
tone = np.random.default_rng(5).random(PL + 1).astype(np.float32) * 0.25
grain = fbm((N, N), 6, 16, 11)
grain = grain * 0.6 + fbm((N, 256), 5, 8, 12).repeat(N // 256, axis=1) * 0.4
seam = (np.abs((yy * PL) % 1.0 - 0.5) > 0.485).astype(np.float32)
butt = ((np.abs((xx + row * 0.37) % 0.5) < 0.004) & (np.abs((yy * PL) % 1.0 - 0.5) < 0.48)).astype(np.float32)
h = grain * 0.25 - seam * 1.0 - butt * 0.6
base = 0.30 + tone[np.minimum(row.astype(int), PL)] * 0.5
alb = np.zeros((N, N, 3), np.float32)
alb[..., 0] = (base + grain * 0.22) * 150
alb[..., 1] = (base + grain * 0.20) * 105
alb[..., 2] = (base + grain * 0.16) * 70
alb *= (1.0 - seam[..., None] * 0.6) * (1.0 - butt[..., None] * 0.4)
rough = 0.62 + grain * 0.18 - fbm((N, N), 3, 4, 13) * 0.22
ao = 1.0 - seam * 0.55 - butt * 0.3
save(alb, "floor_albedo.png")
save(normal_from_height(h, 2.6), "floor_normal.png")
save(np.clip(rough, 0.15, 1)[..., None] * 255, "floor_rough.png")
save(np.clip(ao, 0, 1)[..., None] * 255, "floor_ao.png")

# ======================================================= MUR : damassé =====
mot = Image.new("L", (256, 256), 0)
d = ImageDraw.Draw(mot)
d.polygon([(128, 30), (190, 128), (128, 226), (66, 128)], fill=90)
d.ellipse([104, 104, 152, 152], fill=140)
d.polygon([(128, 60), (160, 128), (128, 196), (96, 128)], fill=40)
for cx, cy in [(0, 0), (256, 0), (0, 256), (256, 256)]:
    d.ellipse([cx - 26, cy - 26, cx + 26, cy + 26], fill=70)
d.ellipse([120, 8, 136, 24], fill=110)
d.ellipse([120, 232, 136, 248], fill=110)
mot = mot.filter(ImageFilter.GaussianBlur(1.5))
tile = np.asarray(mot, np.float32) / 255.0
pat = np.tile(tile, (N // 256, N // 256))
pat = np.roll(pat, (0, 0), axis=(0, 1))
stip = fbm((N, N), 6, 32, 21)
h = pat * 0.5 + stip * 0.12
alb = np.zeros((N, N, 3), np.float32)
alb[..., 0] = 62 + pat * 26 + stip * 10
alb[..., 1] = 46 + pat * 18 + stip * 8
alb[..., 2] = 56 + pat * 24 + stip * 10
stain = np.clip(fbm((N, N), 4, 4, 22) * 2.2, -1, 1)
alb *= (1.0 - np.clip(stain, 0, 1)[..., None] * 0.35)
rough = np.full((N, N), 0.82, np.float32) + stip * 0.08
ao = 1.0 - np.clip(stain, 0, 1) * 0.25
save(alb, "wall_albedo.png")
save(normal_from_height(h, 1.4), "wall_normal.png")
save(np.clip(rough, 0, 1)[..., None] * 255, "wall_rough.png")
save(np.clip(ao, 0, 1)[..., None] * 255, "wall_ao.png")

# =================================================== PLAFOND : plâtre =======
stip = fbm((N, N), 6, 24, 31)
stain = np.clip(fbm((N, N), 4, 3, 32) * 2.4, -1, 1)
crack = np.clip(np.abs(fbm((N, N), 5, 6, 33)) * 9 - 0.35, 0, 1)
crack = 1 - np.clip(crack * 6, 0, 1) * 0.5
h = stip * 0.15 - np.clip(stain, 0, 1) * 0.2 - (1 - crack) * 0.4
g = 0.5 + stip * 0.12
alb = np.stack([g * 74, g * 70, g * 68], -1)
alb *= (1.0 - np.clip(stain, 0, 1)[..., None] * 0.45)
rough = np.full((N, N), 0.9, np.float32)
ao = 1.0 - np.clip(stain, 0, 1) * 0.4 - (1 - crack) * 0.2
save(alb, "ceil_albedo.png")
save(normal_from_height(h, 1.1), "ceil_normal.png")
save(rough[..., None] * 255, "ceil_rough.png")
save(np.clip(ao, 0, 1)[..., None] * 255, "ceil_ao.png")

# ==================================================== PORTE : panneaux ======
panel = np.zeros((N, N), np.float32)
iy, ix = yy, xx
inset = (((iy > 0.08) & (iy < 0.44) & (ix > 0.14) & (ix < 0.86)) | \
        ((iy > 0.54) & (iy < 0.92) & (ix > 0.14) & (ix < 0.86))).astype(np.float32)
edge = np.zeros((N, N), np.float32)
for a in (0.08, 0.44, 0.54, 0.92):
    edge = np.maximum(edge, np.clip(1 - np.abs(iy - a) * 60, 0, 1))
for a in (0.14, 0.86):
    edge = np.maximum(edge, np.clip(1 - np.abs(ix - a) * 60, 0, 1) * inset.astype(np.float32) * 0 + np.clip(1 - np.abs(ix - a) * 60, 0, 1))
wgrain = fbm((256, N), 5, 8, 41).repeat(N // 256, axis=0)
h = -inset * 0.35 + edge * 0.25 + wgrain * 0.15
alb = np.zeros((N, N, 3), np.float32)
w = 0.42 + wgrain * 0.2
alb[..., 0] = w * 105
alb[..., 1] = w * 68
alb[..., 2] = w * 44
alb *= (1 - inset[..., None] * 0.12)
rough = np.full((N, N), 0.48, np.float32) + wgrain * 0.15
ao = 1.0 - inset * 0.15
save(alb, "door_albedo.png")
save(normal_from_height(h, 2.0), "door_normal.png")
save(np.clip(rough, 0, 1)[..., None] * 255, "door_rough.png")
save(np.clip(ao, 0, 1)[..., None] * 255, "door_ao.png")

print("PBR 2K OK")
print("PBR OK (3K)")
