# =============================================================
#  LE 31 — kit itch.io : cover, icône, bannière (zéro asset externe)
# =============================================================
import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageEnhance

HERE = os.path.dirname(__file__)
TEX = os.path.join(HERE, "..", "assets", "tex")
OUT = os.path.join(HERE, "..", "..", "doc", "le31_kit")
os.makedirs(OUT, exist_ok=True)
BOLD = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"


def px(im, scale):
    return im.resize((im.width * scale, im.height * scale), Image.NEAREST)


def scanlines(im, step=3, alpha=36):
    d = ImageDraw.Draw(im, "RGBA")
    for y in range(0, im.height, step):
        d.rectangle([0, y, im.width, y], fill=(0, 0, 0, alpha))
    return im


def vignette(im):
    m = Image.new("L", im.size, 0)
    d = ImageDraw.Draw(m)
    d.ellipse([-im.width * 0.25, -im.height * 0.35, im.width * 1.25, im.height * 1.35], fill=255)
    m = m.filter(ImageFilter.GaussianBlur(60))
    black = Image.new("RGB", im.size, (4, 3, 6))
    return Image.composite(im, black, m)


def title_block(w, h, size):
    t = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(t)
    f = ImageFont.truetype(BOLD, size)
    d.text((4, 4), "LE 31", font=f, fill=(12, 6, 4, 255))
    d.text((0, 0), "LE 31", font=f, fill=(232, 116, 28, 255))
    f2 = ImageFont.truetype(BOLD, size // 4)
    d.text((2, h - size // 3), "OCT 31 1997 — CAM 2", font=f2, fill=(200, 200, 205, 255))
    return t


def compose(w, h, pum_scale, ent_scale, tsize):
    im = Image.new("RGB", (w, h), (16, 12, 20))
    d = ImageDraw.Draw(im)
    # fond : couloir suggéré (perspective brute)
    for i in range(14, 0, -1):
        k = i / 14.0
        x0 = int(w * 0.5 - w * 0.46 * k)
        x1 = int(w * 0.5 + w * 0.46 * k)
        y0 = int(h * 0.5 - h * 0.44 * k)
        y1 = int(h * 0.5 + h * 0.44 * k)
        c = int(10 + 26 * (1 - k))
        d.rectangle([x0, y0, x1, y1], outline=(c + 8, c, c + 6))
    # entité au fond
    if ent_scale > 0:
        ent = Image.open(os.path.join(TEX, "entity.png")).convert("RGBA")
        ent = px(ent, ent_scale)
        im.paste(ent, (int(w * 0.5 - ent.width / 2), int(h * 0.52 - ent.height * 0.9)), ent)
    # citrouille premier plan
    pum = Image.open(os.path.join(TEX, "pumpkin.png")).convert("RGBA")
    pum = px(pum, pum_scale)
    im.paste(pum, (int(w * 0.10), int(h * 0.92 - pum.height)), pum)
    # lueur citrouille
    gl = Image.new("RGBA", (pum.width * 2, pum.height * 2), (0, 0, 0, 0))
    gd = ImageDraw.Draw(gl)
    gd.ellipse([gl.width // 4, gl.height // 4, gl.width * 3 // 4, gl.height * 3 // 4], fill=(255, 140, 40, 60))
    gl = gl.filter(ImageFilter.GaussianBlur(18))
    im.paste(gl, (int(w * 0.10) - pum.width // 2, int(h * 0.92 - pum.height) - pum.height // 2), gl)
    im = vignette(im)
    im = ImageEnhance.Contrast(im).enhance(1.08)
    # titre
    if tsize > 0:
        tb = title_block(int(w * 0.62), int(tsize * 1.5), tsize)
        im.paste(tb, (int(w * 0.06), int(h * 0.07)), tb)
    im = scanlines(im)
    return im


compose(630, 500, 8, 6, 96).save(os.path.join(OUT, "cover_630x500.png"))
compose(1920, 650, 10, 7, 120).save(os.path.join(OUT, "banner_1920x650.png"))
ico = compose(128, 128, 4, 0, 0)
d = ImageDraw.Draw(ico)
f = ImageFont.truetype(BOLD, 44)
d.text((10, 34), "31", font=f, fill=(12, 6, 4))
d.text((8, 32), "31", font=f, fill=(232, 116, 28))
ico.save(os.path.join(OUT, "icon_128.png"))
print("KIT COVERS OK")
