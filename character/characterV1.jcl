//CHARV1   JOB (1),'TRAVELLER',CLASS=A,MSGCLASS=A,MSGLEVEL=(1,1),
//             USER=HERC01,PASSWORD=CUL8TR
//* Compile, relie et execute HERC01.TRAVEL.CBL(CHARV1).
//* Pre-requis : RANDGEN deja construit par lib/randomGenerator.jcl
//* dans HERC01.TRAVEL.LOAD.
//*
//* Comment CHARTRA trouve RANDGEN :
//*  1. COB  : CALL 'RANDGEN' laisse une reference externe non resolue
//*            dans le module objet.
//*  2. LKED : l'editeur de liens (IEWL) cherche chaque reference
//*            non resolue comme MEMBRE des bibliotheques du DD SYSLIB
//*            (autocall). Il trouve HERC01.TRAVEL.LOAD(RANDGEN) et le
//*            copie dans le module CHARTRA (appel statique).
//*  3. GO   : le module est complet, rien n'est cherche a l'execution.
//*            Modifier RANDGEN oblige donc a relancer ce job.
//* Rajout de cette ligne pour le copybook : 
//COB      EXEC COBUCLG,PARM.COB='LOAD,SUPMAP,LIB,SIZE=2048K,BUF=1024K'
//* -------------------------------------------------------------
//* AJOUT DE LA BIBLIOTHEQUE DE COPYBOOKS POUR LE COMPILATEUR
//* -------------------------------------------------------------
//COB.SYSLIB DD DSN=HERC01.TRAVEL.COPYLIB,DISP=SHR
//COB.SYSIN DD DSN=HERC01.TRAVEL.CBL(CHARV1),DISP=SHR
//* SYSLIB de la procedure = SYS1.COBLIB seul (runtime COBOL).
//* Surcharge : notre bibliotheque d'abord, puis SYS1.COBLIB en
//* concatenation (DD sans nom). Ordre impose : en MVS 3.8 le plus
//* grand BLKSIZE doit etre en tete (LOAD 19069, COBLIB 1024).
//* on peut aussi faire DCB=BLKSIZE=19069.
//LKED.SYSLIB DD DSN=HERC01.TRAVEL.LOAD,DISP=SHR
//            DD DSN=SYS1.COBLIB,DISP=SHR
//GO.SYSPRINT DD SYSOUT=*
//GO.SYSOUT   DD SYSOUT=*
//* Une carte par ACCEPT : CHAR-NAME, CHAR-SNAME, STR (2 chiffres).
//GO.SYSIN    DD *
DUPONT
JEAN
07
/*
//
