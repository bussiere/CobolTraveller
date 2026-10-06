# Notes : fiche personnage et générateur aléatoire

Cible : MVS 3.8j TK4- dans le conteneur `mainframe-tk4`, compilateur IBM ANS
COBOL `IKFCBL00` (1972). Envoi et lancement avec `powe`.

## Utilisation

```bash
cd ~/Workspace/CustomCobol/CobolTraveller
./upload_character.sh               # dépôt (+ compilation des libs si besoin)
./upload_character.sh --run         # idem, puis exécution de CHARV1
./upload_character.sh --force-libs  # recompile toutes les libs même sans changement
```

Deux listes en tête du script :

- `LIBS` (ex. `lib/randomGenerator:RANDGEN`) : sous-programmes, compilés
  dans `HERC01.TRAVEL.LOAD` **seulement si besoin** (voir ci-dessous) ;
- `PROGRAMMES` (ex. `character/characterV1:CHARV1`) : **toujours** renvoyés.
  Leur JCL les recompile et les relie à chaque soumission.

Ajouter une lib = une ligne dans `LIBS`, plus un `.cbl` et un `.jcl` qui
écrit le module dans `HERC01.TRAVEL.LOAD(MEMBRE)`.

Avec `--run`, le script affiche **toute** la sortie du programme (chaque
`DISPLAY`) : les lignes du spool entre la fin du listing de l'éditeur de
liens (`AUTHORIZATION CODE IS`) et la bannière de fin de job. Plus les
erreurs `IKFnnnnI` et `IEW0132`. Une première version filtrait sur des
débuts de ligne fixes (`FICHE`, `NAME`...) : un nouveau `DISPLAY`
n'apparaissait pas, et `CHARV1` semblait ne pas être mis à jour.

### Libs recompilées seulement si besoin

Avant l'upload (qui écraserait les sources sur MVS), le script vérifie :

1. le module `HERC01.TRAVEL.LOAD(RANDGEN)` existe
   (`powe --rfj files list all-members`, champ `data.members`) ;
2. `HERC01.TRAVEL.CBL(RANDGEN)` est identique à `lib/randomGenerator.cbl`
   (`powe files download data-set ... -f`, puis `cmp`) ;
3. `HERC01.TRAVEL.JCL(RANDGEN)` est identique à `lib/randomGenerator.jcl`.

Les trois sont vrais : sources RANDGEN non renvoyées, pas de job `RANDLIB`.
Sinon : effacement de l'ancien module, upload, puis `RANDLIB`, même sans
`--run`. Le module sur MVS correspond ainsi toujours à la source sur MVS.

L'ancien module est effacé **avant** l'upload. Si l'upload ou la
compilation échoue (ou Ctrl-C), le module reste absent et le lancement
suivant recompile. Sans cela, source neuve + vieux module passeraient pour
« à jour ».

`powe files delete` d'un **membre** absent échoue (code 3), contrairement à
celui d'un dataset absent : le script n'efface que si le module existe.

`CHARV1` est toujours recompilé et relié : il recopie le RANDGEN courant.

Testé : rien changé (pas de `RANDLIB`), source modifiée, module effacé,
`--force-libs`, erreur de compilation dans `CHARV1`.

Sortie attendue :

```
FICHE PERSONNAGE
NAME     : DUPONT
SURNAME  : JEAN
FORCE    : 07
NB ALEATOIRE : 0061
DEX 2D6  : 06
```

## Fichiers et datasets

MVS n'a pas de dossiers. Chaque fichier devient un membre (8 caractères max)
d'un PDS (dataset partitionné).

| Fichier local                | Dataset MVS                   |
|------------------------------|-------------------------------|
| `lib/randomGenerator.cbl`    | `HERC01.TRAVEL.CBL(RANDGEN)`  |
| `lib/randomGenerator.jcl`    | `HERC01.TRAVEL.JCL(RANDGEN)`  |
| `character/characterV1.cbl`  | `HERC01.TRAVEL.CBL(CHARV1)`   |
| `character/characterV1.jcl`  | `HERC01.TRAVEL.JCL(CHARV1)`   |
| (module compilé)             | `HERC01.TRAVEL.LOAD(RANDGEN)` |

Garder le préfixe `HERC01.` : hors du catalogue utilisateur, un dataset est
alloué sans être catalogué (`IEF287I NOT CATLGD`).

## Corrections apportées

| Fichier | Problème | Correction |
|---|---|---|
| `randomGenerator.cbl` | `STOP RUN` dans un sous-programme arrête aussi l'appelant | `EXIT PROGRAM` |
| | `VALUE` interdit en `LINKAGE SECTION` | retiré |
| | `PROCEDURE DIVISION` sans `USING` : les paramètres ne sont pas reçus | `USING LK-MIN LK-MAX LK-RESULTAT` |
| | `ACCEPT ... FROM TIME` inconnu du compilateur de 1972 (RC 12) | registre IBM `TIME-OF-DAY` (HHMMSS) |
| | Graine relue à chaque appel : deux appels dans la même seconde donnent le même nombre | graine lue au premier appel seulement |
| | `PROGRAM-ID. TIRAGE-ALEATOIRE` trop long pour un nom de module | `RANDGEN` |
| | Accents, guillemets doubles | ASCII, apostrophes |
| `characterV1.cbl` | `CALL 'generator'` ne désigne aucun module | `CALL 'RANDGEN'` |
| | Variables du tirage au niveau 10, rangées par erreur dans `CARAC` | groupe `01 TIRAGE` à part |
| | `AUTHOR` sans point | `AUTHOR.` |

Ajout : `DEX` est tiré en 2D6 (deux appels de 1 à 6), comme dans Traveller.

## Le générateur RANDGEN

Algorithme MINSTD (Park-Miller, congruentiel linéaire) :

```
graine   = (graine * 16807) modulo 2147483647
résultat = min + (graine * (max - min + 1)) / 2147483647   (partie entière)
```

- Au premier appel, la graine vient de l'heure (`TIME-OF-DAY`, HHMMSS). Une
  graine 0 est remplacée par 1, sinon MINSTD reste bloqué à 0.
- Puis **échauffement** : 10 + (heure modulo 97) tirages jetés (voir
  ci-dessous).
- La `WORKING-STORAGE` d'un sous-programme est conservée entre deux `CALL`.
  Les appels suivants repartent donc du tirage précédent.

### Tirages prévisibles d'un lancement à l'autre (corrigé)

Première version : graine = heure, un tour de MINSTD, puis `graine modulo
plage`. Six lancements à 3 secondes d'écart :

```
20:44:35 NB ALEATOIRE : 0099
20:44:38 NB ALEATOIRE : 0020
20:44:41 NB ALEATOIRE : 0041
20:44:44 NB ALEATOIRE : 0055
20:44:47 NB ALEATOIRE : 0076
20:44:50 NB ALEATOIRE : 0097
```

Le tirage avance d'environ 21 toutes les 3 secondes : +7 par seconde.

Cause : MINSTD est **linéaire**. Après N tours,
`graine = heure * 16807^N modulo 2147483647`. L'heure avance de 1 par
seconde, donc la graine avance d'un pas constant (`16807^N`), et le tirage
aussi. Avec N = 1 sur 1-100 : 16807 modulo 100 = 7, d'où +7 par seconde.

Jeter un nombre **fixe** de tirages ne suffit pas : le pas change, mais
reste constant (simulation : +38 par seconde avec 10 tours).

Corrections :

1. **Échauffement variable** : N = 10 + (heure modulo 97). Le
   multiplicateur `16807^N` change à chaque seconde : plus de pas constant.
2. **Chiffres de poids fort** : `(graine * plage) / 2147483647` au lieu de
   `graine modulo plage`. `graine / 2147483647` est une fraction entre 0
   et 1, étirée sur la plage. Les chiffres de poids faible d'un générateur
   congruentiel sont les moins aléatoires.

Vérifié par simulation sur les 86 400 secondes d'une journée : les 100
valeurs de 1-100 sortent toutes, DEX suit la courbe 2D6 (7 dans 1 cas sur
6, 2 et 12 dans 1 cas sur 36). Puis sur le conteneur :

```
20:46:14 NB ALEATOIRE : 0061 DEX 2D6  : 11
20:46:17 NB ALEATOIRE : 0073 DEX 2D6  : 07
20:46:20 NB ALEATOIRE : 0043 DEX 2D6  : 06
20:46:23 NB ALEATOIRE : 0083 DEX 2D6  : 08
20:46:27 NB ALEATOIRE : 0044 DEX 2D6  : 07
20:46:30 NB ALEATOIRE : 0068 DEX 2D6  : 08
20:46:33 NB ALEATOIRE : 0020 DEX 2D6  : 02
20:46:36 NB ALEATOIRE : 0095 DEX 2D6  : 06
```

Limites :

- 7 reste le résultat le plus fréquent en 2D6 : c'est voulu (6 combinaisons
  sur 36). Le voir plusieurs fois n'est pas un défaut.
- Deux lancements dans la même seconde donnent le même résultat :
  `TIME-OF-DAY` est à la seconde près.
- Pas fait pour la sécurité (mots de passe, jetons) : la graine se devine
  à partir de l'heure.

## Pourquoi le niveau 77

```cobol
       WORKING-STORAGE SECTION.
       77  WS-INIT                   PIC 9      VALUE 0.
```

En COBOL, le numéro en tête d'une donnée est son **niveau** :

| Niveau  | Sens |
|---------|------|
| `01`    | début d'un enregistrement, peut contenir des sous-zones |
| `02`-`49` | sous-zones d'un `01` (`05`, `10`... par convention) |
| `77`    | donnée **isolée** : ni groupe, ni sous-zone |
| `88`    | nom de condition (`88 DEJA-INIT VALUE 1.`) |

`77` dit : « variable simple, seule ». C'est le cas de `WS-INIT`, un drapeau
d'un chiffre (0 = graine pas encore lue, 1 = graine lue), et des autres
variables de travail de RANDGEN (`WS-GRAINE`, `WS-PRODUIT`...). Aucune n'a
de sous-zone, aucune n'appartient à une autre.

Règles :

- un `77` s'écrit en zone A (colonne 8), comme un `01` ;
- il ne peut pas avoir de sous-zones, et ne peut pas être une sous-zone ;
- il n'existe qu'en `WORKING-STORAGE` et `LINKAGE SECTION`, pas en
  `FILE SECTION` ;
- en COBOL 74 (et sur ce compilateur de 1972), les `77` se placent avant
  les `01` de la même section.

Un `01` avec un seul `PIC` ferait la même chose :

```cobol
       01  WS-INIT                   PIC 9      VALUE 0.
```

La différence est de lecture : `77` annonce tout de suite une variable
isolée. Le niveau 77 est déclaré obsolète depuis COBOL 2002, mais reste
accepté partout et très présent dans le code ancien.

Pourquoi `WS-INIT` marche : la `WORKING-STORAGE` d'un sous-programme est
initialisée (`VALUE 0`) une seule fois, au chargement du module, puis garde
ses valeurs entre deux `CALL`. Au premier appel `WS-INIT = 0`, on lit
l'heure et on passe `WS-INIT` à 1 ; aux appels suivants, la lecture est
sautée.

Dans `characterV1.cbl`, les variables du tirage sont au contraire dans un
groupe `01 TIRAGE` (sous-zones `05`), parce qu'elles vont ensemble : les
trois paramètres du `CALL`.

## Passage des paramètres

`CALL 'RANDGEN' USING WS-MIN WS-MAX WS-RESULTAT` passe des **adresses**, pas
des noms. La `LINKAGE SECTION` de RANDGEN ne réserve aucune mémoire : elle
pose ses noms (`LK-MIN`, `LK-MAX`, `LK-RESULTAT`) sur les zones de l'appelant.
Il faut donc le même ordre et les mêmes `PIC` des deux côtés (`PIC 9(4)`).
Les noms, eux, peuvent différer.

## Comment CHARV1 trouve RANDGEN

1. **Job `RANDLIB`** (`lib/randomGenerator.jcl`, procédure `COBUCL`) :
   compile RANDGEN et écrit le module dans `HERC01.TRAVEL.LOAD(RANDGEN)`
   (surcharge de `//LKED.SYSLMOD`, qui vise sinon un PDS temporaire).
2. **Job `CHARV1`, étape COB** : `CALL 'RANDGEN'` laisse une référence
   externe non résolue. Le compilateur ne sait pas où est RANDGEN.
3. **Job `CHARV1`, étape LKED** : l'éditeur de liens (`IEWL`) cherche chaque
   référence non résolue comme membre des bibliothèques de `//LKED.SYSLIB`
   (autocall). Il trouve `HERC01.TRAVEL.LOAD(RANDGEN)` et le copie dans le
   module (appel statique).
4. **Job `CHARV1`, étape GO** : le module est complet, rien n'est cherché à
   l'exécution.

Surcharge de `SYSLIB` dans `characterV1.jcl` :

```
//LKED.SYSLIB DD DSN=HERC01.TRAVEL.LOAD,DISP=SHR
//            DD DSN=SYS1.COBLIB,DISP=SHR
```

Notre bibliothèque est en tête, puis le runtime COBOL. Sur MVS 3.8, le plus
grand BLKSIZE doit venir en premier (LOAD 19069, COBLIB 1024).

### Pourquoi le plus grand BLKSIZE en tête

**BLKSIZE** (block size) : taille maximale d'un bloc physique sur le disque,
en octets. C'est l'unité qu'une lecture transfère d'un coup. Un module
(RECFM=U) est stocké en blocs de taille variable, au plus BLKSIZE.

| Bibliothèque          | BLKSIZE | Origine |
|-----------------------|---------|---------|
| `HERC01.TRAVEL.LOAD`  | 19069   | créée par `upload_character.sh` (`--blksize 19069`) |
| `SYS1.COBLIB`         | 1024    | fournie par TK4- (`powe files list data-set SYS1.COBLIB`) |

19069 octets = capacité d'une piste de disque 3350 : un bloc par piste,
le moins de place perdue entre blocs.

#### Connaître le BLKSIZE d'une bibliothèque

`powe files list data-set NOM` lance `LISTDS` (TSO) en batch :

```console
$ powe files list data-set HERC01.TRAVEL.LOAD
...
HERC01.TRAVEL.LOAD
--RECFM-LRECL-BLKSIZE-DSORG
  U     80    19069   PO
```

Dans un script, la sortie JSON donne les valeurs directement :

```console
$ powe --rfj files list data-set HERC01.TRAVEL.LOAD | jq -c .data.attributes
{"recfm":"U","lrecl":"80","blksize":"19069","dsorg":"PO","volume":"MVSCAT"}
```

`--attributes` lance `LISTCAT ENTRY(...) ALL` : volume, type de disque, date
de création.

```console
$ powe files list data-set HERC01.TRAVEL.LOAD --attributes | grep DEVTYPE
       VOLSER------------MVSCAT     DEVTYPE------X'3010200F'     FSEQN------------------0
```

`DEVTYPE X'3010200F'` : le dernier octet `0F` désigne un disque 3350, dont
la piste fait 19069 octets.

Même commande pour une autre bibliothèque : `powe files list data-set
SYS1.COBLIB` (blocs de 1024).

Sans powe : sous TSO en 3270, `LISTDS 'HERC01.TRAVEL.LOAD'` affiche le même
tableau. Sous ISPF, option 3.2, puis le nom du dataset.

**Concaténation** : deux DD à la suite (le second sans nom) forment un seul
fichier logique, `SYSLIB`. L'éditeur de liens l'ouvre **une seule fois**.
À cette ouverture (OPEN), MVS lit les attributs (DCB) du **premier** dataset
seulement, et réserve des tampons mémoire de cette taille. Ces tampons
servent ensuite pour tous les datasets de la concaténation.

Conséquences :

- **LOAD (19069) en tête** : tampons de 19069 octets. Les blocs de COBLIB
  (1024 au plus) y tiennent. Correct.
- **COBLIB (1024) en tête** : tampons de 1024 octets. Un bloc de 19069
  lu depuis LOAD ne tient pas : erreur d'entrée-sortie, module illisible,
  RANDGEN non résolu ou ABEND (typiquement `001`, erreur de lecture).

Les systèmes récents (z/OS) recalculent les tampons à chaque changement de
dataset dans la concaténation ; MVS 3.8 ne le fait pas pour une
bibliothèque partitionnée.

Ordre inverse non testé ici : la règle vient du fonctionnement de l'OPEN
décrit ci-dessus. Avec l'ordre actuel, le job passe (LKED RC 0000).

Autres solutions possibles :

- créer `HERC01.TRAVEL.LOAD` avec `--blksize 1024` : les deux tailles sont
  égales, l'ordre devient libre (mais plus de blocs, plus lent) ;
- forcer la taille dans le JCL, sur le premier DD :
  `//LKED.SYSLIB DD DSN=SYS1.COBLIB,DISP=SHR,DCB=BLKSIZE=19069`.

Garder notre bibliothèque en tête a un second avantage : un membre de même
nom dans LOAD est trouvé avant celui de COBLIB (recherche dans l'ordre).

Le même nom `RANDGEN` doit apparaître à trois endroits : le `PROGRAM-ID`, le
`CALL` et le nom du membre dans `HERC01.TRAVEL.LOAD`.

Si RANDGEN change : relancer `RANDLIB`, puis `CHARV1` (le module CHARV1
contient une copie de l'ancien RANDGEN).

## Données d'entrée

Une carte par `ACCEPT`, dans `//GO.SYSIN` de `characterV1.jcl` :

```
DUPONT      -> CHAR-NAME
JEAN        -> CHAR-SNAME
07          -> STR (2 chiffres)
```

## Dépannage

| Symptôme | Cause |
|---|---|
| `IKFnnnnI-E` dans le spool, RC 12 sur COB | erreur de compilation, numéro de ligne en tête |
| `IEW0132` sur LKED | RANDGEN introuvable dans SYSLIB : lancer `RANDLIB` d'abord |
| Accent devenu `?` | MVS est en EBCDIC, écrire en ASCII |
| Ligne tronquée | 80 colonnes max ; code COBOL en colonnes 8 à 72 |

```bash
powe jobs view spool-file-by-id CHARV1 | grep -E 'IKF[0-9]+I-[EWCD]|IEW'
```
