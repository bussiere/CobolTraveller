#!/usr/bin/env bash
# upload_character.sh : envoie les sources COBOL et les JCL de CobolTraveller
# dans le conteneur MVS 3.8j TK4- (mainframe-tk4), avec powe.
#
#   script/upload_character.sh               upload (+ compile les libs si besoin)
#   script/upload_character.sh --run         idem, puis lance CHARV1
#   script/upload_character.sh --force-libs  recompile toutes les libs, meme
#                                            sans changement (alias : --force-lib)
#   (options combinables : --run --force-libs ; lancable depuis n'importe
#    quel repertoire)
#
# Deux sortes de fichiers :
# - les LIBS (sous-programmes, ex. RANDGEN) : compilees dans HERC01.TRAVEL.LOAD
#   seulement si leur source ou leur JCL a change, ou si le module manque ;
# - les PROGRAMMES (ex. CHARV1) : toujours renvoyes. Leur JCL les recompile
#   et les relie a chaque soumission.
#
# Rappels powe (clone Python de la CLI Zowe, voir hercule/powe/README.md) :
# - powe ne parle pas a z/OSMF (absent de TK4-). Chaque commande "files"
#   fabrique un petit job JCL (IEBGENER, IKJEFT01...), l'envoie au lecteur de
#   cartes 3505, puis lit le resultat dans le journal et l'imprimante
#   (prt00e.txt) du conteneur via podman.
# - Codes de sortie : 0 ok, 1 usage/connexion, 2 job pas fini a temps,
#   3 job en echec (ABEND ou RC >= 8), 4 sortie imprimante absente.
# - Config par defaut : 127.0.0.1:3505, conteneur mainframe-tk4,
#   USER=HERC01 PASSWORD=CUL8TR. Surchargeable par POWE_* ou --option.
# - MVS n'a pas de dossiers : on range dans des PDS (datasets partitionnes),
#   un par type ; chaque fichier devient un membre (8 caracteres max) :
#     HERC01.TRAVEL.CBL(CHARV1)   <- character/characterV1.cbl
#     HERC01.TRAVEL.CBL(RANDGEN)  <- lib/randomGenerator.cbl
#     HERC01.TRAVEL.JCL(CHARV1)   <- character/characterV1.jcl
#     HERC01.TRAVEL.JCL(RANDGEN)  <- lib/randomGenerator.jcl
#     HERC01.TRAVEL.LOAD(RANDGEN)    module compile, ecrit par le job RANDLIB
#   Garder le prefixe HERC01. : hors catalogue utilisateur, le dataset serait
#   alloue sans etre catalogue (IEF287I NOT CATLGD).
#
# Chaine d'appel : CHARTRA fait CALL 'RANDGEN'. Le job RANDLIB compile
# RANDGEN dans HERC01.TRAVEL.LOAD ; le job CHARV1 met cette bibliotheque dans
# LKED.SYSLIB, l'editeur de liens y trouve le membre RANDGEN et l'inclut.
# Donc : RANDLIB d'abord, CHARV1 ensuite.
set -euo pipefail

# Le script est dans script/ ; les chemins de LIBS et PROGRAMMES sont
# relatifs a la racine du projet, un niveau au-dessus.
cd "$(dirname "$0")/.."

RUN=0
FORCE_LIBS=0
for arg in "$@"; do
    case "$arg" in
        --run)                     RUN=1 ;;
        --force-libs|--force-lib)  FORCE_LIBS=1 ;;
        *) echo "usage : $0 [--run] [--force-libs]" >&2; exit 1 ;;
    esac
done

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# POWE="uv run --project ../hercule/powe powe" si powe n'est pas installe.
read -r -a POWE <<< "${POWE:-powe}"

PREFIXE="HERC01.TRAVEL"
PDS_CBL="$PREFIXE.CBL"
PDS_JCL="$PREFIXE.JCL"
PDS_LOAD="$PREFIXE.LOAD"

# Chaque entree : "chemin sans extension:MEMBRE". Le .cbl va dans
# HERC01.TRAVEL.CBL(MEMBRE), le .jcl dans HERC01.TRAVEL.JCL(MEMBRE).
# Pour une lib, le JCL doit ecrire le module dans HERC01.TRAVEL.LOAD(MEMBRE)
# (voir lib/randomGenerator.jcl). Ajouter une lib = ajouter une ligne ici.
LIBS=(
    "lib/randomGenerator:RANDGEN"
)
PROGRAMMES=(
    "character/characterV1:CHARV1"
)

# 0. Tous les fichiers locaux existent-ils ? Verifie AVANT de toucher a MVS :
#    sinon une lib dont le .cbl manque passerait pour "modifiee", son module
#    serait efface, puis l'upload echouerait.
manquants=0
for entree in "${LIBS[@]}" "${PROGRAMMES[@]}"; do
    for ext in cbl jcl; do
        if [[ ! -f "${entree%%:*}.$ext" ]]; then
            echo "[ERREUR] fichier absent : $PWD/${entree%%:*}.$ext" >&2
            manquants=1
        fi
    done
done
[[ $manquants == 0 ]] || exit 1

# 1. Le mainframe repond-il ? Verifie lecteur 3505, console 8038, conteneur,
#    JES2 et MVS. Code 0 seulement si tout est pret.
echo "== Etat du mainframe"
"${POWE[@]}" zosmf check status

# 2. Quels datasets existent deja sous HERC01.TRAVEL ?
#    "list data-set PREFIXE.**" lance LISTCAT LEVEL(...) en batch.
#    --rfj : un seul objet JSON sur stdout ; data.datasets liste les noms.
existants=$("${POWE[@]}" --rfj files list data-set "$PREFIXE.**" \
    | python3 -c 'import json,sys; print(" ".join(json.load(sys.stdin)["data"]["datasets"]))')

# 3. Cree les PDS absents. "create" d'un dataset deja present echoue
#    (code 3) : on ne le lance que si le nom manque.
#    Sources et JCL : defauts powe (FB 80, 5 pistes, 10 blocs de repertoire).
#    Modules (LOAD) : RECFM=U, format exige par l'editeur de liens pour
#    SYSLMOD/SYSLIB. powe impose un LRECL : 80 par defaut, ignore en U.
creer() {
    local pds="$1"; shift
    if [[ " $existants " == *" $pds "* ]]; then
        echo "== $pds existe deja"
    else
        echo "== Creation de $pds"
        "${POWE[@]}" files create data-set-partitioned "$pds" "$@"
    fi
}
creer "$PDS_CBL"
creer "$PDS_JCL"
creer "$PDS_LOAD" --recfm U --blksize 19069

# upload LOCAL CIBLE : le fichier est envoye en cartes de 80 colonnes dans un
# job IEBGENER (DD DATA,DLM=@@) ; le membre est cree ou remplace.
# Limites : 200 000 octets, pas de ligne commencant par @@, lignes > 80
# colonnes tronquees (avertissement [ATTENTION] sur stderr), ASCII seul
# (un accent devient ?). Guillemets obligatoires autour de PDS(MEMBRE) :
# les parentheses sont lues par le shell.
upload() {
    echo "== Upload $1 -> $2"
    "${POWE[@]}" files upload file-to-data-set "$1" "$2"
}

# identique LOCAL DSN : la copie sur MVS est-elle identique au fichier local ?
# "download data-set" : IEBGENER vers le spool, recopie dans un fichier
# local, puis cmp octet par octet. Membre absent : download sort en code 3,
# cmp echoue.
identique() {
    rm -f "$TMP/copie"
    "${POWE[@]}" files download data-set "$2" -f "$TMP/copie" > /dev/null 2>&1 || true
    cmp -s "$1" "$TMP/copie"
}

# 4. LIBS : recompiler seulement si besoin.
#    Modules deja dans HERC01.TRAVEL.LOAD ("list all-members" : LISTDS ...
#    MEMBERS ; --rfj donne data.members). Liste lue une seule fois.
modules=" $("${POWE[@]}" --rfj files list all-members "$PDS_LOAD" \
    | python3 -c 'import json,sys; print(" ".join(json.load(sys.stdin)["data"].get("members", [])))') "

A_COMPILER=()
for entree in "${LIBS[@]}"; do
    base="${entree%%:*}"
    membre="${entree##*:}"
    echo "== Lib $membre a jour ?"

    # 4a. Tests, AVANT l'upload (qui ecraserait les copies sur MVS) :
    #     module present, source identique, JCL identique (une option de
    #     compilation changee doit aussi recompiler).
    present=0
    [[ "$modules" == *" $membre "* ]] && present=1
    if [[ $present == 0 ]]; then
        echo "   module $membre absent"
    elif ! identique "$base.cbl" "$PDS_CBL($membre)"; then
        echo "   source $membre modifiee"
    elif ! identique "$base.jcl" "$PDS_JCL($membre)"; then
        echo "   JCL $membre modifie"
    elif [[ $FORCE_LIBS == 1 ]]; then
        echo "   a jour, mais --force-libs : recompilation"
    else
        echo "   oui : pas de recompilation"
        continue
    fi

    # 4b. Effacer l'ancien module AVANT de deposer la nouvelle source. Si
    #     l'upload ou la compilation echoue (ou Ctrl-C), le module reste
    #     absent et le prochain lancement recompile. Sans cela, source neuve
    #     + vieux module passeraient pour "a jour".
    #     Seulement si le module existe : "delete" d'un MEMBRE absent echoue
    #     (code 3), contrairement a celui d'un dataset absent.
    if [[ $present == 1 ]]; then
        echo "== Effacement de $PDS_LOAD($membre)"
        "${POWE[@]}" files delete data-set "$PDS_LOAD($membre)" > /dev/null
    fi
    upload "$base.cbl" "$PDS_CBL($membre)"
    upload "$base.jcl" "$PDS_JCL($membre)"
    A_COMPILER+=("$membre")
done

# 5. PROGRAMMES : toujours renvoyes, sans test. Leur JCL les recompile a
#    chaque soumission, et recopie au passage la version courante des libs.
for entree in "${PROGRAMMES[@]}"; do
    base="${entree%%:*}"
    membre="${entree##*:}"
    upload "$base.cbl" "$PDS_CBL($membre)"
    upload "$base.jcl" "$PDS_JCL($membre)"
done

# 6. Controle : liste les membres de chaque PDS (LISTDS ... MEMBERS).
echo "== Membres"
for pds in "$PDS_CBL" "$PDS_JCL"; do
    echo "$pds : $("${POWE[@]}" files list all-members "$pds" | grep '^Membres')"
done

# 7. Soumet les JCL ranges dans le PDS (comme SUBMIT sous TSO).
#    --watch suit chaque job jusqu'a la fin et sort en code 3 si une etape
#    a un RC >= 8 (set -e arrete alors le script).

# 7a. Libs a recompiler : COB (IKFCBL00) + LKED (IEWL) vers
#     HERC01.TRAVEL.LOAD. Fait meme sans --run : source sur MVS et module
#     restent toujours d'accord. Avant les programmes, qui les relient.
for membre in "${A_COMPILER[@]}"; do
    echo "== Construction de la lib $membre ($PDS_JCL($membre))"
    "${POWE[@]}" jobs submit data-set "$PDS_JCL($membre)" --watch
done

# sortie_programme : lit le spool sur stdin et n'affiche que :
# - les erreurs de compilation (IKFnnnnI-E/C/D) et les references non
#   resolues de l'editeur de liens (IEW0132 = lib absente de SYSLIB) ;
# - tout ce que le programme a ecrit (DISPLAY), quel que soit le texte.
#   Dans le spool, la sortie de GO vient juste apres la derniere ligne du
#   listing LKED ("AUTHORIZATION CODE IS"), et s'arrete a la banniere de fin
#   de job (grandes lettres : un meme caractere repete 10 fois ou plus).
sortie_programme() {
    python3 -c '
import re, sys
lignes = sys.stdin.read().splitlines()
for l in lignes:
    if re.search(r"IKF\d+I-[WCED]|IEW0132", l):
        print(l)
debut = max((i for i, l in enumerate(lignes) if "AUTHORIZATION CODE IS" in l), default=None)
if debut is not None:
    sortie = []
    for l in lignes[debut + 1:]:
        if re.search(r"(\S)\1{9}", l) or l.startswith("****A"):
            break
        sortie.append(l)
    print("\n".join(sortie).strip("\n"))
'
}

# 7b. Programmes : COB, LKED (relie les libs), GO (execution).
if [[ $RUN == 1 ]]; then
    rc=0
    for entree in "${PROGRAMMES[@]}"; do
        membre="${entree##*:}"
        echo "== Soumission $PDS_JCL($membre)"
        "${POWE[@]}" jobs submit data-set "$PDS_JCL($membre)" --watch || rc=$?
        # Spool par nom de job : celui de la carte JOB (ici = membre).
        echo "== Sortie de $membre"
        "${POWE[@]}" jobs view spool-file-by-id "$membre" | sortie_programme
    done
    exit "$rc"
fi
