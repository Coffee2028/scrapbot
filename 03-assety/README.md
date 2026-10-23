# 03 – Assety

[← Zpět na hlavní stránku](../README.md)

**Stav:** prototypové assety pro verzi 0.1.

Všechny obrázky a zvuky v prototypu jsou vlastní. Nejsou stažené odjinud – vytvářejí je dva skripty v Pythonu ve složce [`nastroje/`](nastroje). Proto nejsou potřeba žádné licence třetích stran a assety spadají pod [MIT licenci](../LICENSE) projektu.

Hotové soubory leží přímo v projektu hry: [`04-hra/assets/`](../04-hra/assets).

## Paleta

Barvy podle [ideového plánu](../01-ideovy-plan/README.md#4-popis-audiovizuálu): rez a ocel opuštěné továrny, tmavé pozadí a neonově tyrkysová pro robota a důležité věci.

| Barva | HEX | Použití |
|---|---|---|
| neonová tyrkysová | `#19E3D1` | robot, jeho střely, články baterie |
| rezavě oranžová | `#D9622B` | nepřátelé, boss, okraj střel nepřátel |
| tmavá rez | `#8A3A1C` | stíny na nepřátelích |
| ocel | `#6B7280` | zdi, kovové části |
| světlá ocel | `#A6ADB8` | odlesky, šrouby |
| výstražná žlutá | `#FFC531` | střely nepřátel, výstražné pruhy na dveřích a poklopu |
| červená | `#E0303A` | oči bosse, kontrolky na dveřích a věžičce |
| fialová | `#8C5CE6` | EMP nálož |
| beton | `#282B33` | podlaha |
| pozadí | `#0E0F16` | okolí místnosti, menu |

## Grafika (`04-hra/assets/sprites/`)

Základní dlaždice má 16 × 16 px. Hra běží v rozlišení 384 × 216 px a zvětšuje se bez rozmazání (filtr *nearest*), aby pixely zůstaly ostré.

| Soubor | Velikost | Co to je |
|---|---|---|
| `player.png` | 16 × 16 | robot SCRAPBOT |
| `drone.png` | 16 × 16 | nepřítel – svářecí dron |
| `cart.png` | 16 × 16 | nepřítel – vozík |
| `turret.png` | 16 × 16 | nepřítel – věžička |
| `boss_forklift.png` | 32 × 32 | boss Kladivo (vysokozdvižný vozík) |
| `bullet_player.png`, `bullet_enemy.png` | 6 × 6 | střely robota a nepřátel |
| `floor.png`, `wall.png`, `crate.png` | 16 × 16 | podlaha, zeď, bedna |
| `door_open.png`, `door_closed.png` | 16 × 16 | dveře (kreslené pro horní stěnu, hra je otáčí) |
| `hatch.png` | 16 × 16 | poklop do dalšího patra |
| `pedestal.png` | 16 × 16 | podstavec pro předmět |
| `pickup_battery.png`, `pickup_screw.png`, `pickup_emp.png` | 8–12 px | věci na zemi |
| `item_fan.png`, `item_coil.png`, `item_chip.png`, `item_battery.png`, `item_relay.png` | 16 × 16 | ikony předmětů |
| `hud_cell_full.png`, `hud_cell_empty.png` | 8 × 10 | článek baterie v horní liště |
| `04-hra/icon.png` | 64 × 64 | ikona hry |

## Zvukové efekty (`04-hra/assets/sfx/`)

Krátké retro zvuky (16bitové mono WAV, 22 050 Hz) složené z obdélníkové vlny, jako na starých konzolích, a ze šumu.

| Soubor | Kdy zazní |
|---|---|
| `shoot.wav` | výstřel robota |
| `enemy_shoot.wav` | výstřel nepřítele |
| `hit.wav` | zásah nepřítele |
| `explode.wav` | zničení nepřítele |
| `hurt.wav` | zásah robota |
| `pickup.wav` | sebrání věci ze země |
| `item.wav` | sebrání předmětu |
| `door.wav` | otevření dveří |
| `emp.wav` | výbuch EMP nálože |
| `boss_charge.wav` | boss se chystá k nájezdu |
| `boss_die.wav` | zničení bosse |
| `blip.wav` | pohyb v menu |

## Jak assety znovu vygenerovat

Potřeba je Python 3 a knihovny Pillow a NumPy:

```
pip install pillow numpy
cd 03-assety/nastroje
python make_sprites.py ../../04-hra/assets/sprites
python make_sfx.py ../../04-hra/assets/sfx
```

Každý obrázek je v `make_sprites.py` zapsaný jako mřížka znaků a každý znak je jedna barva z palety (`k` = obrys, `t` = tyrkysová, `o` = rez …). Kdo změní znak, změní pixel. Po novém vygenerování si Godot obrázky při dalším otevření projektu sám znovu naimportuje.

## Co přijde později

- hudba (klidná ve skladu, rychlejší v souboji s bossem),
- animace (chůze robota, výbuchy jako sprity),
- dlaždice a nepřátelé pro další patra.
