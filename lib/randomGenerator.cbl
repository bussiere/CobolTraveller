       IDENTIFICATION DIVISION.
       PROGRAM-ID. TIRAGE-ALEATOIRE.
       AUTHOR. BUSSIERE.
            
       DATA DIVISION.
       WORKING-STORAGE SECTION.
      * Variables pour recuperer l'heure du système (La Graine / Seed)
       01  WS-TEMPS.
           05  WS-HEURE              PIC 99.
           05  WS-MINUTE             PIC 99.
           05  WS-SECONDE            PIC 99.
           05  WS-CENTIEME           PIC 99.
      
      * Variables pour l'algorithme mathematique du tirage
       01  WS-GRAINE                 PIC 9(8)   VALUE ZERO.
       01  WS-PRODUIT                PIC 9(12)  VALUE ZERO.
       01  WS-QUOTIENT               PIC 9(8)   VALUE ZERO.
       01  WS-RESTE                  PIC 9(8)   VALUE ZERO.
      
      * Variables de configuration et resultat du tirage (entre 1 et 100
       01  WS-MIN                    PIC 9(4)   VALUE 1.
       01  WS-MAX                    PIC 9(4)   VALUE 100.
       01  WS-PLAGE                  PIC 9(4)   VALUE ZERO.
       01  WS-RESULTAT               PIC 9(4)   VALUE ZERO.
      
       PROCEDURE DIVISION.
       0000-MAIN.
      *   1. Initialisation de la graine avec l'heure courante 
      *   (evite les doublons)
           ACCEPT WS-TEMPS FROM TIME.
           MOVE WS-TEMPS TO WS-GRAINE.
      
      *   2. Calcul de la plage de tirage (Max - Min + 1)
           COMPUTE WS-PLAGE = WS-MAX - WS-MIN + 1.
      
      *   3. Generation du nombre pseudo-aleatoire 
      *  (Methode Minstd / LGC)
      *   Formule standard : (Graine * 16807) Modulo 2147483647
           MULTIPLY WS-GRAINE BY 16807 GIVING WS-PRODUIT.
           DIVIDE WS-PRODUIT BY 2147483647 
              GIVING WS-QUOTIENT REMAINDER WS-GRAINE.
      
      *   4. Adaptation du resultat à la plage souhaitee (Min à Max)
           DIVIDE WS-GRAINE BY WS-PLAGE 
              GIVING WS-QUOTIENT REMAINDER WS-RESTE.
           ADD WS-RESTE TO WS-MIN GIVING WS-RESULTAT.
      
      *   5. Affichage du resultat
           DISPLAY "NOMBRE TIRe AU SORT : " WS-RESULTAT.
      
           STOP RUN.
      