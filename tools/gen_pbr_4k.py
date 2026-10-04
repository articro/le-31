# Génération 4K par bandes (sol + mur) : octaves précalculées en uint8 pleine
# résolution, puis accumulation par bandes de 1024 lignes -> sans couture, sans OOM.
# Usage: python3 gen_pbr_4k.py floor   |   python3 gen_pbr_4k.py wall
import os
import sys
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "pbr")
M = 4096
BAND = 1024


def octaves_full(base, octs, shape, seed):
    """Octaves fbm upscalées en uint8 pleine résolution (M ou (M,256))."""
    r = np.random.default_rng(seed)
    res = []
    for i in range(octs):
        g = base * 2 ** i
        small = (r.random((g, g)) * 255).astype(np.uint8)
        im = Image.fromarray(small, "L").resize((shape[1], shape[0]), Image.BICUBIC)
        res.append(np.asarray(im, np.uint8))
    return res


def fbm_band(octs, base, r0, r1, amp0=1.0):
    """Bande [r0,r1) de la somme fbm normalisée (-1..1)."""
    h = r1 - r0
    w = octs[0].shape[1]
    out = np.zeros((h, w), np.float32)
    amp, tot = amp0, 0.0
    a = amp0
    for o in octs:
        out += o[r0:r1].astype(np.float32) / 255.0 * a
        tot += a
        a *= 0.5
    return out / tot * 2.0 - 1.0


def save_png(arr, name):
    Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), "RGB").save(os.path.join(OUT, name))
    print("->", name, arr.shape)


def assemble(bands, name):
    canvas = Image.new("RGB", (M, M))
    for i, b in enumerate(bands):
        canvas.paste(Image.fromarray(b, "RGB"), (0, i * BAND))
    canvas.save(os.path.join(OUT, name))
    print("->", name, "4K assemble")


# ---------------------------------------------------------------- SOL bois 4K
def floor():
    yy_full = np.arange(M, dtype=np.float32) / M
    oA = octaves_full(16, 6, (M, M), 11)
    oB = octaves_full(8, 5, (M, 256), 12)
    oC = octaves_full(256, 4, (M, M), 77)
    tone = np.random.default_rng(5).random(9).astype(np.float32) * 0.25
    alb_b, nrm_b = [], []
    for bi in range(M // BAND):
        r0, r1 = bi * BAND, (bi + 1) * BAND
        r0e, r1e = max(0, r0 - 1), min(M, r1 + 1)
        yy = yy_full[r0e:r1e]
        gA = fbm_band(oA, 16, r0e, r1e)
        gB = fbm_band(oB, 8, r0e, r1e).repeat(M // 256, axis=1)
        gC = fbm_band(oC, 256, r0e, r1e)
        grain = (gA * 0.6 + gB * 0.4) + gC * 0.22
        row = np.floor(yy * 8)
        seam = (np.abs((yy * 8) % 1.0 - 0.5) > 0.485).astype(np.float32)
        xx = np.arange(M, dtype=np.float32) / M
        bx, by = np.meshgrid(xx, yy)
        butt = ((np.abs((bx + row[:, None] * 0.37) % 0.5) < 0.004) & (np.abs((yy[:, None] * 8) % 1.0 - 0.5) < 0.48)).astype(np.float32)
        base = 0.30 + tone[np.minimum(row.astype(int), 8)] * 0.5
        alb = np.zeros((r1e - r0e, M, 3), np.float32)
        base2 = base[:, None]
        alb[..., 0] = (base2 + grain * 0.22) * 150
        alb[..., 1] = (base2 + grain * 0.20) * 105
        alb[..., 2] = (base2 + grain * 0.16) * 70
        alb *= (1.0 - seam[:, None, None] * 0.6) * (1.0 - butt[..., None] * 0.4)
        alb_b.append(np.clip(alb[1:-1] if r0e < r0 else alb[: BAND], 0, 255).astype(np.uint8))
        h = grain * 0.25 - seam[:, None] * 1.0 - butt * 0.6
        gy, gx = np.gradient(h * 2.6)
        nx, ny, nz = -gx, gy, np.ones_like(gx)
        l = np.sqrt(nx * nx + ny * ny + nz * nz)
        nx, ny, nz = nx / l, ny / l, nz / l
        nrm = np.zeros((r1e - r0e, M, 3), np.float32)
        nrm[..., 0] = (nx * 0.5 + 0.5) * 255
        nrm[..., 1] = (ny * 0.5 + 0.5) * 255
        nrm[..., 2] = (nz * 0.5 + 0.5) * 255
        nrm_b.append(np.clip(nrm[1:-1] if r0e < r0 else nrm[: BAND], 0, 255).astype(np.uint8))
    assemble(alb_b, "floor_albedo.png")
    assemble(nrm_b, "floor_normal.png")


# ------------------------------------------------------------- MUR damassé 4K
def wall():
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
    oS = octaves_full(32, 6, (M, M), 21)
    oM = octaves_full(192, 3, (M, M), 88)
    oT = octaves_full(4, 4, (M, M), 22)
    alb_b, nrm_b = [], []
    for bi in range(M // BAND):
        r0, r1 = bi * BAND, (bi + 1) * BAND
        r0e, r1e = max(0, r0 - 1), min(M, r1 + 1)
        pat = np.tile(tile, ((r1e - r0e) // 256 + 1, M // 256))[: r1e - r0e]
        stip = fbm_band(oS, 32, r0e, r1e) + fbm_band(oM, 192, r0e, r1e) * 0.35
        stain = np.clip(fbm_band(oT, 4, r0e, r1e) * 2.2, -1, 1)
        alb = np.zeros((r1e - r0e, M, 3), np.float32)
        alb[..., 0] = 62 + pat * 26 + stip * 10
        alb[..., 1] = 46 + pat * 18 + stip * 8
        alb[..., 2] = 56 + pat * 24 + stip * 10
        alb *= (1.0 - np.clip(stain, 0, 1)[..., None] * 0.35)
        keep = slice(1, -1) if r0e < r0 else slice(0, BAND)
        alb_b.append(np.clip(alb[keep], 0, 255).astype(np.uint8))
        h = pat * 0.5 + stip * 0.12
        gy, gx = np.gradient(h * 1.4)
        nx, ny, nz = -gx, gy, np.ones_like(gx)
        l = np.sqrt(nx * nx + ny * ny + nz * nz)
        nx, ny, nz = nx / l, ny / l, nz / l
        nrm = np.zeros((r1e - r0e, M, 3), np.float32)
        nrm[..., 0] = (nx * 0.5 + 0.5) * 255
        nrm[..., 1] = (ny * 0.5 + 0.5) * 255
        nrm[..., 2] = (nz * 0.5 + 0.5) * 255
        nrm_b.append(np.clip(nrm[keep], 0, 255).astype(np.uint8))
    assemble(alb_b, "wall_albedo.png")
    assemble(nrm_b, "wall_normal.png")


if __name__ == "__main__":
    which = sys.argv[1] if len(sys.argv) > 1 else "floor"
    if which == "floor":
        floor()
    else:
        wall()
    print("4K", which, "OK")
