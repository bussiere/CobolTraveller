# Notes : RANDGEN, paragraphes et déroulement

Fichier : `lib/randomGenerator.cbl`. Sous-programme appelé par
`CALL 'RANDGEN' USING ...` (voir `../character/Note.md` pour l'appel et le
JCL).

## Qu'est-ce que `0000-MAIN.`

C'est un **nom de paragraphe**. En COBOL, la `PROCEDURE DIVISION` est
découpée en paragraphes :

- le nom s'écrit en **zone A** (colonne 8), suivi d'un point ;
- le paragraphe contient toutes les phrases qui suivent, jusqu'au nom de
  paragraphe suivant ;
- un nom de paragraphe sert de cible à `PERFORM` (appel avec retour) ou
  `GO TO` (saut sans retour).

`0000-MAIN` n'a rien de spécial pour le compilateur : ce n'est ni un mot
réservé, ni un point d'entrée imposé (contrairement au `main` du C).
L'exécution commence toujours à la **première phrase** de la `PROCEDURE
DIVISION`, quel que soit le nom du premier paragraphe. On aurait pu
l'appeler `DEBUT` ou `TIRAGE`.

Les quatre paragraphes de RANDGEN :

| Paragraphe    | Rôle                                           | Atteint par |
|---------------|------------------------------------------------|-------------|
| `0000-MAIN`   | logique principale, à chaque appel             | `CALL` (première phrase) |
| `0000-FIN`    | `EXIT PROGRAM` : retour à l'appelant           | enchaînement depuis `0000-MAIN` |
| `1000-GRAINE` | graine depuis l'heure + échauffement           | `PERFORM`, premier appel seulement |
| `2000-SUIVANT`| un tour de MINSTD                              | `PERFORM`, plusieurs fois |

## Pourquoi des numéros (`0000-`, `1000-`, `2000-`)

Convention très répandue dans le COBOL d'entreprise, pas une règle du
langage :

- le numéro donne l'**ordre dans le source** : on retrouve vite un
  paragraphe dans un listing de plusieurs milliers de lignes ;
- `0000` = programme principal, `1000`, `2000`... = sous-tâches, `9999` ou
  `-FIN` = sortie ;
- le nom après le tiret dit ce que fait le paragraphe.

## Comment ça s'exécute

COBOL lit les paragraphes **dans l'ordre du source**, et **enchaîne** d'un
paragraphe au suivant tant que rien ne l'arrête (fall-through). Un nom de
paragraphe n'est pas une barrière.

Premier appel (`WS-INIT = 0`) :

```
CALL 'RANDGEN'
 └─ 0000-MAIN
     ├─ IF WS-INIT = 0 → PERFORM 1000-GRAINE ──┐
     │                                          │ 1000-GRAINE
     │                                          │   graine = heure
     │                                          │   WS-INIT = 1
     │                                          │   PERFORM 2000-SUIVANT N FOIS
     │                                          │     (N = 10 + heure mod 97)
     │   ◄──────── retour ──────────────────────┘ (fin du paragraphe)
     ├─ PERFORM 2000-SUIVANT                     (un tour : nouveau tirage)
     ├─ calcul de LK-RESULTAT
     │   (pas d'instruction de fin : on enchaîne sur le paragraphe suivant)
 └─ 0000-FIN
     └─ EXIT PROGRAM  → retour à l'appelant
```

Appels suivants (`WS-INIT = 1`) : même chemin, sans `1000-GRAINE`.

### `PERFORM` : appel avec retour

`PERFORM 1000-GRAINE` exécute le paragraphe `1000-GRAINE`, puis revient à
la phrase qui suit le `PERFORM`. La fin du paragraphe, c'est le nom du
paragraphe suivant (`2000-SUIVANT`) : arrivé là, on revient au `PERFORM`.

`1000-GRAINE` fait lui-même `PERFORM 2000-SUIVANT WS-TOURS TIMES` : un
`PERFORM` imbriqué, permis. `TIMES` répète le paragraphe `WS-TOURS` fois.

### Pourquoi `0000-FIN` est un paragraphe à part

`0000-MAIN` se termine sans instruction de sortie : l'exécution **tombe**
dans `0000-FIN`, qui fait `EXIT PROGRAM`.

Deux raisons de séparer :

- en COBOL 68/74, `EXIT PROGRAM` doit être **seul** dans son paragraphe ;
- un point de sortie unique, avec un nom : on peut y sauter depuis
  n'importe où (`GO TO 0000-FIN`) si on ajoute un cas d'erreur.

`EXIT PROGRAM` rend la main à l'appelant, juste après son `CALL`. `STOP RUN`
arrêterait tout le programme, appelant compris.

### Pourquoi `1000-GRAINE` et `2000-SUIVANT` sont **après** `0000-FIN`

À cause de l'enchaînement. Placés avant `0000-FIN`, ils seraient exécutés
une fois de plus par simple chute, à chaque appel : graine relue, tirage
en trop. Placés après `EXIT PROGRAM`, on ne les atteint **que** par
`PERFORM`.

Règle pratique : d'abord le chemin principal, terminé par la sortie ; puis
les paragraphes appelés par `PERFORM`.

### Le point final remplace `END-IF`

```cobol
           IF WS-INIT = 0
               PERFORM 1000-GRAINE.
```

Ce compilateur (1972) ne connaît pas `END-IF` (`IKF3001I-E END-IF NOT
DEFINED`). C'est le **point** qui ferme le `IF`. Un point mal placé change
la logique : tout ce qui est avant lui est dans le `IF`, tout ce qui est
après est exécuté dans tous les cas.

## Le résultat en un appel

1. `0000-MAIN` : graine initialisée si premier appel.
2. `2000-SUIVANT` : `graine = (graine * 16807) mod 2147483647`.
3. `LK-RESULTAT = LK-MIN + (graine * plage) / 2147483647`, où
   `plage = LK-MAX - LK-MIN + 1`.
4. `0000-FIN` : retour. `LK-RESULTAT` est la zone de l'appelant : il lit le
   tirage dans sa propre variable (`WS-RESULTAT`).

Détails de l'algorithme et de l'échauffement : `../character/Note.md`,
section « Le générateur RANDGEN ».
