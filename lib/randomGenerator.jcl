//RANDLIB  JOB (1),'TRAVELLER LIB',CLASS=A,MSGCLASS=A,MSGLEVEL=(1,1),
//             USER=HERC01,PASSWORD=CUL8TR
//* Construit le sous-programme RANDGEN dans la bibliotheque de
//* modules HERC01.TRAVEL.LOAD. A relancer apres chaque modification
//* de HERC01.TRAVEL.CBL(RANDGEN), puis relier les appelants.
//*
//* COBUCL = COB (compilation IKFCBL00) + LKED (edition de liens IEWL),
//* sans etape GO : un sous-programme ne s'execute pas seul.
//COB      EXEC COBUCL
//COB.SYSIN DD DSN=HERC01.TRAVEL.CBL(RANDGEN),DISP=SHR
//* SYSLMOD : ou LKED ecrit le module. Par defaut un PDS temporaire
//* (&GODATA) efface en fin de job ; ici le PDS permanent, membre
//* RANDGEN (= PROGRAM-ID = nom dans CALL 'RANDGEN').
//LKED.SYSLMOD DD DSN=HERC01.TRAVEL.LOAD(RANDGEN),DISP=SHR
//
