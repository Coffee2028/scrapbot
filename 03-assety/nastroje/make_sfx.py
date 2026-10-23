"""Vygeneruje krátké retro zvukové efekty (16bitové mono WAV) pro prototyp SCRAPBOTu.

Použití:  python make_sfx.py ../../04-hra/assets/sfx
Zvuky jsou poskládané z obdélníkové vlny (jako staré konzole) a šumu.
"""
import sys
import wave
from pathlib import Path
import numpy as np

OUT = Path(sys.argv[1])
OUT.mkdir(parents=True, exist_ok=True)
RATE = 22050
rng = np.random.default_rng(3)


def t(sec):
    return np.arange(int(RATE * sec)) / RATE


def square(freq, sec, duty=0.5):
    """Obdélníková vlna; freq může být i pole (pro klouzavý tón)."""
    n = int(RATE * sec)
    f = np.broadcast_to(np.asarray(freq, dtype=float), (n,))
    phase = np.cumsum(f) / RATE
    return np.where((phase % 1.0) < duty, 1.0, -1.0)


def noise(sec):
    return rng.uniform(-1, 1, int(RATE * sec))


def env(n, attack=0.005, release=1.0):
    """Obálka hlasitosti: rychlý náběh, pak postupné doznění."""
    x = np.linspace(0, 1, n)
    a = np.clip(x / max(attack, 1e-4), 0, 1)
    return a * (1 - x) ** (2.0 * release)


def save(name, sig, vol=0.5):
    sig = np.clip(sig * vol, -1, 1)
    data = (sig * 32767).astype('<i2').tobytes()
    with wave.open(str(OUT / f"{name}.wav"), 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(data)


def slide(f0, f1, sec):
    return np.geomspace(f0, f1, int(RATE * sec))


# výstřel robota: krátký klesající tón
s = square(slide(1400, 500, 0.08), 0.08, 0.25)
save('shoot', s * env(len(s)), 0.25)

# výstřel nepřítele: hlubší, bzučivější
s = square(slide(700, 260, 0.1), 0.1, 0.5)
save('enemy_shoot', s * env(len(s)), 0.18)

# zásah nepřítele: cvaknutí šumu + pípnutí
n = noise(0.05) * 0.6 + square(slide(500, 300, 0.05), 0.05) * 0.4
save('hit', n * env(len(n)), 0.35)

# zničený nepřítel: výbuch šumu s klesajícím tónem
sec = 0.28
n = noise(sec)
lp = np.convolve(n, np.ones(6) / 6, mode='same')
s = lp * 0.7 + square(slide(300, 60, sec), sec) * 0.3
save('explode', s * env(len(s), release=0.8), 0.5)

# zásah robota: klesající tón
s = square(slide(600, 150, 0.25), 0.25, 0.5)
save('hurt', s * env(len(s), release=0.6), 0.35)

# sebrání věci: rychlé stoupající arpeggio
parts = [square(f, 0.05, 0.5) for f in (660, 880, 1320)]
s = np.concatenate(parts)
save('pickup', s * env(len(s), release=0.4), 0.25)

# předmět: delší fanfára
parts = [square(f, 0.09, 0.5) for f in (523, 659, 784, 1046)]
s = np.concatenate(parts + [square(1046, 0.25, 0.25)])
save('item', s * env(len(s), release=0.3), 0.25)

# otevření dveří: hluboké mechanické cvaknutí + syčení
sec = 0.3
s = square(slide(160, 90, sec), sec, 0.5) * 0.6 + noise(sec) * 0.25
save('door', s * env(len(s), release=0.7), 0.35)

# EMP: stoupající zapraskání, pak rána
z = square(slide(200, 2400, 0.2), 0.2, 0.5) * env(int(RATE * 0.2), attack=0.2, release=0.1)
b = noise(0.4)
b = np.convolve(b, np.ones(10) / 10, mode='same') * env(len(b), release=0.6)
save('emp', np.concatenate([z * 0.6, b]), 0.6)

# varování před nájezdem bosse: dunění
sec = 0.5
s = square(slide(70, 110, sec), sec, 0.5) * 0.7 + noise(sec) * 0.2
save('boss_charge', s * env(len(s), attack=0.1, release=0.4), 0.45)

# poražený boss: dlouhý klesající výbuch
sec = 1.2
n = np.convolve(noise(sec), np.ones(12) / 12, mode='same')
s = n * 0.8 + square(slide(200, 30, sec), sec) * 0.3
save('boss_die', s * env(len(s), release=0.5), 0.7)

# pípnutí v menu
s = square(990, 0.04, 0.5)
save('blip', s * env(len(s)), 0.2)

# rozbitá bedna: suché prasknutí dřeva
sec = 0.16
n = np.convolve(noise(sec), np.ones(3) / 3, mode='same')
s = n * 0.8 + square(slide(220, 90, sec), sec, 0.3) * 0.35
save('crate', s * env(len(s), release=1.2), 0.45)

print('zvuků:', len(list(OUT.glob('*.wav'))))
