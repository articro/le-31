# -*- coding: utf-8 -*-
# LE 31 — patch du generateur de personnage : MACHOIRE + DENTS
#   Le maillage TRELLIS n'a pas de machoire mobile : la bouche ne peut pas s'ouvrir.
#   On ajoute donc (1) un os `jaw` sous la tete, (2) des dents (geometrie ajoutee),
#   (3) un transfert de poids : le bas du visage suit la machoire.
import io
P = "/home/user/tools/rig_monstre.py"
s = io.open(P, encoding="utf-8").read()

def rep(a, b, n=1):
    global s
    c = s.count(a)
    assert c == n, "ancre %d fois (attendu %d) : %r" % (c, n, a[:90])
    s = s.replace(a, b, n if n > 1 else 1)

# ---------------------------------------------------------------- 1) points de la machoire
rep('''    "toetipL":  (0.190, -0.492,  0.085),
}''',
'''    "toetipL":  (0.190, -0.492,  0.085),
    # machoire : le pivot est a la ligne de bouche (y = 0.355 en espace source),
    # la queue descend vers le menton et l'avant (visage vers +Z dans cet espace)
    "jaw":      (0.000,  0.356,  0.008),
    "jawtip":   (0.000,  0.312,  0.048),
}''')

rep('''    ("toeR",      "footR",  J2["toeR"],     J2["toetipR"]),
]''',
'''    ("toeR",      "footR",  J2["toeR"],     J2["toetipR"]),
    ("jaw",       "head",   J2["jaw"],      J2["jawtip"]),
]''')

# ---------------------------------------------------------------- 2) transfert de poids vers la machoire
rep('''# ne garder que 4 influences par sommet (limite standard)''',
'''# ---- v20b : le bas du visage (levre inferieure, menton, joues basses) suit la machoire
_i_jaw = NAMES.index("jaw")
_i_head = NAMES.index("head")
_y, _z, _x = P[:, 1], P[:, 2], P[:, 0]
# fondu vertical : 0 au-dessus de la levre (y=0.372), 1 sous le menton (y=0.332)
_t = np.clip((0.372 - _y) / 0.040, 0.0, 1.0)
_t = _t * _t * (3.0 - 2.0 * _t)
# uniquement l'avant du visage (pas la nuque, pas la base du crane)
_t *= np.clip((_z + 0.030) / 0.055, 0.0, 1.0)
_t *= np.clip((0.075 - np.abs(_x)) / 0.030, 0.0, 1.0)
_whead = W[:, _i_head].copy()
W[:, _i_head] = _whead * (1.0 - 0.88 * _t)
W[:, _i_jaw] = _whead * 0.88 * _t
W = np.divide(W, np.maximum(W.sum(axis=1, keepdims=True), 1e-12))
print("machoire : %d sommets transferes (max %.2f de poids)" % (int((_t > 0.05).sum()), float(_t.max())))

# ne garder que 4 influences par sommet (limite standard)''')

# ---------------------------------------------------------------- 3) dents (geometrie ajoutee)
rep('''# ------------------------------------------------------------------ bascule 180 deg : le visage regarde -Z (convention Godot)''',
'''# ------------------------------------------------------------------ dents
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


_uvb = _uv_dent()
DV, DN, DF, DJ = [], [], [], []
_vbase = len(P)
for cote in np.linspace(-0.021, 0.021, 5):
    # dent du haut : pointe vers le bas
    V, N, F = _dent((cote, 0.3565, 0.030), (0.0, -1.0, 0.12), 0.0042, 0.014)
    for v, n in zip(V, N):
        DV.append(v); DN.append(n)
    for f in F:
        DF.append((f[0] + len(DV) - 6, f[1] + len(DV) - 6, f[2] + len(DV) - 6))
        DJ.append(_i_head)
    # dent du bas : pointe vers le haut, portee par la machoire
    V, N, F = _dent((cote, 0.3385, 0.029), (0.0, 1.0, 0.10), 0.0038, 0.012)
    for v, n in zip(V, N):
        DV.append(v); DN.append(n)
    for f in F:
        DF.append((f[0] + len(DV) - 6, f[1] + len(DV) - 6, f[2] + len(DV) - 6))
        DJ.append(_i_jaw)
DV = np.array(DV); DN = np.array(DN)
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
print("dents : %d sommets, %d triangles (teinte UV %.3f, %.3f)" % (len(DV), len(DF), _uvb[0], _uvb[1]))

# ------------------------------------------------------------------ bascule 180 deg : le visage regarde -Z (convention Godot)''')

# la teinte d'os a besoin d'un apercu de la texture + des poids de tete : on les prepare avant
rep('''# ------------------------------------------------------------------ dents''',
'''# apercu de la texture (pour choisir la teinte des dents) et poids de l'os tete
from PIL import Image as _Im2
_im2 = _Im2.open("/home/user/hantise/assets/models/monstre_skin.png").convert("RGB").resize((256, 256), _Im2.LANCZOS)
_TEX_SMALL = np.asarray(_im2, dtype=np.float64) / 255.0
_UVW_HEAD = (JN == NAMES.index("head")).any(axis=1).astype(np.float64)

# ------------------------------------------------------------------ dents''')

# ---------------------------------------------------------------- 4) os ajoute : sidecar
rep('''                              ("thighR","hips","kneeR"),("shinR","thighR","ankleR"),
                              ("footR","shinR","toeR"),("toeR","footR","toetipR")]],''',
'''                              ("thighR","hips","kneeR"),("shinR","thighR","ankleR"),
                              ("footR","shinR","toeR"),("toeR","footR","toetipR"),
                              ("jaw","head","jawtip")]],''')
rep('''    "clavR": "clavR", "upperarmR": "shoulderR", "forearmR": "elbowR", "handR": "wristR",''',
'''    "clavR": "clavR", "upperarmR": "shoulderR", "forearmR": "elbowR", "handR": "wristR",
    "jaw": "jaw",''')

io.open(P, "w", encoding="utf-8").write(s)
print("patch machoire+dents applique")
