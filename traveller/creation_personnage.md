# Traveller : création de personnage et formats de fiche

Règles de **Classic Traveller**, Livre 1 *Characters and Combat* (GDW, 1977,
édition révisée 1981). Puis deux formats de fiche : EDIFACT (échange) et
fichier plat à taille fixe (lu par COBOL). La traduction EDIFACT ↔ fichier
plat sera faite en Java avec StAEDI.

> **À vérifier.** Les tables ci-dessous (jets, modificateurs, compétences,
> gains de fin de service) sont reconstituées de mémoire, sans le livre
> sous les yeux. Avant de les coder, les comparer au Livre 1 : une valeur
> peut être fausse ou venir d'une autre édition.

Sommaire :

- [1. Déroulé](#1-déroulé)
- [2. Caractéristiques](#2-caractéristiques)
- [3. Services](#3-services)
- [4. Un terme de service](#4-un-terme-de-service)
- [5. Grades et compétences automatiques](#5-grades-et-compétences-automatiques)
- [6. Tables de compétences](#6-tables-de-compétences)
- [7. Liste des compétences](#7-liste-des-compétences)
- [8. Vieillissement](#8-vieillissement)
- [9. Fin de service](#9-fin-de-service)
- [10. Format EDIFACT](#10-format-edifact)
- [11. Format fichier plat à taille fixe](#11-format-fichier-plat-à-taille-fixe)
- [12. Correspondance EDIFACT ↔ fichier plat](#12-correspondance-edifact--fichier-plat)

Notations : **2D** = somme de deux dés à six faces ; **8+** = réussite si le
jet vaut 8 ou plus ; **MD** = modificateur de dé, ajouté au jet.

## 1. Déroulé

1. Tirer les six caractéristiques.
2. Choisir un service et tenter l'engagement. En cas d'échec : conscription
   (service tiré au sort).
3. Enchaîner les termes de 4 ans. À chaque terme : survie, commission,
   promotion, compétences, rengagement. Vieillissement à partir du 4e terme.
4. Fin de service : argent, objets, pension.
5. Âge de départ : 18 ans. Âge final : 18 + 4 × nombre de termes.

## 2. Caractéristiques

Six caractéristiques, chacune tirée sur **2D** (de 2 à 12) :

| Code | Nom          | Sens |
|------|--------------|------|
| STR  | Strength     | force |
| DEX  | Dexterity    | dextérité, coordination |
| END  | Endurance    | résistance |
| INT  | Intelligence | intelligence |
| EDU  | Education    | instruction |
| SOC  | Social Standing | rang social (11+ : noblesse) |

**UPP** (*Universal Personality Profile*) : les six valeurs écrites dans cet
ordre, un chiffre hexadécimal chacune (10 = A, 11 = B ... 15 = F).
Exemple : STR 7, DEX 8, END 7, INT 10, EDU 10, SOC 8 → `787AA8`.

Les modifications pendant la carrière (table de développement personnel,
vieillissement, gains de fin de service) changent ces valeurs. Maximum
usuel à la création : 15 (F).

## 3. Services

Six services. Un jet par case, MD cumulables.

|                      | Navy    | Marines | Army    | Scouts  | Merchants | Other  |
|----------------------|---------|---------|---------|---------|-----------|--------|
| **Engagement**       | 8+      | 9+      | 5+      | 7+      | 7+        | 3+     |
| MD +1 si             | INT 8+  | INT 8+  | DEX 6+  | INT 6+  | STR 7+    | —      |
| MD +2 si             | EDU 9+  | STR 8+  | END 5+  | STR 8+  | INT 6+    | —      |
| **Survie**           | 5+      | 6+      | 5+      | 7+      | 5+        | 5+     |
| MD +2 si             | INT 7+  | END 8+  | EDU 6+  | END 9+  | INT 7+    | INT 9+ |
| **Commission**       | 10+     | 9+      | 5+      | —       | 4+        | —      |
| MD +1 si             | SOC 9+  | EDU 7+  | END 7+  | —       | INT 9+    | —      |
| **Promotion**        | 8+      | 9+      | 6+      | —       | 10+       | —      |
| MD +1 si             | EDU 8+  | SOC 8+  | EDU 7+  | —       | INT 10+   | —      |
| **Rengagement**      | 6+      | 6+      | 7+      | 3+      | 4+        | 5+     |

« — » : impossible dans ce service (pas de grades chez les Scouts et dans
Other).

**Conscription** (engagement raté) : 1D → 1 Navy, 2 Marines, 3 Army,
4 Scouts, 5 Merchants, 6 Other. Un conscrit ne peut pas tenter la
commission pendant son premier terme.

## 4. Un terme de service

Un terme dure 4 ans. Dans l'ordre :

1. **Survie** (2D + MD). Échec : le personnage meurt, on recommence.
   *Règle optionnelle* : il est blessé et quitte le service à mi-terme
   (2 ans seulement), sans autre jet ce terme.
2. **Commission** (pas encore officier, service qui en a). Réussite :
   grade 1 et un jet de compétence de plus.
3. **Promotion** (officier seulement, une fois par terme, possible le terme
   même de la commission). Réussite : grade + 1 (max 6, 5 chez les
   Merchants) et un jet de compétence de plus.
4. **Compétences** : 2 jets au premier terme, 1 jet aux suivants. Les
   Scouts ont 2 jets à chaque terme. Plus les jets gagnés par commission et
   promotion. Chaque jet : choisir une des tables du service (section 6),
   lancer 1D.
5. **Vieillissement**, à partir de la fin du 4e terme (section 8).
6. **Rengagement** (2D, sans MD) :
   - 12 : rengagement **obligatoire** ;
   - réussite : le joueur choisit de rester ou de partir ;
   - échec : départ forcé ;
   - après 7 termes : rengagement seulement sur 12.

Départ volontaire possible à la fin de chaque terme. Pension à partir de
5 termes (section 9).

*Règle optionnelle* : total des niveaux de compétence limité à INT + EDU.

## 5. Grades et compétences automatiques

| Grade | Navy        | Marines         | Army        | Merchants    |
|-------|-------------|-----------------|-------------|--------------|
| 1     | Ensign      | Lieutenant      | Lieutenant  | 4th Officer  |
| 2     | Lieutenant  | Captain         | Captain     | 3rd Officer  |
| 3     | Lt Commander| Force Commander | Major       | 2nd Officer  |
| 4     | Commander   | Lt Colonel      | Lt Colonel  | 1st Officer  |
| 5     | Captain     | Colonel         | Colonel     | Captain      |
| 6     | Admiral     | Brigadier       | General     | —            |

Compétences et bonus automatiques :

| Service   | À l'engagement | Liés au grade |
|-----------|----------------|---------------|
| Navy      | —              | Captain : SOC +1 ; Admiral : SOC +1 |
| Marines   | Cutlass-1      | Lieutenant : Revolver-1 |
| Army      | Rifle-1        | Lieutenant : SMG-1 |
| Scouts    | Pilot-1        | — |
| Merchants | —              | 1st Officer : Pilot-1 |
| Other     | —              | — |

## 6. Tables de compétences

Quatre tables par service, 1D chacune :

- **PD** : développement personnel (caractéristiques) ;
- **SS** : compétences de service ;
- **AE** : éducation avancée ;
- **AE2** : éducation avancée supérieure, seulement si **EDU 8+**.

Une compétence déjà possédée monte d'un niveau (Pilot-1 → Pilot-2).

### Navy

| 1D | PD     | SS          | AE         | AE2 (EDU 8+) |
|----|--------|-------------|------------|--------------|
| 1  | +1 STR | Ship's Boat | Vacc Suit  | Medical      |
| 2  | +1 DEX | Vacc Suit   | Mechanical | Navigation   |
| 3  | +1 END | Fwd Obsvr   | Electronic | Engineering  |
| 4  | +1 INT | Gunnery     | Engineering| Computer     |
| 5  | +1 EDU | Blade Cbt   | Gunnery    | Pilot        |
| 6  | +1 SOC | Gun Cbt     | Jack-o-T   | Admin        |

### Marines

| 1D | PD        | SS        | AE         | AE2 (EDU 8+) |
|----|-----------|-----------|------------|--------------|
| 1  | +1 STR    | Vehicle   | Vehicle    | Medical      |
| 2  | +1 DEX    | Vacc Suit | Mechanical | Tactics      |
| 3  | +1 END    | Blade Cbt | Electronic | Tactics      |
| 4  | Gambling  | Gun Cbt   | Tactics    | Computer     |
| 5  | Brawling  | Blade Cbt | Blade Cbt  | Leader       |
| 6  | Blade Cbt | Gun Cbt   | Gun Cbt    | Admin        |

### Army

| 1D | PD       | SS        | AE         | AE2 (EDU 8+) |
|----|----------|-----------|------------|--------------|
| 1  | +1 STR   | Vehicle   | Vehicle    | Medical      |
| 2  | +1 DEX   | Air/Raft  | Mechanical | Tactics      |
| 3  | +1 END   | Gun Cbt   | Electronic | Tactics      |
| 4  | Gambling | Fwd Obsvr | Tactics    | Computer     |
| 5  | +1 EDU   | Blade Cbt | Blade Cbt  | Leader       |
| 6  | Brawling | Gun Cbt   | Gun Cbt    | Admin        |

### Scouts

| 1D | PD      | SS         | AE         | AE2 (EDU 8+) |
|----|---------|------------|------------|--------------|
| 1  | +1 STR  | Vehicle    | Vehicle    | Medical      |
| 2  | +1 DEX  | Vacc Suit  | Mechanical | Navigation   |
| 3  | +1 END  | Mechanical | Electronic | Engineering  |
| 4  | +1 INT  | Navigation | Jack-o-T   | Computer     |
| 5  | +1 EDU  | Electronic | Gunnery    | Pilot        |
| 6  | Gun Cbt | Jack-o-T   | Medical    | Jack-o-T     |

### Merchants

| 1D | PD        | SS        | AE         | AE2 (EDU 8+) |
|----|-----------|-----------|------------|--------------|
| 1  | +1 STR    | Vehicle   | Streetwise | Medical      |
| 2  | +1 DEX    | Vacc Suit | Mechanical | Navigation   |
| 3  | +1 END    | Jack-o-T  | Electronic | Engineering  |
| 4  | +1 STR    | Steward   | Navigation | Computer     |
| 5  | Blade Cbt | Electronic| Gunnery    | Pilot        |
| 6  | Bribery   | Gun Cbt   | Medical    | Admin        |

### Other

| 1D | PD        | SS        | AE         | AE2 (EDU 8+) |
|----|-----------|-----------|------------|--------------|
| 1  | +1 STR    | Vehicle   | Streetwise | Medical      |
| 2  | +1 DEX    | Gambling  | Mechanical | Forgery      |
| 3  | +1 END    | Brawling  | Electronic | Electronic   |
| 4  | Blade Cbt | Bribery   | Gambling   | Computer     |
| 5  | Brawling  | Blade Cbt | Brawling   | Streetwise   |
| 6  | -1 SOC    | Gun Cbt   | Forgery    | Jack-o-T     |

## 7. Liste des compétences

| Compétence (code fiche) | Sens |
|---|---|
| ADMIN          | administration, bureaucratie |
| AIR/RAFT       | véhicule antigrav léger |
| ATV            | véhicule tout-terrain |
| BLADE COMBAT   | armes blanches (*cascade*, voir plus bas) |
| BRAWLING       | bagarre |
| BRIBERY        | corruption |
| COMPUTER       | informatique |
| ELECTRONIC     | électronique |
| ENGINEERING    | moteurs de vaisseau |
| FORGERY        | contrefaçon |
| FWD OBSERVER   | observation avancée, guidage de tir |
| GAMBLING       | jeu ; MD +1 sur la table d'argent |
| GUN COMBAT     | armes à feu (*cascade*) |
| GUNNERY        | tourelles de vaisseau |
| JACK-O-T       | touche-à-tout |
| LEADER         | commandement |
| MECHANICAL     | mécanique |
| MEDICAL        | médecine |
| NAVIGATION     | navigation spatiale |
| PILOT          | pilotage de vaisseau |
| SHIPS BOAT     | petites embarcations spatiales |
| STEWARD        | service à bord |
| STREETWISE     | milieux interlopes |
| TACTICS        | tactique |
| VACC SUIT      | combinaison spatiale |
| VEHICLE        | véhicules (*cascade*) |

**Compétences en cascade** : le résultat désigne une famille, le joueur
choisit une spécialité.

- **BLADE COMBAT** : Dagger, Blade, Foil, Sword, Cutlass, Broadsword,
  Bayonet, Spear, Halberd, Pike, Cudgel.
- **GUN COMBAT** : Body Pistol, Auto Pistol, Revolver, Carbine, Rifle,
  Auto Rifle, Shotgun, SMG, Laser Carbine, Laser Rifle.
- **VEHICLE** : Air/Raft, ATV, Aircraft (Helicopter, Propeller, Jet),
  Watercraft (Small, Large, Hovercraft, Submersible).

## 8. Vieillissement

À la fin du 4e terme (34 ans) puis de chaque terme. Un jet 2D par ligne :
si le jet est **inférieur ou égal** au seuil, la caractéristique baisse.

| Termes (âge)        | STR       | DEX       | END       | INT       |
|---------------------|-----------|-----------|-----------|-----------|
| 4 à 7 (34 à 46)     | -1 si 8-  | -1 si 7-  | -1 si 8-  | —         |
| 8 à 11 (50 à 62)    | -1 si 9-  | -1 si 8-  | -1 si 9-  | —         |
| 12 et + (66 et +)   | -2 si 9-  | -2 si 9-  | -2 si 9-  | -1 si 9-  |

Une caractéristique tombée à 0 : crise de vieillissement. Jet 8+ pour
survivre ; elle remonte alors à 1.

## 9. Fin de service

**Nombre de jets** : 1 par terme, plus 1 si grade 1-2, plus 2 si grade
3-4, plus 3 si grade 5-6. Chaque jet se fait sur la table d'argent **ou**
sur celle des gains, au choix ; **3 jets d'argent au plus** en tout.

MD : +1 sur l'argent si GAMBLING ; +1 sur les gains si grade 5 ou 6.
Les tables vont jusqu'à 7 (1D + MD).

### Argent (Cr, crédits)

| 1D | Navy   | Marines | Army   | Scouts | Merchants | Other   |
|----|--------|---------|--------|--------|-----------|---------|
| 1  | 1 000  | 2 000   | 2 000  | 20 000 | 1 000     | 1 000   |
| 2  | 5 000  | 5 000   | 5 000  | 20 000 | 5 000     | 5 000   |
| 3  | 5 000  | 5 000   | 10 000 | 30 000 | 10 000    | 10 000  |
| 4  | 10 000 | 10 000  | 10 000 | 30 000 | 20 000    | 10 000  |
| 5  | 20 000 | 20 000  | 10 000 | 50 000 | 20 000    | 10 000  |
| 6  | 50 000 | 30 000  | 20 000 | 50 000 | 40 000    | 50 000  |
| 7  | 50 000 | 40 000  | 30 000 | 50 000 | 40 000    | 100 000 |

### Gains

| 1D | Navy        | Marines     | Army        | Scouts      | Merchants   | Other       |
|----|-------------|-------------|-------------|-------------|-------------|-------------|
| 1  | Low Passage | Low Passage | Low Passage | Low Passage | Low Passage | Low Passage |
| 2  | +1 INT      | +2 INT      | +1 INT      | +2 INT      | +1 INT      | +1 INT      |
| 3  | +2 EDU      | +1 EDU      | +2 EDU      | +2 EDU      | +1 EDU      | +1 EDU      |
| 4  | Blade       | Blade       | Gun         | Blade       | Gun         | Gun         |
| 5  | Travellers' | Travellers' | High Passage| Gun         | Blade       | High Passage|
| 6  | High Passage| High Passage| Mid Passage | Scout Ship  | Low Passage | —           |
| 7  | +2 SOC      | +2 SOC      | +1 SOC      | —           | Free Trader | —           |

- **Low / Mid / High Passage** : billet de voyage spatial (3 classes).
- **Blade / Gun** : une arme ; reçue une deuxième fois, elle donne plutôt
  un niveau dans la compétence correspondante.
- **Travellers'** : adhésion à la Travellers' Aid Society.
- **Scout Ship**, **Free Trader** : un vaisseau.

### Pension

À partir de 5 termes (pas pour les Scouts), par an : 4 000 Cr à 5 termes,
6 000 à 6, 8 000 à 7, 10 000 à 8, puis +2 000 par terme.

## 10. Format EDIFACT

### Choix

- Syntaxe UN/EDIFACT version 3, jeu de caractères **UNOA** : majuscules,
  chiffres, espace et ponctuation simple. **Pas de minuscules ni
  d'accents** (cohérent avec le COBOL de TK4-).
- Message **privé** `TRVCHR` (version 1, release 0, agence `ZZ` =
  accord mutuel). Il n'existe pas dans le répertoire UN.
- Segments standard pour l'enveloppe et l'en-tête (`UNA`, `UNB`, `UNH`,
  `BGM`, `DTM`, `UNT`, `UNZ`). Segments **privés** pour le contenu, tous
  préfixés `Z` pour ne jamais entrer en collision avec un segment UN.
- **Un message `UNH`…`UNT` par personnage.** Un échange `UNB`…`UNZ` en
  contient autant qu'on veut.
- Valeurs numériques sans zéros de tête ni signe (`7`, `15000`).

Séparateurs (déclarés par `UNA`) :

| Caractère | Rôle |
|-----------|------|
| `:`       | séparateur de composants |
| `+`       | séparateur d'éléments |
| `.`       | marque décimale |
| `?`       | caractère d'échappement : `?+`, `?:`, `?'`, `??` |
| `'`       | fin de segment |

Un nom comme `O'BRIEN` s'écrit `O?'BRIEN`.

### Segments du message TRVCHR

| Segment | Rep. | Éléments | Exemple |
|---------|------|----------|---------|
| `UNH` | 1 | numéro de message ; `TRVCHR:1:0:ZZ` | `UNH+1+TRVCHR:1:0:ZZ'` |
| `BGM` | 1 | code document `ZCH` ; identifiant du personnage (6 chiffres) ; fonction `9` = original | `BGM+ZCH+000001+9'` |
| `DTM` | 1 | `137` (date du document) : AAAAMMJJ : format `102` | `DTM+137:20261006:102'` |
| `ZID` | 1 | nom ; prénom ; âge | `ZID+DUPONT+JEAN+30'` |
| `ZCA` | 6 | code caractéristique ; valeur (0 à 15) | `ZCA+STR+7'` |
| `ZUP` | 1 | UPP (6 caractères hexadécimaux) | `ZUP+787AA8'` |
| `ZCR` | 1 | service ; entrée (`V` volontaire, `C` conscrit) ; termes ; grade (0 à 6) ; titre ; statut | `ZCR+NAV+V+3+3+LT COMMANDER+Q'` |
| `ZTM` | 0..12 | n° de terme ; survie ; commission ; promotion ; rengagement | `ZTM+1+O+O+N+O'` |
| `ZSK` | 0..18 | compétence`:`spécialité (spécialité facultative) ; niveau | `ZSK+BLADE COMBAT:CUTLASS+1'` |
| `ZBN` | 0..10 | type (`OBJ` objet, `CAR` caractéristique, `ADH` adhésion) ; gain`:`spécialité ; quantité ou bonus | `ZBN+OBJ+BLADE:DAGGER+1'` |
| `ZMO` | 2 | `CSH` argent ou `PEN` pension annuelle ; montant en Cr | `ZMO+CSH+15000'` |
| `UNT` | 1 | nombre de segments **de `UNH` à `UNT` inclus** ; numéro de message | `UNT+27+1'` |

Codes :

- **Services** : `NAV` Navy, `MAR` Marines, `ARM` Army, `SCO` Scouts,
  `MER` Merchants, `OTH` Other.
- **Statut** : `Q` a quitté le service, `R` retraité (pension), `M` mort
  pendant la création.
- **Historique `ZTM`** : `O` oui, `N` non, `-` sans objet (pas de jet).
- **Compétences** : codes de la section 7.

Les répétitions maximales (12 termes, 18 compétences, 10 gains) sont
celles du fichier plat : un message qui les dépasse ne peut pas être
converti.

### Exemple

Deux personnages dans un même échange
(`exemples/personnages.edi`) :

```
UNA:+.? '
UNB+UNOA:3+TRAVELLER:ZZ+COBOL:ZZ+261006:2300+000001'
UNH+1+TRVCHR:1:0:ZZ'
BGM+ZCH+000001+9'
DTM+137:20261006:102'
ZID+DUPONT+JEAN+30'
ZCA+STR+7'
ZCA+DEX+8'
ZCA+END+7'
ZCA+INT+10'
ZCA+EDU+10'
ZCA+SOC+8'
ZUP+787AA8'
ZCR+NAV+V+3+3+LT COMMANDER+Q'
ZTM+1+O+O+N+O'
ZTM+2+O+-+O+O'
ZTM+3+O+-+O+N'
ZSK+VACC SUIT+1'
ZSK+SHIPS BOAT+1'
ZSK+GUNNERY+1'
ZSK+ENGINEERING+1'
ZSK+PILOT+1'
ZSK+COMPUTER+1'
ZBN+OBJ+LOW PASSAGE+1'
ZBN+OBJ+BLADE:DAGGER+1'
ZBN+CAR+INT+1'
ZMO+CSH+15000'
ZMO+PEN+0'
UNT+27+1'
UNH+2+TRVCHR:1:0:ZZ'
BGM+ZCH+000002+9'
DTM+137:20261006:102'
ZID+MARTIN+CLAIRE+26'
ZCA+STR+6'
ZCA+DEX+10'
ZCA+END+8'
ZCA+INT+8'
ZCA+EDU+9'
ZCA+SOC+5'
ZUP+6A8895'
ZCR+SCO+V+2+0++Q'
ZTM+1+O+-+-+O'
ZTM+2+O+-+-+N'
ZSK+PILOT+1'
ZSK+VACC SUIT+1'
ZSK+NAVIGATION+1'
ZSK+MECHANICAL+1'
ZBN+CAR+EDU+2'
ZMO+CSH+20000'
ZMO+PEN+0'
UNT+22+2'
UNZ+2+000001'
```

Lecture du premier personnage : Jean Dupont, Navy volontaire, 3 termes,
commissionné au 1er terme, promu aux 2e et 3e (grade 3, Lt Commander),
rengagement raté au 3e terme. 30 ans. 7 jets de compétence (2 + 1 + 1, plus
1 commission et 2 promotions) : six compétences et +1 END. 5 jets de fin de
service (3 termes + 2 pour le grade 3) : 15 000 Cr (2 jets), Low Passage,
une dague, +1 INT.

Les retours à la ligne après chaque `'` servent à la lecture ; la norme ne
les prévoit pas. Vérifier que StAEDI les accepte, sinon écrire l'échange
sur une seule ligne.

StAEDI connaît l'enveloppe (`UNB`, `UNH`...) mais pas le message privé
`TRVCHR` : pour valider son contenu, il faudra lui fournir un schéma du
message.

## 11. Format fichier plat à taille fixe

### Choix

- **Un enregistrement par personnage**, longueur fixe **1000 octets**,
  sans séparateur de champ. Sur MVS : dataset `RECFM=FB`, `LRECL=1000`.
- Tous les champs en **texte** (`DISPLAY`) : le fichier reste lisible et
  modifiable dans un éditeur, et se transfère en ASCII/EBCDIC sans
  conversion de nombres. Pas de binaire ni de décimal condensé.
- Numériques : cadrés à droite, complétés par des zéros, sans signe.
- Alphanumériques : cadrés à gauche, complétés par des espaces,
  majuscules ASCII.
- Tables à nombre fixe d'entrées (`OCCURS`), précédées d'un compteur. Les
  entrées inutilisées : espaces, niveau ou quantité à 0.
- `FILLER` de 42 octets en fin : place pour de futurs champs sans changer
  la longueur.

1000 octets par fiche : une table de 1000 fiches en mémoire ferait 1 Mo,
au-delà de la limite mesurée du compilateur de TK4- (voir
`../character/Note.md`). Lire le fichier fiche par fiche.

### Description

| Position | Long. | Champ COBOL        | PIC      | Contenu |
|----------|-------|--------------------|----------|---------|
| 1        | 6     | `CHR-ID`           | 9(6)     | identifiant |
| 7        | 24    | `CHR-NOM`          | X(24)    | nom |
| 31       | 24    | `CHR-PRENOM`       | X(24)    | prénom |
| 55       | 2     | `CHR-AGE`          | 9(2)     | âge |
| 57       | 2     | `CHR-STR`          | 9(2)     | caractéristiques, 0 à 15 |
| 59       | 2     | `CHR-DEX`          | 9(2)     | |
| 61       | 2     | `CHR-END`          | 9(2)     | |
| 63       | 2     | `CHR-INT`          | 9(2)     | |
| 65       | 2     | `CHR-EDU`          | 9(2)     | |
| 67       | 2     | `CHR-SOC`          | 9(2)     | |
| 69       | 6     | `CHR-UPP`          | X(6)     | UPP hexadécimal |
| 75       | 3     | `CHR-SERVICE`      | X(3)     | `NAV` `MAR` `ARM` `SCO` `MER` `OTH` |
| 78       | 1     | `CHR-ENTREE`       | X        | `V` volontaire, `C` conscrit |
| 79       | 2     | `CHR-TERMES`       | 9(2)     | nombre de termes |
| 81       | 1     | `CHR-RANG`         | 9        | grade, 0 à 6 |
| 82       | 16    | `CHR-TITRE`        | X(16)    | titre du grade |
| 98       | 1     | `CHR-STATUT`       | X        | `Q`, `R`, `M` |
| 99       | 8     | `CHR-CASH`         | 9(8)     | argent (Cr) |
| 107      | 6     | `CHR-PENSION`      | 9(6)     | pension annuelle (Cr) |
| 113      | 8     | `CHR-DATE`         | 9(8)     | date de création AAAAMMJJ |
| 121      | 2     | `CHR-NB-COMP`      | 9(2)     | compétences remplies, 0 à 18 |
| 123      | 486   | `CHR-COMP`         | 18 × 27  | compétences |
|          | 14    | ↳ `CHR-COMP-NOM`   | X(14)    | code compétence (section 7) |
|          | 12    | ↳ `CHR-COMP-SPEC`  | X(12)    | spécialité (cascade) ou espaces |
|          | 1     | ↳ `CHR-COMP-NIV`   | 9        | niveau |
| 609      | 2     | `CHR-NB-AV`        | 9(2)     | gains remplis, 0 à 10 |
| 611      | 300   | `CHR-AV`           | 10 × 30  | gains de fin de service |
|          | 3     | ↳ `CHR-AV-TYPE`    | X(3)     | `OBJ`, `CAR`, `ADH` |
|          | 14    | ↳ `CHR-AV-NOM`     | X(14)    | objet ou caractéristique |
|          | 12    | ↳ `CHR-AV-SPEC`    | X(12)    | précision (`DAGGER`...) |
|          | 1     | ↳ `CHR-AV-QTE`     | 9        | quantité ou bonus |
| 911      | 48    | `CHR-HIST`         | 12 × 4   | historique, un groupe par terme |
|          | 1     | ↳ `CHR-HIST-SURVIE`| X        | `O`, `N` |
|          | 1     | ↳ `CHR-HIST-COMM`  | X        | `O`, `N`, `-` |
|          | 1     | ↳ `CHR-HIST-PROMO` | X        | `O`, `N`, `-` |
|          | 1     | ↳ `CHR-HIST-RENG`  | X        | `O`, `N` |
| 959      | 42    | `FILLER`           | X(42)    | réservé |

Total : 1000.

### Description COBOL (copybook)

```cobol
       01  CHR-ENREG.
           05  CHR-ID                PIC 9(6).
           05  CHR-NOM               PIC X(24).
           05  CHR-PRENOM            PIC X(24).
           05  CHR-AGE               PIC 9(2).
           05  CHR-CARACS.
               10  CHR-STR           PIC 9(2).
               10  CHR-DEX           PIC 9(2).
               10  CHR-END           PIC 9(2).
               10  CHR-INT           PIC 9(2).
               10  CHR-EDU           PIC 9(2).
               10  CHR-SOC           PIC 9(2).
           05  CHR-UPP               PIC X(6).
           05  CHR-SERVICE           PIC X(3).
           05  CHR-ENTREE            PIC X.
           05  CHR-TERMES            PIC 9(2).
           05  CHR-RANG              PIC 9.
           05  CHR-TITRE             PIC X(16).
           05  CHR-STATUT            PIC X.
           05  CHR-CASH              PIC 9(8).
           05  CHR-PENSION           PIC 9(6).
           05  CHR-DATE              PIC 9(8).
           05  CHR-NB-COMP           PIC 9(2).
           05  CHR-COMP OCCURS 18 TIMES.
               10  CHR-COMP-NOM      PIC X(14).
               10  CHR-COMP-SPEC     PIC X(12).
               10  CHR-COMP-NIV      PIC 9.
           05  CHR-NB-AV             PIC 9(2).
           05  CHR-AV OCCURS 10 TIMES.
               10  CHR-AV-TYPE       PIC X(3).
               10  CHR-AV-NOM        PIC X(14).
               10  CHR-AV-SPEC       PIC X(12).
               10  CHR-AV-QTE        PIC 9.
           05  CHR-HIST OCCURS 12 TIMES.
               10  CHR-HIST-SURVIE   PIC X.
               10  CHR-HIST-COMM     PIC X.
               10  CHR-HIST-PROMO    PIC X.
               10  CHR-HIST-RENG     PIC X.
           05  FILLER                PIC X(42).
```

Vérifié sur TK4- (compilation avec `PARM.COB='LOAD,DMAP,...'`) : RC 0000,
la carte mémoire donne `CHR-ENREG DS 0CL1000` (1000 octets) et le `FILLER`
à l'offset `3BE` (958), soit la position 959.

### Exemple

`exemples/personnages.dat` : les deux personnages de l'exemple EDIFACT, une
ligne de 1000 caractères chacun. Début des lignes (130 premiers
caractères) :

```
000001DUPONT                  JEAN                    30070807101008787AA8NAVV033LT COMMANDER    Q000150000000002026100606VACC SUI
000002MARTIN                  CLAIRE                  260610080809056A8895SCOV020                Q000200000000002026100604PILOT
```

Découpage de la première :

```
000001 DUPONT(24) JEAN(24) 30 07 08 07 10 10 08 787AA8 NAV V 03 3 LT COMMANDER(16) Q 00015000 000000 20261006 06 VACC SUIT...
```

## 12. Correspondance EDIFACT ↔ fichier plat

| EDIFACT | Fichier plat | Conversion |
|---|---|---|
| `BGM` élément 2 | `CHR-ID` | zéros à gauche sur 6 |
| `DTM+137` composant 2 | `CHR-DATE` | tel quel |
| `ZID` éléments 1, 2, 3 | `CHR-NOM`, `CHR-PRENOM`, `CHR-AGE` | échappements `?` retirés ; espaces / zéros |
| `ZCA+STR` ... `ZCA+SOC` | `CHR-STR` ... `CHR-SOC` | par code, quel que soit l'ordre des segments |
| `ZUP` | `CHR-UPP` | doit correspondre aux six `ZCA` |
| `ZCR` éléments 1 à 6 | `CHR-SERVICE` ... `CHR-STATUT` | titre vide → espaces |
| `ZTM` (n) | `CHR-HIST` (n) | le n° de terme donne l'indice |
| `ZSK` (dans l'ordre) | `CHR-COMP` (1..18), `CHR-NB-COMP` | composant 2 absent → spécialité à espaces |
| `ZBN` (dans l'ordre) | `CHR-AV` (1..10), `CHR-NB-AV` | idem |
| `ZMO+CSH` / `ZMO+PEN` | `CHR-CASH` / `CHR-PENSION` | zéros à gauche |
| un message `UNH`…`UNT` | un enregistrement | ordre des messages = ordre des lignes |

Règles de rejet suggérées (dans les deux sens) :

- champ trop long pour la zone (nom > 24, compétence > 14...) ;
- plus de 18 compétences, 10 gains ou 12 termes ;
- caractère hors UNOA (minuscule, accent) ;
- `UPP` incohérent avec les caractéristiques ;
- dans l'EDIFACT : `UNT` dont le compte ne correspond pas, `UNZ` dont le
  nombre de messages ne correspond pas.
