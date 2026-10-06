# -*- coding: utf-8 -*-
"""LE 31 — animation de la creature : PROTOTYPE DE REFERENCE (portage GDScript ensuite).

Choix techniques (ce qui fait la difference entre un monstre amateur et professionnel) :
  * squelette : 21 os, peau continue (aucune boule, aucun morceau qui baille) ;
  * jambes en IK 2 os : le pied se pose OU on veut, le genou se plie tout seul ;
  * phase d'appui pilotee par la DISTANCE parcourue -> le pied pose ne patine pas ;
  * le bassin s'abaisse automatiquement quand la foulee s'allonge (jamais de jambe
    trop tendue) : c'est ce qui donne la demarche voûtee d'une creature ;
  * bras en FK avec retard (whip), tete qui suit le joueur, micro-tics + respiration ;
  * canaux de pose lisses -> transitions douces entre rôde / alerte / chasse / recul / bond.
"""
import json, struct, math
import numpy as np
from PIL import Image

MOD = "/home/user/hantise/assets/models/monstre_rig.glb"
SIDE = json.load(open("/home/user/hantise/assets/models/monstre_rig_bones.json"))
NAMES = [b["name"] for b in SIDE["bones"]]
PARENT = {b["name"]: b["parent"] for b in SIDE["bones"]}
HEAD = {b["name"]: np.array(b["head"]) for b in SIDE["bones"]}
TAIL = {b["name"]: np.array(b["tail"]) for b in SIDE["bones"]}
L_THIGH = float(np.linalg.norm(TAIL["thighL"] - HEAD["thighL"]))
L_SHIN = float(np.linalg.norm(TAIL["shinL"] - HEAD["shinL"]))
Y_HIP = HEAD["thighL"][1]
Y_ANK = HEAD["footL"][1]
HIP_X = abs(HEAD["thighL"][0])
CHAIN = 0.985 * (L_THIGH + L_SHIN)   # reserve d'allonge : genou jamais verrouille


def sag(a, b):
    """angle sagittal (positif = vers l'avant, -Z) de a vers b"""
    return math.atan2(-(b[2] - a[2]), (a[1] - b[1]))


B_THIGH = sag(HEAD["thighL"], TAIL["thighL"])
B_SHIN = sag(HEAD["shinL"], TAIL["shinL"])
B_FOOT = sag(HEAD["footL"], TAIL["footL"])


# semelle : enveloppe convexe des points de contact dans le repere local de l'os du pied
SOLE = json.load(open("/home/user/hantise/assets/models/monstre_sole.json"))

def sole_low(theta):
    """ordonnee du point de semelle le plus bas apres une rotation de tangage theta (autour de X)"""
    h = SOLE["footL"]["hull"]
    return min(p[1] * math.cos(theta) - p[2] * math.sin(theta) for p in h)

SOLE_K0 = sole_low(0.0)


def sstep(t):
    t = max(0.0, min(1.0, t)); return t * t * (3 - 2 * t)


def lerp(a, b, t):
    return a + (b - a) * max(0.0, min(1.0, t))


class Canaux:
    """canaux de pose lisses (le fondu entre modes est automatique)"""
    def __init__(self):
        self.v = dict(lean=0.0, roll=0.0, head_p=0.0, head_y=0.0, arm_x=0.0, arm_z=0.0,
                      elbow=0.0, shoulder_up=0.0, chest_p=0.0, gait_amp=1.0, stride=0.40,
                      arm_fwd=0.0, jaw=0.06, gait=0.0)
        self.c = dict(self.v)

    def set(self, **kw):
        self.c.update(kw)

    # canaux INTEGRES (jamais lisses) : la phase de marche avance avec la distance parcourue
    LIBRES = ("gait",)

    def step(self, d, rate=4.5):
        k = min(1.0, rate * d)
        for n in self.v:
            if n in Canaux.LIBRES or n.startswith("_"):
                continue
            self.v[n] = lerp(self.v[n], self.c[n], k)


MODE_POSE = {
    #            lean   roll  head_p  arm_x  arm_z elbow  sh_up  chest_p  amp   stride
    0: dict(lean=0.05, roll=0.0, head_p=0.10, arm_x=-0.15, arm_z=0.60, arm_fwd=-0.30, elbow=-0.30,
            shoulder_up=0.05, chest_p=0.08, gait_amp=0.45, stride=0.30, jaw=0.06),
    1: dict(lean=0.20, roll=0.0, head_p=-0.05, arm_x=-0.10, arm_z=0.55, arm_fwd=-0.48, elbow=-0.60,
            shoulder_up=0.10, chest_p=0.14, gait_amp=1.0, stride=0.42, jaw=0.12),
    2: dict(lean=0.42, roll=0.0, head_p=-0.14, arm_x=0.30, arm_z=0.10, arm_fwd=-1.10, elbow=-1.00,
            shoulder_up=0.28, chest_p=0.22, gait_amp=1.2, stride=0.56, jaw=0.34),
    3: dict(lean=-0.28, roll=0.0, head_p=0.26, arm_x=0.10, arm_z=0.50, arm_fwd=-0.50, elbow=-1.30,
            shoulder_up=0.45, chest_p=-0.14, gait_amp=0.35, stride=0.25, jaw=0.60),
    4: dict(lean=0.60, roll=0.0, head_p=0.12, arm_x=0.35, arm_z=0.05, arm_fwd=-1.30, elbow=-0.50,
            shoulder_up=0.40, chest_p=0.30, gait_amp=0.8, stride=0.34, jaw=0.46),
}


def pose(t, mode, speed_world, move_dir=(0.0, -1.0), look_deg=0.0, roll_in=0.0, scale=2.8):
    """t : temps (s) ; mode : 0 rôde, 1 alerte, 2 chasse, 3 recul, 4 bond
       speed_world : vitesse au sol (m/s monde) ; move_dir : direction (x, z) unitaire ;
       look_deg : angle du regard relatif au corps ; rend (rotations par os, offset bassin)
       Les rotations sont (axe, angle) en espace LOCAL du parent (identique au repos Godot)."""
    c = Canaux()
    return None  # remplace plus bas


def anim_step(c: Canaux, d, t, mode, speed_world, look_deg, roll_in, scale=2.8):
    S = scale
    sp = speed_world / S                      # unites modele / s
    c.set(**MODE_POSE[mode])
    c.set(head_y=math.radians(max(-75.0, min(75.0, look_deg))), roll=roll_in)
    c.step(d, rate=(5.0 if mode == 2 else 3.6))
    v = c.v
    moving = sp > 0.03
    # --- l'allure avance avec la DISTANCE (pas verrouilles au sol) : phase += dist / foulee
    if moving:
        # l'appui dure 0,62 cycle : le cycle complet vaut donc stride/0,62 -- sinon le pied
        # pose patine (il recule de 1/0,62 = 1,61 fois la vitesse d'avancee)
        v["gait"] += (sp * d) / max(0.08, v["stride"] / 0.62)
    g = v["gait"]

    sway = 0.045 * v["gait_amp"] * math.sin(2 * math.pi * g)
    # rotation du bassin : les jambes en heritent, il faut la retrancher pour que l'IK
    # place le pied la ou on le veut (sinon deplacement horizontal de ~12 cm)
    hips_pitch = v["lean"] * 0.30
    hips_roll = sway * 0.55

    # --- jambes : IK 2 os, exactement atteignables (le pied pose touche le sol sans le traverser)
    yaw_h = 0.09 * v["gait_amp"] * math.sin(2 * math.pi * g)
    # 1) cibles horizontales des deux pieds
    cibles = []
    for side, ph in (("L", g), ("R", g + 0.5)):
        p = ph % 1.0
        if p < 0.62:                      # appui : le pied recule exactement a la vitesse d'avancee
            fwd = v["stride"] * (0.5 - p / 0.62)
            lift = 0.0
            plantar = 0.55 * max(0.0, (p - 0.42) / 0.20) ** 2
        else:                             # balancement
            u = (p - 0.62) / 0.38
            fwd = v["stride"] * (-0.5 + sstep(u))
            lift = 0.14 * math.sin(math.pi * u) ** 0.75 * (1.0 if mode >= 1 else 0.6)
            plantar = -0.22 * math.sin(math.pi * u)
        sgn = 1.0 if side == "L" else -1.0
        dz = -fwd - HIP_X * math.sin(yaw_h) * sgn
        cibles.append((side, p, dz, lift, plantar))
    # 2) hauteur du bassin : constante sur tout le cycle, calee sur la foulee maximale
    #    (si on la faisait varier a chaque image, le bassin pomperait de 40 cm)
    half_max = min(v["stride"] * 0.5, CHAIN * 0.97)
    need = math.sqrt(max(0.0009, CHAIN * CHAIN - half_max * half_max))
    hips_base = (Y_ANK + need) - Y_HIP
    # 3) oscillation verticale : les hanches montent pendant la phase aérienne, jamais plus bas
    bob2 = 0.020 * v["gait_amp"] * abs(math.sin(2 * math.pi * g))
    R = {}
    for side, p, dz, lift, plantar in cibles:
        sgn = 1.0 if side == "L" else -1.0
        hip_y = Y_HIP + hips_base + bob2
        # la cheville monte juste ce qu'il faut pour que la semelle touche le sol sans le traverser
        ank_y = lift + Y_ANK + max(0.0, SOLE_K0 - sole_low(plantar)) + 0.004
        down = hip_y - ank_y
        dist = min(CHAIN, math.hypot(dz, down))
        cosk = (L_THIGH ** 2 + L_SHIN ** 2 - dist * dist) / (2 * L_THIGH * L_SHIN)
        knee = math.pi - math.acos(max(-1.0, min(1.0, cosk)))
        cosc = (L_THIGH ** 2 + dist * dist - L_SHIN ** 2) / (2 * L_THIGH * dist)
        beta = math.atan2(-dz, down)
        thigh_a = beta + math.acos(max(-1.0, min(1.0, cosc)))
        shin_abs = thigh_a - knee
        brut = {
            "thigh" + side: thigh_a - B_THIGH,
            "shin" + side: (shin_abs - thigh_a) - (B_SHIN - B_THIGH),
            "foot" + side: (B_FOOT + plantar) - shin_abs - (B_FOOT - B_SHIN),
        }
        # filtre 1 pole : supprime le tremblement residuel de l'IK sans amortir le mouvement
        for k, val in brut.items():
            prec = v.get("_" + k, val)
            v["_" + k] = lerp(prec, val, min(1.0, 16.0 * d))
        R["thigh" + side] = [((1, 0, 0), v["_thigh" + side] - hips_pitch),
                             ((0, 0, 1), -sgn * sway * 0.35 - hips_roll)]
        R["shin" + side] = [((1, 0, 0), v["_shin" + side])]
        # rotation LOCALE du pied = (absolu voulu - absolu du parent) - (repos absolu - repos du parent)
        R["foot" + side] = [((1, 0, 0), v["_foot" + side])]
        R["toe" + side] = [((1, 0, 0), 0.0)]      # orteils fixes : moins d'artefacts

    # --- colonne / tete
    R["hips"] = [((1, 0, 0), v["lean"] * 0.30), ((0, 0, 1), sway * 0.55), ((0, 1, 0), yaw_h * 0.55)]
    R["spine"] = [((1, 0, 0), v["lean"] * 0.34), ((0, 0, 1), -sway * 0.30)]
    resp = 0.02 * math.sin(t * 1.15) if mode == 0 else 0.03 * math.sin(t * 3.1)
    R["chest"] = [((1, 0, 0), v["lean"] * 0.30 + v["chest_p"] * 0.30 + resp),
                  ((0, 0, 1), -sway * 0.25)]
    R["neck"] = [((1, 0, 0), v["head_p"] * 0.35 + resp * 0.6), ((0, 1, 0), v["head_y"] * 0.35)]
    ticoy = 0.09 * math.sin(t * 0.63); ticop = 0.05 * math.sin(t * 3.7 + 1.0)
    R["head"] = [((1, 0, 0), v["head_p"] * 0.65 + ticop + (0.09 if mode >= 2 else 0.0)),
                 ((0, 1, 0), v["head_y"] * 0.65 + ticoy),
                 ((0, 0, 1), 0.05 * math.sin(t * 1.9))]

    # --- machoire : elle s'ouvre en chassant, avec des claquements
    ouv = v["jaw"]
    if mode == 2:
        ouv += 0.20 * max(0.0, math.sin(t * 7.0)) ** 3.0     # claquements rapides
    elif mode == 3:
        ouv += 0.12 * abs(math.sin(t * 9.0))                  # hurlement
    R["jaw"] = [((1, 0, 0), -ouv)]   # NEGATIF = la machoire descend (mesure au rapporteur)
    # --- bras : balancier + pose de chasse, avec un leger retard (effet fouet)
    for side, ph in (("R", g), ("L", g + 0.5)):
        sgn = 1.0 if side == "L" else -1.0
        sw = math.sin(2 * math.pi * (ph % 1.0)) * 0.42 * v["gait_amp"]
        ax = v["arm_x"] + sw * (0.5 if mode != 0 else 0.15)
        az = v["arm_z"] * sgn
        el = v["elbow"] - abs(sw) * 0.22
        R["clav" + side] = [((0, 0, 1), -sgn * v["shoulder_up"] * 0.30)]
        # Y negatif pour le cote gauche : c'est ce qui envoie le bras VERS L'AVANT (mesure au rapporteur)
        R["upperarm" + side] = [((1, 0, 0), ax), ((0, 0, 1), az), ((0, 1, 0), -sgn * (0.10 + v["arm_fwd"]))]
        R["forearm" + side] = [((1, 0, 0), el)]
        R["hand" + side] = [((1, 0, 0), -0.18 + 0.10 * math.sin(t * 5.1 + sgn)),
                            ((0, 0, 1), az * 0.4)]
    return R, hips_base + bob2
