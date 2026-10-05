# =============================================================
#  LE 31 — générateur audio horreur (zéro asset externe)
# =============================================================
import os, math, random, wave, struct

OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "audio")
os.makedirs(OUT, exist_ok=True)
SR = 44100
rng = random.Random(1031)


def write(name, samples):
    mx = max(1e-9, max(abs(s) for s in samples))
    data = b"".join(struct.pack("<h", int(32000 * s / mx)) for s in samples)
    w = wave.open(os.path.join(OUT, name), "wb")
    w.setnchannels(1)
    w.setsampwidth(2)
    w.setframerate(SR)
    w.writeframes(data)
    w.close()
    print("->", name, round(len(samples) / SR, 2), "s")


def env(n, a=0.01, r=0.2, sus=1.0):
    out = []
    for i in range(n):
        t = i / SR
        dur = n / SR
        if t < a:
            out.append(t / a)
        elif t > dur - r:
            out.append(max(0.0, (dur - t) / r) * sus)
        else:
            out.append(sus)
    return out


# ---- drone ambiant (nappe grave + battement) 20 s, bouclable ----
n = SR * 20
s = []
for i in range(n):
    t = i / SR
    v = 0.30 * math.sin(2 * math.pi * 41 * t)
    v += 0.18 * math.sin(2 * math.pi * 41.7 * t)          # battement lent
    v += 0.10 * math.sin(2 * math.pi * 82.3 * t + math.sin(t * 0.7) * 2)
    v += 0.05 * math.sin(2 * math.pi * 123 * t) * (0.5 + 0.5 * math.sin(t * 0.23))
    breath = 0.035 * (0.5 + 0.5 * math.sin(2 * math.pi * 0.11 * t))
    v += breath * (rng.random() * 2 - 1)
    v *= 0.85 + 0.15 * math.sin(2 * math.pi * 0.05 * t)
    s.append(v * 0.5)
# fondu entrée/sortie pour boucle propre
f = int(SR * 1.5)
for i in range(f):
    s[i] *= i / f
    s[-1 - i] *= i / f
write("drone.wav", s)

# ---- pas (étouffé, bois) ----
n = int(SR * 0.16)
s = []
for i in range(n):
    t = i / SR
    e = math.exp(-t * 34)
    v = e * (0.6 * math.sin(2 * math.pi * 78 * t) + 0.25 * (rng.random() * 2 - 1) * math.exp(-t * 60))
    s.append(v)
write("step.wav", s)

# ---- sting reset (cluster dissonant descendant) ----
n = int(SR * 1.1)
s = []
for i in range(n):
    t = i / SR
    e = math.exp(-t * 2.6)
    f0 = 220 * math.exp(-t * 1.4)
    v = e * (math.sin(2 * math.pi * f0 * t) * 0.5
             + math.sin(2 * math.pi * f0 * 1.41 * t) * 0.35
             + math.sin(2 * math.pi * f0 * 0.53 * t) * 0.4)
    v += 0.15 * e * (rng.random() * 2 - 1)
    s.append(v)
write("sting.wav", s)

# ---- chime progression (cloche douce) ----
n = int(SR * 0.9)
s = []
for i in range(n):
    t = i / SR
    e = math.exp(-t * 4.5)
    v = e * (math.sin(2 * math.pi * 660 * t) * 0.4 + math.sin(2 * math.pi * 990 * t) * 0.2
             + math.sin(2 * math.pi * 1320 * t) * 0.08 * math.exp(-t * 9))
    s.append(v)
write("chime.wav", s)

# ---- chuchotement (bruit bandé modulé, inquiétant) ----
n = int(SR * 1.6)
s = []
prev = 0.0
for i in range(n):
    t = i / SR
    m = (0.5 + 0.5 * math.sin(2 * math.pi * 7.3 * t + math.sin(t * 3.1) * 3))
    m *= (0.4 + 0.6 * math.sin(2 * math.pi * 2.1 * t))
    nz = rng.random() * 2 - 1
    prev = 0.86 * prev + 0.14 * nz          # filtre passe-bas grossier
    v = prev * m * 0.9 * math.sin(math.pi * t / 1.6)
    s.append(v)
write("whisper.wav", s)

# ---- battement de coeur ----
n = int(SR * 1.4)
s = [0.0] * n
def thump(t0, amp):
    st = int(t0 * SR)
    for i in range(int(0.22 * SR)):
        t = i / SR
        if st + i < n:
            s[st + i] += amp * math.exp(-t * 18) * math.sin(2 * math.pi * 52 * t)
thump(0.0, 1.0)
thump(0.34, 0.7)
write("heart.wav", s)

# ---- jumpscare (burst + cri grave saturé) ----
n = int(SR * 1.3)
s = []
for i in range(n):
    t = i / SR
    e = math.exp(-t * 1.9)
    v = 0.7 * (rng.random() * 2 - 1) * math.exp(-t * 9)
    f0 = 180 + 240 * math.exp(-t * 5)
    v += e * 0.8 * math.sin(2 * math.pi * f0 * t + 3 * math.sin(2 * math.pi * 6.5 * t))
    v += e * 0.4 * math.sin(2 * math.pi * f0 * 2.02 * t)
    s.append(max(-1, min(1, v * 1.4)))
write("scare.wav", s)

# ---- grincement de porte ----
n = int(SR * 1.2)
s = []
ph = 0.0
for i in range(n):
    t = i / SR
    f0 = 300 + 260 * math.sin(t * 5.1) + 120 * math.sin(t * 13.7)
    ph += 2 * math.pi * f0 / SR
    e = math.sin(math.pi * t / 1.2) ** 0.7
    v = e * (0.4 * math.sin(ph) + 0.2 * math.sin(ph * 2.7) + 0.1 * (rng.random() * 2 - 1))
    s.append(v * 0.7)
write("creak.wav", s)

# ---- souffle (haletement) ----
n = int(SR * 1.0)
s = []
prev = 0.0
for i in range(n):
    t = i / SR
    ph = t / 1.0
    amp = math.sin(math.pi * ph) ** 1.5
    nz = rng.random() * 2 - 1
    prev = 0.72 * prev + 0.28 * nz
    v = amp * prev * 0.9 * (0.55 + 0.45 * math.sin(2 * math.pi * 1.1 * t))
    s.append(v)
write("breath.wav", s)

# ---- pas v2 : thump bois + craquement ----
n = int(SR * 0.22)
s = []
for i in range(n):
    t = i / SR
    thump = math.exp(-t * 30) * math.sin(2 * math.pi * 70 * t)
    creak = math.exp(-t * 14) * math.sin(2 * math.pi * (240 + 180 * math.exp(-t * 8)) * t + 2 * math.sin(2 * math.pi * 9 * t))
    v = thump * 0.8 + creak * 0.35 + (rng.random() * 2 - 1) * math.exp(-t * 50) * 0.2
    s.append(v)
write("step.wav", s)

# ---- drone étendu 45 s ----
n = SR * 45
s = []
for i in range(n):
    t = i / SR
    v = 0.30 * math.sin(2 * math.pi * 41 * t)
    v += 0.18 * math.sin(2 * math.pi * 41.7 * t)
    v += 0.10 * math.sin(2 * math.pi * 82.3 * t + math.sin(t * 0.7) * 2)
    v += 0.05 * math.sin(2 * math.pi * 123 * t) * (0.5 + 0.5 * math.sin(t * 0.23))
    v += 0.035 * (0.5 + 0.5 * math.sin(2 * math.pi * 0.11 * t)) * (rng.random() * 2 - 1)
    v *= 0.85 + 0.15 * math.sin(2 * math.pi * 0.05 * t)
    s.append(v * 0.5)
f = int(SR * 1.5)
for i in range(f):
    s[i] *= i / f
    s[-1 - i] *= i / f
write("drone.wav", s)

# ---- vent loop 20 s ----
n = SR * 20
s = []
prev = 0.0
prev2 = 0.0
for i in range(n):
    t = i / SR
    nz = rng.random() * 2 - 1
    prev = 0.94 * prev + 0.06 * nz
    prev2 = 0.985 * prev2 + 0.015 * nz
    gust = 0.4 + 0.6 * (0.5 + 0.5 * math.sin(2 * math.pi * 0.07 * t + math.sin(t * 0.31) * 2))
    s.append((prev * 1.6 + prev2 * 1.2) * gust * 0.8)
f = int(SR * 1.0)
for i in range(f):
    s[i] *= i / f
    s[-1 - i] *= i / f
write("wind.wav", s)

# ---- maison qui craque : 24 s, événements espacés ----
n = SR * 24
s = [0.0] * n
for ev in range(7):
    t0 = rng.random() * 22.0
    st = int(t0 * SR)
    dur = int(0.5 * SR)
    ph = 0.0
    f0 = rng.uniform(180, 420)
    for i in range(dur):
        if st + i < n:
            t = i / SR
            ph += 2 * math.pi * (f0 + 90 * math.sin(t * 7)) / SR
            s[st + i] += math.exp(-t * 6) * (0.5 * math.sin(ph) + 0.2 * math.sin(ph * 2.3)) * 0.5
write("house.wav", s)

# ---------- stéréo + piste tension ----------
def write2(name, L, R):
    mx = max(1e-9, max(abs(v) for v in L), max(abs(v) for v in R))
    data = b"".join(struct.pack("<hh", int(32000 * a / mx), int(32000 * b / mx)) for a, b in zip(L, R))
    w = wave.open(os.path.join(OUT, name), "wb")
    w.setnchannels(2)
    w.setsampwidth(2)
    w.setframerate(SR)
    w.writeframes(data)
    w.close()
    print("->", name, round(len(L) / SR, 2), "s stereo")

# drone 45 s stereo (modulation décalée L/R)
n = SR * 45
L = []
R = []
for i in range(n):
    t = i / SR
    a = 0.30 * math.sin(2 * math.pi * 41 * t) + 0.18 * math.sin(2 * math.pi * 41.7 * t)
    a += 0.10 * math.sin(2 * math.pi * 82.3 * t + math.sin(t * 0.7) * 2)
    a += 0.05 * math.sin(2 * math.pi * 123 * t) * (0.5 + 0.5 * math.sin(t * 0.23))
    b = 0.30 * math.sin(2 * math.pi * 41 * t + 0.4) + 0.18 * math.sin(2 * math.pi * 41.9 * t)
    b += 0.10 * math.sin(2 * math.pi * 82.3 * t + math.sin(t * 0.7 + 1.1) * 2)
    b += 0.05 * math.sin(2 * math.pi * 123 * t + 0.8) * (0.5 + 0.5 * math.sin(t * 0.21))
    g = 0.85 + 0.15 * math.sin(2 * math.pi * 0.05 * t)
    L.append(a * g * 0.5)
    R.append(b * g * 0.5)
f = int(SR * 1.5)
for i in range(f):
    L[i] *= i / f; L[-1 - i] *= i / f
    R[i] *= i / f; R[-1 - i] *= i / f
write2("drone.wav", L, R)

# vent 20 s stereo
n = SR * 20
L = []
R = []
p1 = p2 = p3 = p4 = 0.0
for i in range(n):
    t = i / SR
    p1 = 0.94 * p1 + 0.06 * (rng.random() * 2 - 1)
    p2 = 0.985 * p2 + 0.015 * (rng.random() * 2 - 1)
    p3 = 0.94 * p3 + 0.06 * (rng.random() * 2 - 1)
    p4 = 0.985 * p4 + 0.015 * (rng.random() * 2 - 1)
    g1 = 0.4 + 0.6 * (0.5 + 0.5 * math.sin(2 * math.pi * 0.07 * t + math.sin(t * 0.31) * 2))
    g2 = 0.4 + 0.6 * (0.5 + 0.5 * math.sin(2 * math.pi * 0.07 * t + 1.7 + math.sin(t * 0.27) * 2))
    L.append((p1 * 1.6 + p2 * 1.2) * g1 * 0.8)
    R.append((p3 * 1.6 + p4 * 1.2) * g2 * 0.8)
f = int(SR * 1.0)
for i in range(f):
    L[i] *= i / f; L[-1 - i] *= i / f
    R[i] *= i / f; R[-1 - i] *= i / f
write2("wind.wav", L, R)

# maison 24 s stereo (pan aléatoire par événement)
n = SR * 24
L = [0.0] * n
R = [0.0] * n
for ev in range(8):
    t0 = rng.random() * 22.0
    st = int(t0 * SR)
    dur = int(0.5 * SR)
    ph = 0.0
    f0 = rng.uniform(180, 420)
    pan = rng.uniform(-0.7, 0.7)
    gl = math.cos((pan + 1) * math.pi / 4)
    gr = math.sin((pan + 1) * math.pi / 4)
    for i in range(dur):
        if st + i < n:
            t = i / SR
            ph += 2 * math.pi * (f0 + 90 * math.sin(t * 7)) / SR
            v = math.exp(-t * 6) * (0.5 * math.sin(ph) + 0.2 * math.sin(ph * 2.3)) * 0.5
            L[st + i] += v * gl
            R[st + i] += v * gr
write2("house.wav", L, R)

# tension 20 s loop : pouls 140 BPM + triton tendu + ticks
n = SR * 20
L = [0.0] * n
R = [0.0] * n
per = int(60.0 / 140 * SR)
for k in range(0, n, per):
    for i in range(int(0.22 * SR)):
        if k + i < n:
            t = i / SR
            v = math.exp(-t * 14) * math.sin(2 * math.pi * (55 + 30 * math.exp(-t * 20)) * t) * 0.8
            L[k + i] += v * 0.9
            R[k + i] += v * 0.9
for i in range(n):
    t = i / SR
    sw = 0.5 + 0.5 * math.sin(2 * math.pi * 0.09 * t)
    a = 0.10 * math.sin(2 * math.pi * 220 * t) + 0.05 * math.sin(2 * math.pi * 440 * t + 1)
    b = 0.10 * math.sin(2 * math.pi * 311.1 * t) + 0.05 * math.sin(2 * math.pi * 466.2 * t + 1)
    tick = 0.0
    if (i % (per // 2)) < int(0.01 * SR):
        tick = 0.12 * (rng.random() * 2 - 1)
    L[i] += a * (0.4 + 0.6 * sw) + tick
    R[i] += b * (0.4 + 0.6 * (1 - sw)) + tick
f = int(SR * 0.8)
for i in range(f):
    L[i] *= i / f; L[-1 - i] *= i / f
    R[i] *= i / f; R[-1 - i] *= i / f
write2("tension.wav", L, R)

# ---- musique angoissante 60 s stereo v2 (basse renforcee) ----
n = SR * 60
L = [0.0] * n
R = [0.0] * n
notes = [220.0, 261.63, 329.63, 392.0, 440.0]
events = []
tt0 = 2.0
while tt0 < 56.0:
    events.append((tt0, rng.choice(notes), rng.uniform(-0.7, 0.7)))
    tt0 += rng.uniform(4.0, 7.0)
for i in range(n):
    t = i / SR
    sub = 0.30 * math.sin(2 * math.pi * 55 * t + math.sin(t * 0.21) * 1.4)
    pad = 0.20 * math.sin(2 * math.pi * 110 * t + math.sin(t * 0.3) * 0.8)
    pad += 0.15 * math.sin(2 * math.pi * 130.81 * t + 1.2 + math.sin(t * 0.23) * 0.6)
    pad += 0.11 * math.sin(2 * math.pi * 164.81 * t + 2.1 + math.sin(t * 0.17) * 0.5)
    trem = 0.7 + 0.3 * math.sin(2 * math.pi * 0.09 * t)
    tb = t % 1.2
    pulse = 0.0
    if tb < 0.35:
        pulse = math.exp(-tb * 10) * math.sin(2 * math.pi * (48 + 26 * math.exp(-tb * 14)) * tb) * 0.85
    hb = t % 2.4
    heart = 0.0
    if hb < 0.25:
        heart = math.exp(-hb * 16) * math.sin(2 * math.pi * 40 * hb) * 0.35
    crack = 0.014 * (rng.random() * 2 - 1)
    v = (sub + pad * trem + pulse + heart) * 0.9 + crack
    L[i] += v
    R[i] += v * 0.93 + 0.03 * math.sin(2 * math.pi * 110.7 * t)
for (t0, f, pan) in events:
    st = int(t0 * SR)
    dur = int(2.4 * SR)
    gl = math.cos((pan + 1) * math.pi / 4)
    gr = math.sin((pan + 1) * math.pi / 4)
    for i in range(dur):
        if st + i < n:
            t = i / SR
            v = math.exp(-t * 2.4) * (0.34 * math.sin(2 * math.pi * f * t) + 0.12 * math.sin(2 * math.pi * f * 2 * t + 0.5)) * 0.6
            L[st + i] += v * gl
            R[st + i] += v * gr
f = int(SR * 2.0)
for i in range(f):
    L[i] *= i / f; L[-1 - i] *= i / f
    R[i] *= i / f; R[-1 - i] *= i / f
write2("music.wav", L, R)

print("AUDIO H OK")

# ---- growl : grognement grave de la créature (2,4 s) ----
n = int(SR * 2.4)
s = []
r2 = random.Random(77)
for i in range(n):
    t = i / SR
    base = math.sin(2 * math.pi * 62 * t) * 0.5 + math.sin(2 * math.pi * 93 * t) * 0.3 + math.sin(2 * math.pi * 41 * t) * 0.4
    mod = 0.55 + 0.45 * math.sin(2 * math.pi * 3.1 * t)
    grit = (r2.random() * 2 - 1) * 0.22
    sub = math.sin(2 * math.pi * 17 * t) * 0.25
    v = (base * mod + grit + sub)
    v = math.tanh(v * 1.6)
    s.append(v * env(n, a=0.35, r=0.9)[i])
write("growl.wav", s)

# ---- sniff : reniflement (0,55 s, deux inspirations) ----
n = int(SR * 0.55)
s = []
r3 = random.Random(913)
for i in range(n):
    t = i / SR
    burst = 0.0
    for (st, ln) in ((0.0, 0.16), (0.24, 0.20)):
        if st <= t < st + ln:
            k = (t - st) / ln
            burst += math.sin(math.pi * k) * (1.0 - k * 0.35)
    v = burst * ((r3.random() * 2 - 1) * 0.9 + math.sin(2 * math.pi * 230 * t) * 0.12)
    s.append(v)
write("sniff.wav", s)
