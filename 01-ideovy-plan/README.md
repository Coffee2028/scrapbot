# Ideový plán – SCRAPBOT

[← Zpět na hlavní stránku](../README.md)

---

## 1. Formální název projektu

**SCRAPBOT** (pracovní podtitul: *Cesta do jádra*)

---

## 2. Marketingový úvodník

Továrna se zbláznila. Stroje, které kdysi poslušně vyráběly, se vzbouřily a ovládla je zbloudilá umělá inteligence. Jediný, kdo zůstal v pořádku, je malý opravářský robot **SCRAPBOT** – vyzbrojený nýtovačkou, hrstí šroubů a jednou baterií.

Vydej se dolů, patro po patře, až k jádru továrny a vypni ho dřív, než bude pozdě. Každý sestup je jiný: místnosti se pokaždé poskládají znovu, vylepšení se kombinují nečekanými způsoby a jedna chyba znamená začít od začátku. Najdeš turbo ventilátor, přimontuješ magnetickou cívku, nebo riskneš podivný čip z koše? Zjisti, jak daleko se dokážeš probojovat tentokrát.

---

## 3. Popis hry

SCRAPBOT je 2D roguelike střílečka z pohledu shora, inspirovaná hrou *The Binding of Isaac*.

### Principy

- **Roguelike** – každý pokus (run) začíná od nuly. Když je robot zničen, hráč začíná znovu od prvního patra. Odemčené předměty a postavy mu ale zůstávají.
- **Náhodně generovaná patra** – každé patro se skládá z místností propojených dveřmi a jeho rozložení se při každém pokusu mění.
- **Bullet hell z pohledu shora** – pohyb do osmi směrů a střelba do čtyř směrů nezávisle na pohybu. Nepřátelé zaplňují obrazovku střelami, kterým je potřeba uhýbat.
- **Kombinace předmětů** – vylepšení se sčítají a navzájem ovlivňují, takže z každého pokusu vznikne jiný styl hraní.

### Funkčnost a možnosti

**Ovládání**

| Klávesa | Akce |
|---|---|
| W A S D | pohyb |
| šipky | střelba |
| E | EMP nálož |
| mezerník | použití aktivního předmětu |

Hra bude podporovat i herní ovladač (gamepad).

**Typy místností**

- běžná místnost – boj s nepřáteli, dveře se otevřou po vyčištění,
- pokladová místnost – jeden předmět zdarma,
- obchod – nákup předmětů za šrouby,
- zamčená místnost – otevírá se přístupovou kartou,
- místnost s výzvou – vlny nepřátel výměnou za odměnu,
- místnost s bossem – na konci každého patra.

**Zdroje**

| Ve hře | Funkce |
|---|---|
| články baterie | životy |
| šrouby | peníze do obchodu |
| přístupové karty | klíče k zamčeným místnostem a truhlám |
| EMP nálože | bomby – ničí překážky a zraňují nepřátele |

**Předměty (příklady)**

- *Turbo ventilátor* – rychlejší střelba,
- *Magnetická cívka* – střely se stáčejí k nepřátelům,
- *Přetaktovaný čip* – vyšší poškození, ale robot se přehřívá,
- *Záložní baterie* – jeden článek baterie navíc,
- *Zaseknuté relé* – každý výstřel má náhodný efekt.

**Nepřátelé a patra**

Každé patro má vlastní typy nepřátel s jinými vzorci střelby (svářecí drony, pásové vozíky, rotující věžičky, zbloudilé robotické vysavače…) a vlastního bosse.

| Patro | Prostředí | Boss |
|---|---|---|
| 1 | Sklad | vysokozdvižný vozík „Kladivo“ |
| 2 | Lakovna | lakovací robotické rameno |
| 3 | Slévárna | hydraulický lis |
| 4 | Jádro | zbloudilá umělá inteligence |

**Rozsah první verze**

První hratelná verze bude obsahovat 2 patra, 5 typů nepřátel, 15 předmětů a 2 bosse. Další patra a obsah přibudou v dalších verzích.

### Cíle hráče

- **Krátkodobý cíl** – vyčistit místnost, přežít a najít užitečné předměty.
- **Střednědobý cíl** – porazit bosse patra a sestoupit níž.
- **Hlavní cíl** – dostat se až k jádru továrny a vypnout zbloudilou umělou inteligenci.
- **Dlouhodobý cíl** – odemykat nové předměty a další roboty s jinými schopnostmi a překonávat vlastní rekordy (nejhlubší patro, nejrychlejší průchod).

---

## 4. Popis audiovizuálu

### Grafika

- Pixel art – postavy a předměty ve velikosti 16 × 16 a 32 × 32 pixelů, pohled shora.
- Omezená barevná paleta: rezavě oranžová, ocelově šedá a tmavé pozadí. Robot a důležité předměty jsou neonově tyrkysové, aby byl hráč vždy dobře vidět.
- Každé patro má vlastní barevné ladění: sklad hnědé a dřevěné tóny, lakovna barevné skvrny, slévárna žhavá oranžová, jádro studená modrá.

### Animace a efekty

- jiskry a částice při zásahu,
- otřes obrazovky při výbuchu,
- záblesk robota při poškození,
- krátké zpomalení času při poražení bosse.

### Zvuk a hudba

- Chiptune hudba s industriálními prvky (kovové údery, rytmus strojů). Každé patro má vlastní motiv, souboje s bossy rychlejší a dramatičtější skladbu.
- Retro zvukové efekty pro střelbu, zásahy, sbírání předmětů a otevírání dveří.
- Zvuky prostředí – bzučení strojů, syčení páry, vzdálené údery lisů.

### Uživatelské rozhraní

- Minimalistické rozhraní: baterie vlevo nahoře, pod nimi šrouby, karty a nálože, minimapa patra vpravo nahoře.
- Písmo ve stylu bodového (dot-matrix) displeje, které ladí s robotickým tématem.

---

## 5. Chystané použité technologie

| Oblast | Nástroj | Proč |
|---|---|---|
| Herní engine | **Godot 4** | zdarma, open-source, výborná podpora 2D her |
| Programování | **GDScript** | jednoduchý jazyk podobný Pythonu, přímo v Godotu |
| Pixel art | **Pixelorama** / **LibreSprite** | zdarma, určené pro pixel art a animace |
| Zvukové efekty | **jsfxr** | generátor retro zvuků v prohlížeči |
| Hudba | **BeepBox** | tvorba chiptune hudby v prohlížeči |
| Úprava zvuku | **Audacity** | stříhání a úprava zvuků |
| Správa verzí | **Git, GitHub, VS Code** | historie změn, zálohy a vydávání verzí |
| Vydání hry | **export z Godotu pro Windows**, **GitHub Releases** | hotová hra ke stažení jako .exe |

---

## 6. Hypotézy

### Hypotéza 1: Hráči se budou chtít vracet

**Předpoklad:** Hra bude mít efekt „ještě jeden pokus“. Hráči po prohře budou chtít pokračovat a během jednoho hraní odehrají v průměru **alespoň 3 pokusy**.

**Ověření:** Hra bude počítat odehrané pokusy za jedno spuštění. Testeři (spolužáci a kamarádi) navíc vyplní krátký dotazník. Hypotéza se potvrdí, pokud bude průměr alespoň 3 pokusy.

### Hypotéza 2: Obtížnost bude dobře nastavená

**Předpoklad:** Nový hráč porazí bosse prvního patra **nejpozději ve 3. pokusu** – hra tedy nebude příliš snadná ani frustrující.

**Ověření:** Hra zaznamená, ve kterém pokusu hráč bosse porazil, a výsledky doplní pozorování testerů. Hypotéza se potvrdí, pokud to zvládne alespoň **polovina testerů**. Pokud ne, upravím obtížnost (životy nepřátel, množství a rychlost střel).
