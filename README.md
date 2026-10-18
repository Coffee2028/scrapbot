# SCRAPBOT

> Malý opravářský robot, továrna, která se vymkla kontrole, a cesta až do jejího jádra.
> Roguelike střílečka z pohledu shora v pixel artu.

| | |
|---|---|
| **Název** | SCRAPBOT |
| **Autor** | Jakub Steinz (Coffee2028) |
| **Rok** | 2026 |
| **Škola / předmět** | 4ITE PHR |
| **Žánr** | roguelike, bullet hell, střílečka z pohledu shora |
| **Engine** | Godot 4 (GDScript) |
| **Platforma** | Windows |
| **Stav projektu** | ideový plán |
| **Licence** | [MIT](LICENSE) |

## O hře

SCRAPBOT je 2D roguelike střílečka z pohledu shora inspirovaná hrou *The Binding of Isaac*. Hráč ovládá malého opravářského robota, který sestupuje patro po patře do továrny ovládnuté zbloudilou umělou inteligencí. Patra se při každém pokusu generují znovu, předměty se navzájem kombinují a po zničení robota začíná hráč od začátku.

Podrobný popis je v [ideovém plánu](01-ideovy-plan/README.md).

## Rozcestník

| # | Část projektu | Obsah | Stav |
|---|---|---|---|
| 01 | [Ideový plán](01-ideovy-plan/README.md) | název, úvodník, popis hry, audiovizuál, technologie, hypotézy | hotovo |
| 02 | [Game design](02-game-design/README.md) | předměty, nepřátelé, bossové, místnosti, vyvážení | připravuje se |
| 03 | [Assety](03-assety/README.md) | grafika, zvukové efekty, hudba | připravuje se |
| 04 | [Hra](04-hra/README.md) | projekt v Godotu, zdrojový kód | připravuje se |
| 05 | [Testování](05-testovani/README.md) | výsledky testů, ověření hypotéz | připravuje se |

### Kapitoly ideového plánu

1. [Formální název projektu](01-ideovy-plan/README.md#1-formální-název-projektu)
2. [Marketingový úvodník](01-ideovy-plan/README.md#2-marketingový-úvodník)
3. [Popis hry](01-ideovy-plan/README.md#3-popis-hry)
   - [Principy](01-ideovy-plan/README.md#principy)
   - [Funkčnost a možnosti](01-ideovy-plan/README.md#funkčnost-a-možnosti)
   - [Cíle hráče](01-ideovy-plan/README.md#cíle-hráče)
4. [Popis audiovizuálu](01-ideovy-plan/README.md#4-popis-audiovizuálu)
5. [Chystané použité technologie](01-ideovy-plan/README.md#5-chystané-použité-technologie)
6. [Hypotézy](01-ideovy-plan/README.md#6-hypotézy)

## Struktura repozitáře

```
scrapbot/
├── 01-ideovy-plan/   ideový plán hry
├── 02-game-design/   podrobný návrh herních mechanik
├── 03-assety/        grafika, zvuky a hudba
├── 04-hra/           projekt v Godotu 4
├── 05-testovani/     testování a ověření hypotéz
├── LICENSE
└── README.md
```

Každá fáze projektu má vlastní očíslovanou složku. Další část se přidá jako nová složka a nový řádek v rozcestníku.

## Licence

Projekt je zveřejněn pod licencí [MIT](LICENSE).
