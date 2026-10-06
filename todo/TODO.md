# TODO CobolTraveller

## Étape 1 : un personnage par fichier

- [ ] Créer un fichier de données contenant un seul personnage.
- [ ] Faire lire ce fichier par le programme à la place des cartes du JCL.
- [ ] Créer un deuxième fichier avec un autre personnage.
- [ ] Lancer le programme sur chacun des deux fichiers, sans modifier le
      code COBOL entre les deux.
- [ ] Afficher la fiche de chaque personnage.
- [ ] Déposer les fichiers de données sur MVS avec le script d'upload.
- [ ] Gérer le cas du fichier absent.
- [ ] Gérer le cas du fichier vide.

## Étape 2 : un seul fichier, une caractéristique par ligne

- [ ] Définir l'ordre des lignes (nom, prénom, FOR, DEX, ...).
- [ ] Créer un fichier avec une caractéristique par ligne pour un personnage.
- [ ] Faire lire ce fichier par le programme.
- [ ] Afficher la fiche complète.
- [ ] Gérer une caractéristique manquante (fichier trop court).
- [ ] Gérer une valeur invalide (lettres à la place d'un nombre).
- [ ] Gérer une caractéristique absente du fichier : la tirer au hasard
      avec RANDGEN.
- [ ] Ajouter les autres caractéristiques Traveller (END, INT, EDU, SOC).

## Étape 3 : un seul fichier, un personnage par ligne

- [ ] Définir le format d'une ligne (position et longueur de chaque champ).
- [ ] Créer un fichier avec plusieurs personnages, un par ligne.
- [ ] Lire toutes les lignes jusqu'à la fin du fichier.
- [ ] Afficher une fiche par personnage.
- [ ] Afficher le nombre de personnages lus à la fin.
- [ ] Gérer une ligne invalide : la signaler et passer à la suivante.
- [ ] Gérer un fichier vide (zéro personnage).
- [ ] Tester avec un grand nombre de personnages (100, 1000).
- [ ] Écrire les personnages générés dans un fichier de sortie, pas
      seulement à l'écran.

## Étape 4 : autres formats de fichiers

### CSV

- [ ] Créer un fichier CSV de personnages (une ligne d'en-tête, un
      personnage par ligne).
- [ ] Le lire et afficher les fiches.
- [ ] Gérer des champs de longueur variable.
- [ ] Gérer un champ vide.
- [ ] Gérer un séparateur présent dans un nom.
- [ ] Produire un CSV en sortie.

### EDIFACT

- [ ] Définir un message EDIFACT pour un personnage (segments, éléments).
- [ ] Créer un fichier EDIFACT avec un ou plusieurs personnages.
- [ ] Le lire et afficher les fiches.
- [ ] Vérifier l'en-tête et la fin de message (nombre de segments).
- [ ] Gérer un segment inconnu.
- [ ] Gérer le caractère d'échappement.
- [ ] Produire un fichier EDIFACT en sortie.

### Fichiers faits pour COBOL

- [ ] Fichier séquentiel à enregistrements de longueur fixe.
- [ ] Fichier séquentiel à enregistrements de longueur variable.
- [ ] Fichier avec des nombres stockés en binaire ou en décimal condensé,
      pas en texte.
- [ ] Fichier indexé par une clé (retrouver un personnage par son nom).
- [ ] Fichier en accès direct (retrouver un personnage par son numéro).
- [ ] Partager la description d'un enregistrement entre plusieurs
      programmes.

### Comparaison

- [ ] Mêmes personnages dans chaque format.
- [ ] Vérifier que chaque format donne les mêmes fiches.
- [ ] Noter, pour chaque format, ce qui a été facile ou difficile en COBOL
      sur ce compilateur.

## En suspens

- [ ] Rendre CHARTRA appelable depuis un autre programme (module dans
      HERC01.TRAVEL.LOAD).
- [ ] `0000-FIN.` : espaces en fin de ligne dans `characterV1.cbl`.
