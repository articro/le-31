# =============================================================
#  LE 31 — générateur de textures PSX (zéro asset externe)
# =============================================================
import os, math, random
from PIL import Image, ImageDraw, ImageFilter, ImageEnhance

OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "tex")
os.makedirs(OUT, exist_ok=True)
rng = random.Random(31)


def save(im, name, scale=1):
    im.save(os.path.join(OUT, name))
    print("->", name)


def grain(im, amt=10):
    px = im.load()
    w, h = im.size
    for y in range(h):
        for x in range(w):
            n = rng.randint(-amt, amt)
            p = px[x, y]
            px[x, y] = tuple(max(0, min(255, c + n)) for c in p[:3]) + ((p[3],) if len(p) > 3 else ())
    return im


# ---- papier peint damassé sombre ----
wall = Image.new("RGB", (64, 64), (46, 38, 44))
d = ImageDraw.Draw(wall)
for y in range(0, 64, 16):
    for x in range(0, 64, 16):
        cx, cy = x + 8, y + 8
        d.polygon([(cx, cy - 5), (cx + 4, cy), (cx, cy + 5), (cx - 4, cy)], fill=(58, 46, 56))
        d.point((cx, cy), fill=(70, 54, 66))
        d.point((x, y), fill=(38, 32, 38))
for i in range(140):
    d.point((rng.randrange(64), rng.randrange(64)), fill=(40, 34, 40))
save(grain(wall, 6), "wall.png")

# ---- plancher bois sombre ----
floor = Image.new("RGB", (64, 64), (38, 28, 22))
d = ImageDraw.Draw(floor)
for y in range(0, 64, 8):
    d.rectangle([0, y, 63, y], fill=(26, 19, 15))
    for x in range(64):
        v = 34 + int(6 * math.sin(x * 0.7 + y)) + rng.randint(-3, 3)
        d.point((x, y + 3), fill=(v + 6, v - 2, v - 8))
        d.point((x, y + 5), fill=(v + 2, v - 5, v - 10))
for i in range(6):
    x = rng.randrange(64)
    y = rng.randrange(8) * 8 + 4
    d.ellipse([x, y, x + 2, y + 1], fill=(22, 15, 11))
save(grain(floor, 5), "floor.png")

# ---- plafond plâtre sale ----
ceil = Image.new("RGB", (64, 64), (34, 32, 34))
d = ImageDraw.Draw(ceil)
for i in range(300):
    x, y = rng.randrange(64), rng.randrange(64)
    d.point((x, y), fill=(30 + rng.randint(-4, 8),) * 3)
for i in range(5):
    x, y = rng.randrange(50), rng.randrange(50)
    d.ellipse([x, y, x + rng.randrange(6, 14), y + rng.randrange(4, 10)], fill=(28, 26, 24))
save(grain(ceil, 5), "ceil.png")

# ---- affiche fête (normale) ----
def poster(bad=False):
    im = Image.new("RGB", (32, 48), (24, 20, 26))
    d = ImageDraw.Draw(im)
    d.rectangle([1, 1, 30, 46], fill=(58, 40, 52))
    d.rectangle([3, 3, 28, 30], fill=(20, 14, 22))
    # citrouille
    d.ellipse([9, 10, 23, 24], fill=(196, 96, 24))
    d.rectangle([15, 7, 17, 10], fill=(70, 90, 40))
    d.polygon([(12, 15), (15, 15), (13, 18)], fill=(20, 12, 10))
    d.polygon([(18, 15), (21, 15), (19, 18)], fill=(20, 12, 10))
    d.polygon([(13, 20), (19, 20), (16, 22)], fill=(20, 12, 10))
    if bad:
        # silhouette noire derrière la citrouille
        d.rectangle([22, 6, 26, 24], fill=(8, 6, 10))
        d.ellipse([22, 3, 27, 8], fill=(8, 6, 10))
        d.point((23, 5), fill=(230, 230, 220))
        d.point((25, 5), fill=(230, 230, 22))
    d.rectangle([5, 33, 26, 36], fill=(210, 170, 90))
    d.rectangle([7, 39, 24, 41], fill=(150, 120, 70))
    return grain(im, 5)

save(poster(False), "poster_a.png")
save(poster(True), "poster_b.png")

# ---- pancarte règles (FR / EN / mauvaises versions) ----
def rules(lang, bad):
    im = Image.new("RGB", (48, 40), (22, 18, 20))
    d = ImageDraw.Draw(im)
    d.rectangle([1, 1, 46, 38], fill=(196, 184, 158))
    d.rectangle([2, 2, 45, 37], outline=(120, 100, 70))
    lines = {
        ("fr", False): ["REGLES :", "1 UN BONBON", "2 SI QUELQUE", "CHOSE CHANGE :", "DEMI-TOUR"],
        ("en", False): ["RULES :", "1 ONE CANDY", "2 IF SOMETHING", "CHANGES :", "TURN BACK"],
        ("fr", True): ["REGLES :", "1 UN BONBON", "2 SI QUELQUE", "CHOSE CHANGE :", "REPONDS-LUI"],
        ("en", True): ["RULES :", "1 ONE CANDY", "2 IF SOMETHING", "CHANGES :", "ANSWER HIM"],
    }[(lang, bad)]
    y = 3
    for i, ln in enumerate(lines):
        col = (140, 20, 16) if (bad and i == 4) else (40, 30, 24)
        d.text((3, y), ln, fill=col)
        y += 7
    return grain(im, 4)

save(rules("fr", False), "rules_fr.png")
save(rules("en", False), "rules_en.png")
save(rules("fr", True), "rulesbad_fr.png")
save(rules("en", True), "rulesbad_en.png")

# ---- citrouille billboard (alpha) ----
pk = Image.new("RGBA", (24, 24), (0, 0, 0, 0))
d = ImageDraw.Draw(pk)
d.ellipse([3, 7, 21, 22], fill=(200, 100, 26, 255))
d.ellipse([6, 7, 18, 22], fill=(226, 122, 32, 255))
d.rectangle([11, 3, 13, 7], fill=(70, 96, 44, 255))
d.polygon([(7, 12), (10, 12), (8, 15)], fill=(24, 12, 8, 255))
d.polygon([(14, 12), (17, 12), (15, 15)], fill=(24, 12, 8, 255))
d.polygon([(8, 17), (16, 17), (12, 20)], fill=(24, 12, 8, 255))
for x in range(8, 16):
    d.point((x, 17), fill=(255, 190, 60, 255))
save(grain(pk, 4), "pumpkin.png")

# ---- silhouette entité (alpha) ----
en_ = Image.new("RGBA", (24, 48), (0, 0, 0, 0))
d = ImageDraw.Draw(en_)
d.ellipse([8, 2, 16, 10], fill=(6, 5, 8, 255))
d.polygon([(6, 10), (18, 10), (20, 46), (4, 46)], fill=(6, 5, 8, 255))
d.rectangle([3, 12, 6, 30], fill=(6, 5, 8, 255))
d.rectangle([18, 12, 21, 30], fill=(6, 5, 8, 255))
d.point((10, 5), fill=(235, 235, 225, 255))
d.point((14, 5), fill=(235, 235, 225, 255))
save(en_, "entity.png")

# ---- portes ----
door = Image.new("RGB", (32, 48), (30, 22, 18))
d = ImageDraw.Draw(door)
d.rectangle([1, 1, 30, 47], fill=(52, 38, 28))
d.rectangle([4, 4, 27, 20], outline=(36, 26, 19))
d.rectangle([4, 24, 27, 44], outline=(36, 26, 19))
d.ellipse([24, 24, 27, 27], fill=(150, 120, 60))
save(grain(door, 4), "door.png")

dooro = Image.new("RGB", (32, 48), (30, 22, 18))
d = ImageDraw.Draw(dooro)
d.rectangle([1, 1, 30, 47], fill=(52, 38, 28))
d.rectangle([5, 3, 26, 46], fill=(4, 3, 5))
d.point((13, 14), fill=(220, 220, 210))
d.point((18, 14), fill=(220, 220, 210))
save(grain(dooro, 3), "door_open.png")

# ---- visage jumpscare ----
sc = Image.new("RGB", (128, 128), (10, 8, 10))
d = ImageDraw.Draw(sc)
d.ellipse([24, 14, 104, 118], fill=(198, 186, 172))
d.ellipse([40, 44, 58, 70], fill=(6, 4, 6))
d.ellipse([70, 44, 88, 70], fill=(6, 4, 6))
d.ellipse([52, 82, 76, 112], fill=(10, 4, 6))
for i in range(40):
    x = rng.randrange(30, 98)
    y = rng.randrange(20, 112)
    d.point((x, y), fill=(150, 130, 120))
sc = sc.filter(ImageFilter.GaussianBlur(0.6))
save(grain(sc, 8), "scare.png")

# ---- tache sombre au sol (alpha) ----
st = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
d = ImageDraw.Draw(st)
for i in range(7):
    x, y = rng.randrange(6, 24), rng.randrange(6, 24)
    r = rng.randrange(3, 8)
    d.ellipse([x - r, y - r, x + r, y + r], fill=(26, 8, 8, rng.randrange(120, 200)))
d.ellipse([12, 12, 22, 20], fill=(18, 4, 6, 220))
st = st.filter(ImageFilter.GaussianBlur(1.2))
save(st, "stain.png")

# ---- affiche variante chat noir ----
pc = Image.new("RGB", (32, 48), (24, 20, 26))
d = ImageDraw.Draw(pc)
d.rectangle([1, 1, 30, 46], fill=(40, 44, 58))
d.rectangle([3, 3, 28, 30], fill=(16, 14, 20))
d.ellipse([11, 12, 21, 22], fill=(8, 8, 10))
d.polygon([(11, 12), (14, 8), (15, 12)], fill=(8, 8, 10))
d.polygon([(18, 12), (21, 8), (21, 12)], fill=(8, 8, 10))
d.point((14, 15), fill=(240, 220, 80))
d.point((18, 15), fill=(240, 220, 80))
d.polygon([(20, 20), (26, 26), (24, 28), (19, 22)], fill=(8, 8, 10))
d.rectangle([5, 33, 26, 36], fill=(180, 180, 200))
d.rectangle([7, 39, 24, 41], fill=(120, 120, 140))
save(grain(pc, 5), "poster_c.png")

# ---- carrelage salle de bains / cuisine ----
ti = Image.new("RGB", (256, 256), (150, 148, 140))
d = ImageDraw.Draw(ti)
for r in range(4):
    for c in range(4):
        shade = 138 + ((r * 4 + c) * 7) % 24
        d.rectangle([c * 64 + 3, r * 64 + 3, c * 64 + 61, r * 64 + 61], fill=(shade, shade - 2, shade - 8))
        d.rectangle([c * 64 + 6, r * 64 + 6, c * 64 + 30, r * 64 + 30], fill=(shade + 10, shade + 8, shade + 2))
for i in range(140):
    x = (i * 53) % 256
    y = (i * 97) % 256
    d.point((x, y), fill=(110, 108, 100))
save(grain(ti, 4), "tile.png")

# ---- visage jumpscare ----
fa = Image.new("RGB", (512, 512), (6, 5, 6))
d = ImageDraw.Draw(fa)
d.ellipse([136, 60, 376, 470], fill=(196, 186, 168))
d.ellipse([150, 80, 362, 452], fill=(210, 200, 182))
d.ellipse([168, 168, 244, 258], fill=(2, 2, 3))
d.ellipse([268, 168, 344, 258], fill=(2, 2, 3))
d.ellipse([180, 184, 232, 246], fill=(0, 0, 0))
d.ellipse([280, 184, 332, 246], fill=(0, 0, 0))
d.point((206, 212), fill=(180, 170, 150))
d.point((306, 212), fill=(180, 170, 150))
d.ellipse([216, 320, 296, 452], fill=(4, 3, 3))
d.ellipse([226, 330, 286, 430], fill=(0, 0, 0))
for k in range(6):
    d.polygon([(228 + k * 10, 322), (233 + k * 10, 342), (238 + k * 10, 322)], fill=(160, 150, 130))
for k in range(9):
    x0 = 160 + k * 22
    d.line([(x0, 90 + (k % 3) * 14), (x0 + 8, 150 + (k % 2) * 30)], fill=(150, 140, 122), width=2)
d.line([(150, 300), (120, 340)], fill=(140, 130, 112), width=3)
d.line([(362, 300), (392, 340)], fill=(140, 130, 112), width=3)
fa = fa.filter(ImageFilter.GaussianBlur(1.2))
save(grain(fa, 7), "face.png")

# ---- chevron guide (alpha) ----
ar = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
d = ImageDraw.Draw(ar)
d.polygon([(16, 3), (28, 16), (21, 16), (21, 29), (11, 29), (11, 16), (4, 16)], fill=(255, 150, 40, 255))
d.polygon([(16, 7), (23, 15), (19, 15), (19, 26), (13, 26), (13, 15), (9, 15)], fill=(255, 210, 120, 255))
save(ar, "arrow.png")

# ---- lueur sortie ----
ex = Image.new("RGB", (32, 48), (8, 8, 6))
d = ImageDraw.Draw(ex)
d.rectangle([3, 3, 28, 46], fill=(240, 200, 120))
d.rectangle([8, 8, 23, 42], fill=(255, 240, 190))
save(ex, "exit.png")

print("TEXTURES H OK")
