"""Vygeneruje pixel art pro prototyp SCRAPBOTu.

Použití:  python make_sprites.py ../../04-hra/assets/sprites
(ikona hry icon.png se uloží o dvě složky výš, tedy do 04-hra/)

Paleta podle ideového plánu: rezavě oranžová, ocelově šedá, tmavé pozadí
a neonově tyrkysová pro robota a důležité věci.
Každý obrázek je mřížka znaků, každý znak je jedna barva z palety PAL.
"""
import random
import sys
from pathlib import Path
from PIL import Image, ImageDraw

OUT = Path(sys.argv[1])
OUT.mkdir(parents=True, exist_ok=True)

PAL = {
    '.': (0, 0, 0, 0),
    'k': (20, 16, 24, 255),      # obrys
    'g': (59, 63, 74, 255),      # tmavá ocel
    'G': (107, 114, 128, 255),   # ocel
    'h': (166, 173, 184, 255),   # světlá ocel
    'w': (232, 237, 242, 255),   # bílá
    't': (25, 227, 209, 255),    # neonová tyrkysová
    'T': (15, 143, 134, 255),    # tmavá tyrkysová
    'o': (217, 98, 43, 255),     # rezavě oranžová
    'O': (138, 58, 28, 255),     # tmavá rez
    'y': (255, 197, 49, 255),    # výstražná žlutá
    'r': (224, 48, 58, 255),     # červená
    'b': (122, 84, 50, 255),     # dřevo
    'B': (74, 50, 30, 255),      # tmavé dřevo
    'c': (40, 43, 51, 255),      # beton
    'C': (50, 54, 63, 255),      # světlejší beton
    'p': (140, 92, 230, 255),    # fialová (EMP)
    'P': (90, 60, 170, 255),     # tmavě fialová (EMP)
    'e': (60, 200, 90, 255),     # zelená (čip)
    'E': (25, 110, 50, 255),     # tmavě zelená (čip)
}


def grid(name, rows):
    w = len(rows[0])
    for i, r in enumerate(rows):
        assert len(r) == w, f"{name}: řádek {i} má {len(r)} znaků, má mít {w}"
    img = Image.new('RGBA', (w, len(rows)))
    for y, r in enumerate(rows):
        for x, ch in enumerate(r):
            img.putpixel((x, y), PAL[ch])
    img.save(OUT / f"{name}.png")
    return img


# ---------- postavy ----------
grid('player', [
    "................",
    ".......tt.......",
    ".......kk.......",
    "....kkkkkkkk....",
    "...khhhhhhhhk...",
    "...khkkkkkkhk...",
    "...khktkktkhk...",
    "...khkkkkkkhk...",
    "...khhhhhhhhk...",
    "....kkkkkkkk....",
    "...kTttttttTk...",
    "..kGkTttttTkGk..",
    "..kGkTtyytTkGk..",
    "....kTttttTk....",
    "....kGk..kGk....",
    "....kkk..kkk....",
])

grid('drone', [
    "................",
    "..kkkkk..kkkkk..",
    "......kkkk......",
    ".......kk.......",
    "....kkkkkkkk....",
    "...kGGGGGGGGk...",
    "..kGhhhhhhhhGk..",
    "..kGhkkkkkkhGk..",
    "..kGhkoooOkhGk..",
    "..kGhkkkkkkhGk..",
    "..kGGGGGGGGGGk..",
    "...kGGGGGGGGk...",
    "....kkkkkkkk....",
    ".......kk.......",
    "......kyyk......",
    ".......yy.......",
])

grid('turret', [
    "................",
    ".......kk.......",
    "......kGGk......",
    "......kGGk......",
    "....kkkGGkkk....",
    "...kOOOOOOOOk...",
    "...kOooooooOk...",
    "kGGkOoorrooOkGGk",
    "kGGkOoorrooOkGGk",
    "...kOooooooOk...",
    "...kOOOOOOOOk...",
    "....kkkGGkkk....",
    "......kGGk......",
    "......kGGk......",
    ".......kk.......",
    "................",
])

grid('cart', [
    "................",
    "................",
    ".kkkkkkkkkkkkkk.",
    ".kgGgGgGgGgGgGk.",
    ".kkkkkkkkkkkkkk.",
    "..kOOOOOOOOOOk..",
    "..kOooooooooOk..",
    "..kOoyykkyyoOk..",
    "..kOooooooooOk..",
    "..kOOOOOOOOOOk..",
    ".kkkkkkkkkkkkkk.",
    ".kgGgGgGgGgGgGk.",
    ".kkkkkkkkkkkkkk.",
    "................",
    "................",
    "................",
])

# ---------- boss: vysokozdvižný vozík „Kladivo“ (32x32), kreslený tvary ----------
def boss():
    img = Image.new('RGBA', (32, 32), PAL['.'])
    d = ImageDraw.Draw(img)
    k, o, O, G, g, h, y, r = (PAL[c] for c in 'koOGghyr')
    # stožár (dvě kolejnice) vzadu
    d.rectangle([7, 1, 9, 14], fill=g, outline=k)
    d.rectangle([22, 1, 24, 14], fill=g, outline=k)
    d.rectangle([7, 1, 24, 3], fill=G, outline=k)
    # klec kabiny
    d.rectangle([9, 5, 22, 14], fill=(30, 30, 38, 255), outline=k)
    for x in (12, 15, 18):
        d.line([x, 5, x, 14], fill=G)
    # naštvané oči v kabině
    d.rectangle([11, 9, 13, 10], fill=r)
    d.rectangle([18, 9, 20, 10], fill=r)
    # karoserie
    d.rectangle([4, 14, 27, 25], fill=o, outline=k)
    d.rectangle([5, 23, 26, 24], fill=O)
    # výstražný pruh
    for i, x in enumerate(range(6, 26, 4)):
        d.rectangle([x, 16, x + 1, 17], fill=y if i % 2 == 0 else k)
    d.rectangle([13, 19, 18, 21], fill=k)          # mřížka
    d.line([14, 20, 17, 20], fill=G)
    # kola
    for x in (3, 24):
        d.rectangle([x, 22, x + 4, 28], fill=k)
        d.rectangle([x + 1, 24, x + 3, 26], fill=g)
    # vidle
    d.rectangle([9, 26, 11, 31], fill=h, outline=k)
    d.rectangle([20, 26, 22, 31], fill=h, outline=k)
    img.save(OUT / 'boss_forklift.png')


boss()

# ---------- střely ----------
grid('bullet_player', [
    "..tt..",
    ".twwt.",
    "twwwwt",
    "twwwwt",
    ".twwt.",
    "..tt..",
])
grid('bullet_enemy', [
    "..oo..",
    ".oyyo.",
    "oyyyyo",
    "oyyyyo",
    ".oyyo.",
    "..oo..",
])

# ---------- dlaždice ----------
def floor():
    rnd = random.Random(7)
    img = Image.new('RGBA', (16, 16), PAL['c'])
    for _ in range(18):
        img.putpixel((rnd.randrange(16), rnd.randrange(16)), PAL['C'])
    for _ in range(6):
        img.putpixel((rnd.randrange(16), rnd.randrange(16)), (34, 37, 44, 255))
    for i in range(16):  # jemné spáry, aby podlaha vypadala jako velké betonové desky
        img.putpixel((i, 15), (35, 38, 45, 255))
        img.putpixel((15, i), (35, 38, 45, 255))
    img.save(OUT / 'floor.png')


floor()

grid('wall', [
    "kkkkkkkkkkkkkkkk",
    "kGGGGGGGGGGGGGGk",
    "kGhGGGGGGGGGGhGk",
    "kGGGGGGGGGGGGGGk",
    "kGGGGGGGGGGGGGGk",
    "kGGGGGGGGGGGGGGk",
    "kgggggggggggggGk",
    "kkkkkkkkkkkkkkkk",
    "kGGGGGGkGGGGGGGk",
    "kGhGGGGkGGGGGhGk",
    "kGGGGGGkGGGGGGGk",
    "kGGGGGGkGGGGGGGk",
    "kGGGGGGkGGGGGGGk",
    "kgggggGkgggggggk",
    "kgggggGkgggggggk",
    "kkkkkkkkkkkkkkkk",
])

grid('crate', [
    "kkkkkkkkkkkkkkkk",
    "kbbbbbbbbbbbbbbk",
    "kbBkkkkkkkkkkBbk",
    "kbkbbbbbbbbbbkbk",
    "kbkBbbbbbbbbBkbk",
    "kbkbBbbbbbbBbkbk",
    "kbkbbBbbbbBbbkbk",
    "kbkbbbBbbBbbbkbk",
    "kbkbbbbBBbbbbkbk",
    "kbkbbbBbbBbbbkbk",
    "kbkbbBbbbbBbbkbk",
    "kbkbBbbbbbbBbkbk",
    "kbkBbbbbbbbbBkbk",
    "kbBkkkkkkkkkkBbk",
    "kbbbbbbbbbbbbbbk",
    "kkkkkkkkkkkkkkkk",
])
# naštípnutá bedna (po prvním zásahu): prasklina a uštípnutý roh
grid('crate_cracked', [
    "..kkkkkkkkkkkkkk",
    ".kkbbbbbbbkbbbbk",
    "kkBkkkkkkkkkkBbk",
    "kbkbbbbbbkbbbkbk",
    "kbkBbbbbbbkbBkbk",
    "kbkbBbbbbkbBbkbk",
    "kbkbbBbbbkBbbkbk",
    "kbkbbbBbkbBbbkbk",
    "kbkbbbbkBbbbbkbk",
    "kbkbbbkbbBbbbkbk",
    "kbkbbBbkbbBbbkbk",
    "kbkbkbbbkbbBbkbk",
    "kbkBbbbbbkbbBkbk",
    "kbBkkkkkkkkkkBbk",
    "kbbbbkbbbbbbbbbk",
    "kkkkkkkkkkkkkkkk",
])

# dveře jsou nakreslené pro HORNÍ stěnu; pro ostatní strany je hra otočí
grid('door_closed', [
    "kkkkkkkkkkkkkkkk",
    "kykkykkykkykkyyk",
    "kkykkykkykkykkyk",
    "kGGGGGGGGGGGGGGk",
    "kghhhhhhhhhhhhgk",
    "kGGGGGGGGGGGGGGk",
    "kghhhhhhhhhhhhgk",
    "kGGGGGGGGGGGGGGk",
    "kghhhhhhhhhhhhgk",
    "kGGGGGGGGGGGGGGk",
    "kghhhhhhhhhhhhgk",
    "kGGGGGGrrGGGGGGk",
    "kghhhhhrrhhhhhgk",
    "kGGGGGGGGGGGGGGk",
    "kgggggggggggggGk",
    "kkkkkkkkkkkkkkkk",
])
grid('door_open', [
    "kkkkkkkkkkkkkkkk",
    "kykkykkykkykkyyk",
    "kkykkykkykkykkyk",
    "kk............kk",
    "kk............kk",
    "kk............kk",
    "kk............kk",
    "kk............kk",
    "kk............kk",
    "kk............kk",
    "kk............kk",
    "kk............kk",
    "kk............kk",
    "kk............kk",
    "kk.....tt.....kk",
    "kk.....tt.....kk",
])

grid('pedestal', [
    "................",
    "................",
    "................",
    "................",
    "................",
    "................",
    "................",
    "...kkkkkkkkkk...",
    "...khhhhhhhhk...",
    "...kGGGGGGGGk...",
    "....kGGGGGGk....",
    "....kgGGGGgk....",
    "....kgGGGGgk....",
    "...kGGGGGGGGk...",
    "...kggggggggk...",
    "...kkkkkkkkkk...",
])

grid('hatch', [  # šipka dolů: cesta do dalšího patra
    "kkkkkkkkkkkkkkkk",
    "kyykkyykkyykkyyk",
    "kykkkkkkkkkkkkyk",
    "kkkgggggggggkkkk",
    "kykgGGGGGGGGgkyk",
    "kykgGGGttGGGgkyk",
    "kkkgGGGttGGGgkkk",
    "kykgGGGttGGGgkyk",
    "kykgGGGttGGGgkyk",
    "kkkgGtttttttgkkk",
    "kykgGGttttGGgkyk",
    "kykgGGGttGGGgkyk",
    "kkkgggggggggkkkk",
    "kykkkkkkkkkkkkyk",
    "kyykkyykkyykkyyk",
    "kkkkkkkkkkkkkkkk",
])

# ---------- věci na zemi ----------
grid('pickup_battery', [
    "...kkkk...",
    "...khhk...",
    ".kkkkkkkk.",
    ".kTttttTk.",
    ".kTtwwtTk.",
    ".kTttttTk.",
    ".kTtwwtTk.",
    ".kTttttTk.",
    ".kTttttTk.",
    ".kTTTTTTk.",
    ".kkkkkkkk.",
    "..........",
])
grid('pickup_screw', [
    "..kkkk..",
    ".khhhhk.",
    "khGkkGhk",
    "khkGGkhk",
    "khkGGkhk",
    "khGkkGhk",
    ".khhhhk.",
    "..kkkk..",
])
grid('pickup_emp', [
    "...kkkk...",
    "..kPPPPk..",
    ".kPppypPk.",
    "kPppyyppPk",
    "kPpyyyypPk",
    "kPppyyppPk",
    "kPppypppPk",
    ".kPpypPPk.",
    "..kPPPPk..",
    "...kkkk...",
])

# ---------- předměty (16x16) ----------
grid('item_fan', [
    "................",
    "....kkkkkkkk....",
    "...kGGGGGGGGk...",
    "..kGkkhhhkkkGk..",
    ".kGkhhhkkkkkkGk.",
    ".kGkkhhkkkhhkGk.",
    ".kGkkkhttkhhkGk.",
    ".kGkkkttttkkkGk.",
    ".kGkkkttttkkkGk.",
    ".kGkhhkttkkkkGk.",
    ".kGhhkkkkhhkkGk.",
    ".kGkkkkkkhhhkGk.",
    "..kGkkkkkkhhGk..",
    "...kGGGGGGGGk...",
    "....kkkkkkkk....",
    "................",
])
grid('item_coil', [
    "................",
    "...kkk....kkk...",
    "...krk....kGk...",
    "...krk....kGk...",
    "..kkkkkkkkkkkk..",
    "..koooooooooOk..",
    "..kOOOOOOOOOOk..",
    "..koooooooooOk..",
    "..kOOOOOOOOOOk..",
    "..koooooooooOk..",
    "..kOOOOOOOOOOk..",
    "..koooooooooOk..",
    "..kkkkkkkkkkkk..",
    "...krk....kGk...",
    "...kkk....kkk...",
    "................",
])
grid('item_chip', [
    "................",
    "...h.h.h.h.h....",
    "...h.h.h.h.h....",
    "..kkkkkkkkkkk...",
    "hhkEEEEEEEEEkhh.",
    "..kEeeeeeeeEk...",
    "hhkEekkkkkeEkhh.",
    "..kEekrrrkeEk...",
    "hhkEekrrrkeEkhh.",
    "..kEekkkkkeEk...",
    "hhkEeeeeeeeEkhh.",
    "..kEEEEEEEEEk...",
    "..kkkkkkkkkkk...",
    "...h.h.h.h.h....",
    "...h.h.h.h.h....",
    "................",
])
grid('item_battery', [
    "................",
    "......kkkk......",
    "......khhk......",
    "...kkkkkkkkkk...",
    "...kTTTTTTTTk...",
    "...kTttttttTk...",
    "...kTttwwttTk...",
    "...kTttwwttTk...",
    "...kTwwwwwwTk...",
    "...kTwwwwwwTk...",
    "...kTttwwttTk...",
    "...kTttwwttTk...",
    "...kTttttttTk...",
    "...kTTTTTTTTk...",
    "...kkkkkkkkkk...",
    "................",
])
grid('item_relay', [
    "................",
    "..kkkkkkkkkkkk..",
    "..kGGGGGGGGGGk..",
    "..kGkkkkkkkkGk..",
    "..kGkkkkyykkGk..",
    "..kGkkkyykkkGk..",
    "..kGkkyykkkkGk..",
    "..kGkyyyyyykGk..",
    "..kGkkkkyykkGk..",
    "..kGkkkyykkkGk..",
    "..kGkkyykkkkGk..",
    "..kGkkkkkkkkGk..",
    "..kGGGGGGGGGGk..",
    "..kkkkkkkkkkkk..",
    "...kk......kk...",
    "................",
])

# ---------- HUD ----------
grid('hud_cell_full', [
    "..kkkk..",
    "kkkkkkkk",
    "kTttttTk",
    "kTtwwtTk",
    "kTttttTk",
    "kTtwwtTk",
    "kTttttTk",
    "kTTTTTTk",
    "kkkkkkkk",
    "........",
])
grid('hud_cell_empty', [
    "..kkkk..",
    "kkkkkkkk",
    "kgggggGk",
    "kg....Gk",
    "kg....Gk",
    "kg....Gk",
    "kg....Gk",
    "kGGGGGGk",
    "kkkkkkkk",
    "........",
])

# ikona hry: robot, 4x zvětšený, na tmavém pozadí
robot = Image.open(OUT / 'player.png')
icon = Image.new('RGBA', (64, 64), (16, 18, 26, 255))
icon.alpha_composite(robot.resize((64, 64), Image.NEAREST))
icon.save(OUT.parent.parent / 'icon.png')
print('obrázků:', len(list(OUT.glob('*.png'))))
