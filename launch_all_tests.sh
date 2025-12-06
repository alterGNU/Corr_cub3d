#!/usr/bin/env bash

# ============================================================================================================
# Launch cub3d unitests
# - This script take multiples options as arguments:
#   - If does not start with + or -:
#     - ADD to FUN_NAME_PATTERN list (list of name pattern to search for (unitests and funcheck))
#   - Else, is an option:
#     | NAME | ENABLE OPTION |  DESABLE OPTION  | DESCRIPTIONS                  |
#     |$BUIN | +b --built-in | -b --no-built-in | Check fun. used not forbidden |
#     |$COMP | +c --comp     | -c --no-comp     | Force the compilation         |
#     |$DLOG | +d --dlog     | -d --no-dlog     | Display the log files         |
#     |$EXEC | +e --exec     | -e --no-exec     | Exec the binaries files       |
#     |$FUNC | +f --funcheck | -f --no-funcheck | Run funcheck tooks            |
#     |$HELP | +h --help     | -h --no-help     | Display usage                 |
#     |$NORM | +n --norm     | -n --no-norm     | Run norminette tools          |
#     |$OPTI | +o --opti     | -o --no-opti     | Select only fun with unitests |
#     |$UNIT | +u --unitests | -u --no-unitests | Run cub3d's fun. unitests     |
#     |$VALG | +v --valgrind | -v --no-valgrind | Run valgrind tools            |
# ============================================================================================================
 
# =[ VARIABLES ]==============================================================================================
# -[ PATH/FOLDER/FILE ]---------------------------------------------------------------------------------------
ARGS=()                                                           # ☒ Copy of arguments pass to the script
for arg in "${@}";do ARGS+=( "${arg}" );done
SCRIPTNAME=${0##*\/}                                              # ☒ Script's name (no path)
PARENT_DIR=$(cd $(dirname ${0}) && pwd)                           # ☒ Name of parent directory (TEST_DIR)
MS_DIR=$(cd $(dirname ${PARENT_DIR}) && pwd)                      # ☒ Name of great-parent directory (CUB3D_DIR)
PROGRAMM="${MS_DIR}/cub3D"                                        # ☒ Object's name to test (here our executable)
LOG_DIR="${PARENT_DIR}/log/$(date +%Y_%m_%d/%Hh%Mm%Ss)"           # ☒ Name of the log folder
LOG_FAIL="${LOG_DIR}/list_errors.log"                             # ☒ File contains list of function that failed
DLOG_FILE="${LOG_DIR}/display.log"                                # ☒ File contains list of log to display
BSL_DIR="${PARENT_DIR}/BSL"                                   # ☒ Path to BSL folder
BIN_DIR="${PARENT_DIR}/bin"                                       # ☒ Path to bin folder (test binary)
LIBFT_A=$(find "${MS_DIR}" -type f -name "libft.a")               # ☒ libft.a static library
CUB3D=$(find "${MS_DIR}" -type f -name "cub3d")           # ☒ cub3d program
# -[ SCRIPT OPTION ]------------------------------------------------------------------------------------------
NB_ARG="${#}"                                                     # ☒ Number of script's arguments
BUIN=1                                                            # ☒ Check fun. used not forbidden 
COMP=0                                                            # ☒ Force the compilation         
DLOG=0                                                            # ☒ Display the log files         
EXEC=0                                                            # ☒ Exec the binaries files       
FUNC=0                                                            # ☒ Run funcheck tools            
HELP=0                                                            # ☒ Display usage                 
NORM=1                                                            # ☒ Run norminette tools          
OPTI=0                                                            # ☒ Select only fun with unitests 
UNIT=1                                                            # ☒ Run unitests                  
VALG=1                                                            # ☒ Run valgrind tools            
# -[ LISTS ]--------------------------------------------------------------------------------------------------
TEST_FILE=()                                                      # ☒ List of file.test to use to compare cub3d's return and bash --posix return's
for arg in $(find "${PARENT_DIR}/src" -type f -name "*.test");do TEST_FILE+=( "${arg}" );done
FUN_NAME_PATTERN=( )                                              # ☒ List of function name pattern passed as argument
FUN_ASKED_FOR=( )                                                 # ☒ List of function matching given pattern names as argument
EXCLUDE_NORMI_FOLD=( "tests" "${PARENT_DIR##*\/}" )               # ☒ List of folder to be ignore by norminette
FUN_TO_EXCLUDE=( "_fini" "main" "_start" "_init" "_end" "_stop" ) # ☒ List of LINUX's function names to exclude
FUN_TO_EXCLUDE+=( "dyld_stub_binder" "stub_binder" )              # ☒ List of MacOS's function names to exclude 
FUN_TO_TEST=( )                                                   # ☒ List of user created function specific to cub3d
FUN_WITH_UNITEST=( )                                              # ☒ List of user created function specific to cub3d that have a test founded
HOMEMADE_FUNUSED=( )                                              # ☒ List of user created function in cub3d
BUILTIN_FUNUSED=( )                                               # ☒ List of build-in function 
LIBFT_FUN=( )                                                     # ☒ List of user created function in libft.a
ALLOWED_FUN=("read" "write" "open" "close" "printf" "malloc" "free" "perror" "strerror" "exit" "gettimeofday")
                                                                  # ☒ List of allowed functions
OBJ=( )                                                           # ☒ List of object.o (no main function in it)
# add to OBJ list all '.o' files founded in cub3d/build/ folders that do not contains a main() function
for obj in $(find ${MS_DIR}/build -type f -name '*.o');do if ! nm "${obj}" 2>/dev/null | grep -qE 'T [_]*main';then OBJ+=( "${obj}" );fi;done
# -[ COMMANDS ]-----------------------------------------------------------------------------------------------
CC="cc -Wall -Wextra -Werror -I${MS_DIR}/include -I${MS_DIR}/libft/include ${OBJ[@]}"
VAL_ERR=42
VALGRIND="valgrind --leak-check=full --track-fds=yes --show-leak-kinds=all --error-exitcode=${VAL_ERR}"
# -[ LAYOUT ]-------------------------------------------------------------------------------------------------
LEN=100                                                            # ☑ Width of the box
# -[ COLORS ]-------------------------------------------------------------------------------------------------
E="\033[0m"                                                        # ☒ END color balise
N0="\033[0;30m"                                                    # ☒ START BLACK
R0="\033[0;31m"                                                    # ☒ START RED
RU="\033[4;31m"                                                    # ☒ START RED UNDERSCORED
V0="\033[0;32m"                                                    # ☒ START GREEN
M0="\033[0;33m"                                                    # ☒ START BROWN
Y0="\033[0;93m"                                                    # ☒ START YELLOW
YU="\033[4;93m"                                                    # ☒ START YELLOW UNDERSCORED
B0="\033[0;34m"                                                    # ☒ START BLUE
BU="\033[4;34m"                                                    # ☒ START BLUE
BC0="\033[0;36m"                                                   # ☒ START AZURE
BCU="\033[4;36m"                                                   # ☒ START AZURE UNDERSCORED
P0="\033[0;35m"                                                    # ☒ START PINK
G0="\033[2;37m"                                                    # ☒ START GREY
GU="\033[4;37m"                                                    # ☒ START GREY
CT="\033[97;100m"                                                  # ☒ START TITLE
# =[ SOURCES ]================================================================================================
source ${BSL_DIR}/src/check42_norminette.sh
source ${BSL_DIR}/src/print.sh
# =[ FUNCTIONS ]==============================================================================================
# -[ USAGE ]--------------------------------------------------------------------------------------------------
# Display usage with arg1 as error_msg and arg2 as exit_code both optionnal
script_usage()
{
    local exit_value=0
    local entete="${BU}Usage:${R0}  \`${V0}./${SCRIPTNAME} ${M0}[+-][a,b,c,d,e,f,h,n,o,u,v] [<name_pattern>, ...]${R0}\`${E}"
    if [[ ${#} -eq 2 ]];then
        local entete="${RU}[Err:${2}] Wrong usage${R0}: ${1}${E}\n${BU}Usage:${R0}  \`${V0}./${SCRIPTNAME} ${M0}[+-][a,b,c,d,e,f,h,n,o,u,v] [<name_pattern>, ...]${R0}\`${E}"
        local exit_value=${2}
    fi
    echo -e "${entete}"
    echo -e " 🔹 ${BCU}PRE-REQUISITES:${E}"
    echo -e "    ${BC0}‣ ${BCU}i)${E} : To be cloned inside the project ${M0}path/cub3d/${E} to be tested."
    echo -e "    ${BC0}‣ ${BCU}ii)${E}: The programm ${M0}path/cub3d/${V0}cub3d${E} has to be compiled before using ${V0}./${SCRIPTNAME}${E}."
    echo -e " 🔹 ${BCU}ARGUMENTS:${E}"
    echo -e "    ${BC0}‣ ${E}any arg that does not start with ${V0}+${E} or ${R0}-${E} symbol is considered as an ${M0}<name_pattern>${E} ${G0}(will be use to seach on unitests and funcheck file)${E}"
    echo -e " 🔹 ${BCU}OPTIONS:${E}"
    echo -e "    ${CT}| VAR. NAME |  Enable options |  Desable options  | Descritions                          |${E}"
    echo -e "    |   ${BC0}NONE ${E}   | ${V0}+${M0}a${E}, ${V0}--${M0}all       ${E}| ${R0}-${M0}a ${E},${R0}--no-${M0}all      ${E}| Enable/Desable all following options |"
    echo -e "    |   ${BC0}\$BUIN${E}   | ${V0}+${M0}b${E}, ${V0}--${M0}built-in  ${E}| ${R0}-${M0}b ${E},${R0}--no-${M0}built-in ${E}| Check fun. used not forbidden        |"
    echo -e "    |   ${BC0}\$COMP${E}   | ${V0}+${M0}c${E}, ${V0}--${M0}comp      ${E}| ${R0}-${M0}c ${E},${R0}--no-${M0}comp     ${E}| Force the compilation                |"
    echo -e "    |   ${BC0}\$DLOG${E}   | ${V0}+${M0}d${E}, ${V0}--${M0}dlog      ${E}| ${R0}-${M0}d ${E},${R0}--no-${M0}dlog     ${E}| Display the log files                |"
    echo -e "    |   ${BC0}\$EXEC${E}   | ${V0}+${M0}e${E}, ${V0}--${M0}exec      ${E}| ${R0}-${M0}e ${E},${R0}--no-${M0}exec     ${E}| Exec the binaries files              |"
    echo -e "    |   ${BC0}\$FUNC${E}   | ${V0}+${M0}f${E}, ${V0}--${M0}funcheck  ${E}| ${R0}-${M0}f ${E},${R0}--no-${M0}funcheck ${E}| Run funcheck tooks                   |"
    echo -e "    |   ${BC0}\$HELP${E}   | ${V0}+${M0}h${E}, ${V0}--${M0}help      ${E}| ${R0}-${M0}h ${E},${R0}--no-${M0}help     ${E}| Display usage                        |"
    echo -e "    |   ${BC0}\$NORM${E}   | ${V0}+${M0}n${E}, ${V0}--${M0}norm      ${E}| ${R0}-${M0}n ${E},${R0}--no-${M0}norm     ${E}| Run norminette tools                 |"
    echo -e "    |   ${BC0}\$OPTI${E}   | ${V0}+${M0}o${E}, ${V0}--${M0}opti      ${E}| ${R0}-${M0}o ${E},${R0}--no-${M0}opti     ${E}| Select only fun with unitests        |"
    echo -e "    |   ${BC0}\$UNIT${E}   | ${V0}+${M0}u${E}, ${V0}--${M0}unitests  ${E}| ${R0}-${M0}u ${E},${R0}--no-${M0}unitests ${E}| Run cub3d's functions unitests       |"
    echo -e "    |   ${BC0}\$VALG${E}   | ${V0}+${M0}v${E}, ${V0}--${M0}valgrind  ${E}| ${R0}-${M0}v ${E},${R0}--no-${M0}valgrind ${E}| Run valgrind tools                   |"
    exit ${exit_value}
}
# -[ MAX() ]--------------------------------------------------------------------------------------------------
max()
{
    if (($1 > $2));then
        echo $1
    else
        echo $2
    fi
}
# -[ PRINT_RELATIF_PATH() ]-----------------------------------------------------------------------------------
# substract pwd from arg1 abs-path given
print_shorter_path() { echo "${1/${PWD}/.}" ; }
# -[ EXEC_ANIM_IN_BOX ]---------------------------------------------------------------------------------------
# Takes 2args: arg1:<cmd> [arg2:<title>]
# exec command passed as arg1 while displaying animation, return result in a box colored red if cmd failed, green else
exec_anim_in_box()
{
    [[ ( ${#} -gt 2 ) ]] && { echo -e "\033[1;31mWRONG USAGE of:\033[1;36mexec_anim()\033[1;31m, this function take 2 arguments max.\033[0m" && exit 3 ; }
    local frames=( 🕛  🕒  🕕  🕘 )
    local delay=0.15
    local cmd="${1}"
    [[ ${#} -eq 2 ]] && local boxtitle="${2}" || local boxtitle="${cmd}"
    local tmpfile=$(mktemp "${TMPDIR:-/tmp}/exec_anim_${cmd%% *}_XXXXXX")
    trap '[[ -f "${tmpfile}" ]] && rm -f "${tmpfile}"' EXIT RETURN
    ${1} > "${tmpfile}" 2>&1 &
    local pid=${!}
    while kill -0 ${pid} 2>/dev/null; do
        for frame in "${frames[@]}"; do printf "${frame} \033[1;40mwaiting for cmd:${1}\033[0m\r" && sleep ${delay} ; done
    done
    printf "\r\033[K" && wait ${pid}
    local exit_code=${?}
    [[ ${exit_code} -eq 0 ]] && local color="green" || local color="red"
    print_box_title -t 1 -c ${color} "${boxtitle}"
    while IFS= read -r line; do
        echol -i 0 -c ${color} -t 1 "${line}"
    done < "${tmpfile}"
    print_last -t 1 -c ${color}
    return ${exit_code}
}

# -[ DISPLAY_START ]------------------------------------------------------------------------------------------
display_start()
{
    local OPTIONS=( " ${YU}cub3d's OPTIONS:${E}" )
    [[ ${BUIN} -gt 0 ]] && OPTIONS+=( "     🔸 ${YU}BUIN${Y0} :Check fun. used not forbidden : ${V0}✓ Enable${E}" ) || OPTIONS+=( "     🔸 ${YU}BUIN${Y0} :Check fun. used not forbidden : ${R0}✘ Desable${E}" )
    [[ ${COMP} -gt 0 ]] && OPTIONS+=( "     🔸 ${YU}COMP${Y0} :Force the compilation         : ${V0}✓ Enable${E}" ) || OPTIONS+=( "     🔸 ${YU}COMP${Y0} :Force the compilation         : ${R0}✘ Desable${E}" )
    [[ ${DLOG} -gt 0 ]] && OPTIONS+=( "     🔸 ${YU}DLOG${Y0} :Display the log files         : ${V0}✓ Enable${E}" ) || OPTIONS+=( "     🔸 ${YU}DLOG${Y0} :Display the log files         : ${R0}✘ Desable${E}" )
    [[ ${EXEC} -gt 0 ]] && OPTIONS+=( "     🔸 ${YU}EXEC${Y0} :Exec the binaries files       : ${V0}✓ Enable${E}" ) || OPTIONS+=( "     🔸 ${YU}EXEC${Y0} :Exec the binaries files       : ${R0}✘ Desable${E}" )
    [[ ${FUNC} -gt 0 ]] && OPTIONS+=( "     🔸 ${YU}FUNC${Y0} :Run funcheck on funcheck files: ${V0}✓ Enable${E}" ) || OPTIONS+=( "     🔸 ${YU}FUNC${Y0} :Run funcheck on funcheck files: ${R0}✘ Desable${E}" )
    [[ ${HELP} -gt 0 ]] && OPTIONS+=( "     🔸 ${YU}HELP${Y0} :Display usage                 : ${V0}✓ Enable${E}" ) || OPTIONS+=( "     🔸 ${YU}HELP${Y0} :Display usage                 : ${R0}✘ Desable${E}" )
    [[ ${NORM} -gt 0 ]] && OPTIONS+=( "     🔸 ${YU}NORM${Y0} :Run norminette tools          : ${V0}✓ Enable${E}" ) || OPTIONS+=( "     🔸 ${YU}NORM${Y0} :Run norminette tools          : ${R0}✘ Desable${E}" )
    [[ ${OPTI} -gt 0 ]] && OPTIONS+=( "     🔸 ${YU}OPTI${Y0} :Select only fun with unitests : ${V0}✓ Enable${E}" ) || OPTIONS+=( "     🔸 ${YU}OPTI${Y0} :Select only fun with unitests : ${R0}✘ Desable${E}" )
    [[ ${UNIT} -gt 0 ]] && OPTIONS+=( "     🔸 ${YU}UNIT${Y0} :Run cub3d's fun. unitests     : ${V0}✓ Enable${E}" ) || OPTIONS+=( "     🔸 ${YU}UNIT${Y0} :Run cub3d's fun. unitests     : ${R0}✘ Desable${E}" )
    [[ ${VALG} -gt 0 ]] && OPTIONS+=( "     🔸 ${YU}VALG${Y0} :Run valgrind                  : ${V0}✓ Enable${E}" ) || OPTIONS+=( "     🔸 ${YU}VALG${Y0} :Run valgrind                  : ${R0}✘ Desable${E}" )
                                                                                 
    print_in_box -t 2 -c y \
        "    ${Y0}                                                                                  ${E}" \
        "    ${Y0} ▄█████ ▄▄ ▄▄ ▄▄▄▄  ████▄ ▄▄▄▄    ██  ██ ▄▄  ▄▄ ▄▄ ▄▄▄▄▄▄ ▄▄▄▄▄  ▄▄▄▄ ▄▄▄▄▄▄ ▄▄▄▄ ${E}" \
        "    ${Y0} ██     ██ ██ ██▄██  ▄▄██ ██▀██   ██  ██ ███▄██ ██   ██   ██▄▄  ███▄▄   ██  ███▄▄ ${E}" \
        "    ${Y0} ▀█████ ▀███▀ ██▄█▀ ▄▄▄█▀ ████▀   ▀████▀ ██ ▀██ ██   ██   ██▄▄▄ ▄▄██▀   ██  ▄▄██▀ ${E}" \
        "    ${Y0}                                                                                  ${E}" \
        "  🔶 ${OPTIONS[@]}"
}

# -[ CHECK_FUNUSED ]------------------------------------------------------------------------------------------
# Check that functions used by program are allowed: If elem of BUILTIN_FUNUSED not in ALLOWED_FUN
# - GREEN -> allowed
# - GREY  -> called by main() function
# - RED   -> not allowed
check_funused()
{
    local tot=0
    local args=( )
    local main_calls=( )
    local glibc_calls=( )
    for function in "${BUILTIN_FUNUSED[@]}";do
        local fun="${function%%\@*}"
        if [[ ( "${fun}" == "_"* ) || ( "${FUN_TO_EXCLUDE[@]}" =~ "${fun}" ) ]];then
            main_calls+=( "${G0}• ${fun%%\@*}()${E}" )
        else
            if [[ "${ALLOWED_FUN[@]}" =~ "${fun}" ]];then
                glibc_calls+=( "${V0}✓ ${fun}()${E}" )
            else
                glibc_calls+=( "${R0}✗ ${fun}() ${Y0}➽ ${M0}${function##*\@}${E}" )
                tot=$(( tot + 1 ))
            fi
        fi
    done
    if [[ "${#main_calls[@]}" -ne 0 ]];then
        echo "🔹 ${BCU}main() built_in calls:${E}"
        for fun in "${main_calls[@]}";do echo "   ${fun}";done
        echo "🔹 ${BCU}GLIBC built_in calls:${E}"
        for fun in "${glibc_calls[@]}";do echo "   ${fun}";done
    else
        for fun in "${glibc_calls[@]}";do echo " ${fun}";done
    fi
    return ${tot}
}


# -[ LAUNCH_UNITESTS() ]--------------------------------------------------------------------------------------
# Function that launch unitests for each <function_name> found in <list_name> given as arg1 or arg2.
# Compile then Exec unitests will creating log_files then returns the numbers of errors encountred.
# - USAGE:
#   - Take one to two arguments:
#     - arg1 (mandatory): list_name of a list that contains all the <function_name> fount in object.
#       - `launch_unitests FUN_TO_TEST` --> will launch unitests for all function in list name: FUN_TO_TEST
#     - arg2 (optionnal): list_name of a list that contains all the <function_name> THAT HAVE TO BE FOUND in object.
#       - `launch_unitests LST1 LST2` --> will launch unitests for all fun in LST2 and LST1, if not in LST1=ERROR
# - LOG FILES PRODUCE:
# - ../log/<date>/<time>/${LOG_FAIL}                --> File contains list of all encountred errors, format="<fun_name>\t<error_type>"
#                                                   └-> error_type = {compilation, errors, leaks, missing}                        
# - ../log/<date>/<time>/<fun_name>/                --> Folder created for each function tested (remove if empty at the end)
# - ../log/<date>/<time>/<fun_name>/comp_stderr.txt --> File created only when compilation failed: contains compilation error messages.
# - ../log/<date>/<time>/<fun_name>/exec.log        --> File contains execution's outputs (stdout && stderr)
# - ../log/<date>/<time>/<fun_name>/leaks.log       --> File contains valgrind's outputs (stdout && stderr)
# - PSEUDO-CODE:
#   - (0): INPUT VALIDATION
#     - Check number of args given valid, else exit.
#     - Build the 2 needed arrays: FUN_FOUND (list of fun found in obj), FUN_MANDA (list of fun needed)
#       - If only arg1    --> FUN_FOUND == FUN_MANDA == ${arg1[@]}
#       - If arg1 && arg2 --> FUN_FOUND == ${arg1[@]} && FUN_MANDA == ${arg2[@]}
#     - Check if builded lists valid, else exit.
#   - (1): LOOP TROUGHT FUN_MANDA
#     - if <fun> not in FUN_FOUND --> nb_err++;
#     - else check if an unitests exist:
#        - (1.0) Create directory ../log/<date>/<time>/<fun_name>/
#        - (1.1) COMPILE if compilation needed or forced, if compilation fail --> nb_err++ && create comp_stderr.txt
#        - (1.2) EXEC if compilation succed, redir stdout && stderr to exec.log, if exec failed --> nb_err++
#        - (1.3) VALGRIND if compilation succed, redir stdout && stderr to leaks.log, if valgrind failed --> nb_err++
#        - (1.4) If ../log/<date>/<time>/<fun_name>/ empty, remove the directory
launch_unitests()
{
    # INPUT VALIDATION
    [[ ${#} -eq 0 || ${#} -gt 2 ]] && { echo "${R0}WRONG USAGE OF launch_unitests():wrong number of argument" && exit 2 ; }
    local -a FUN_FOUND=( )     # list of all fun found in object (==arg1)
    local -a FUN_MANDA=( ) # list of all fun needed, (set as arg2 if given, else is a copy of arg1)
    eval "local -a FUN_FOUND=( \"\${${1}[@]}\" )"
    [[ -n ${2} ]] && eval "local -a FUN_MANDA+=( \"\${${2}[@]}\" )" || eval "local -a FUN_MANDA+=( \"\${${1}[@]}\" )"
    [[ ${#FUN_FOUND[@]} -eq 0 ]] && { echo "${R0}WRONG USAGE OF launch_unitests():FUN_FOUND created is an empty list" && exit 2 ; }
    [[ ${#FUN_MANDA[@]} -eq 0 ]] && { echo "${R0}WRONG USAGE OF launch_unitests():FUN_MANDA created is an empty list" && exit 2 ; }

    local nb_err=0
    for fun in ${FUN_MANDA[@]};do
        echo "🔹${BCU}${fun}():${E}"
        if [[ "${FUN_FOUND[@]}" =~ "${fun}" ]];then
            local FUN_LOG_DIR="${LOG_DIR}/${fun}"
            [[ ! -d ${FUN_LOG_DIR} ]] && mkdir -p ${FUN_LOG_DIR}
            local test_main=$(find "${PARENT_DIR}/src/unitests" -type f -name *"${fun}.c")
            local test_txt=$(find "${PARENT_DIR}/src/unitests" -type f -name *"${fun}.txt")
            if [[ -n "${test_main}" ]];then
                # STEP 1 : COMPILATION --> IF NO BINARY OR IF SOURCES NEWER THAN BINARY
                [[ ! -d ${BIN_DIR} ]] && mkdir -p ${BIN_DIR}
                exe="${BIN_DIR}/test_${fun}"
                echo -en " ${BC0} ⤷${E} ⚙️  ${GU}Compilation:${E}"
                # cases where compilation needed: (1:no binary),(2:unitests source code newer than bin),(3:text exist and newer than binary), (4:libft.a newer than bin), (5:cub3d newer than bin)
                if [[ ( "${COMP}" -gt 0 ) || ( ! -f "${exe}" ) || ( "${test_main}" -nt "${exe}" ) || ( -n "${test_txt}" && "${test_txt}" -nt "${exe}" ) || ( "${LIBFT_A}" -nt "${exe}" ) || ( "${CUB3D}" -nt "${exe}" ) ]];then
                    local res_compile=$(${CC} ${test_main} ${LIBFT_A} -o ${exe} > "${FUN_LOG_DIR}/comp_stderr.log" 2>&1 && echo ${?} || echo ${?})
                    if [[ "${res_compile}" -eq 0 ]];then
                        [[ ${COMP} -gt 0 ]] && echo -en " ✅ ${V0} Successfull. ${G0}(forced)${E}\n" || echo -en " ✅ ${V0} Successfull.${E}\n"
                        rm "${FUN_LOG_DIR}/comp_stderr.log"
                    else
                        echo -e "${FUN_LOG_DIR}/comp_stderr.log" >> ${DLOG_FILE}
                        local log_comp_fail=$(print_shorter_path ${FUN_LOG_DIR}/comp_stderr.log)
                        nb_err=$(( nb_err + 1 ))
                        echo -e "${fun}\tcompilation\t${log_comp_fail}" >> ${LOG_FAIL}
                        echo -en " ❌ ${R0}Compilation failed.   ${G0}Here the first 10 lines (out of $(cat ${log_comp_fail} | wc -l))${E}\n"
                        head -n 10 ${log_comp_fail} | sed 's/^/\x1b[0;31m       /'
                        continue
                    fi
                else
                    echo -en " ☑️  ${BC0} Not needed.\n${E}"
                fi
                # STEP 2 : EXECUTION
                echo -en " ${BC0} ⤷${E} 🚀 ${GU}Execution  :${E}"
                if [[ -f "${test_txt}" ]];then
                    local res_tests=$(${exe} "$(dirname "${test_txt}")" "${FUN_LOG_DIR}" > "${FUN_LOG_DIR}/exec.log" 2>&1 && echo ${?} || echo ${?})
                else
                    local res_tests=$(${exe} > "${FUN_LOG_DIR}/exec.log" 2>&1 && echo ${?} || echo ${?})
                fi
                echo "EXIT_VALUE=${res_tests}" >> "${FUN_LOG_DIR}/exec.log"
                if [[ ${res_tests} -eq 0 ]];then
                    echo -en " ✅ ${V0} No error detected.${E}\n"
                else
                    local exec_log_file=$(print_shorter_path ${FUN_LOG_DIR}/exec.log)
                    nb_err=$(( nb_err + 1 ))
                    if [[ ${res_tests} == 139 ]];then
                        echo -e "${fun}\tsegfault\t${exec_log_file}" >> ${LOG_FAIL}
                        echo -en " ❌ ${R0} Error detected = 🚩SEGMENTATION FAULT🚩 (exec return value=${res_tests})\n"
                    else
                        echo -e "${fun}\terrors\t${exec_log_file}" >> ${LOG_FAIL}
                        echo -en " ❌ ${R0} Error detected (exec return value=${res_tests})\n"
                    fi
                    echo "      🔸${Y0}check log file 👉 ${M0}${exec_log_file}${E}"
                fi
                # STEP 3 : VALGRIND
                if [[ ${VALG} -gt 0 ]];then
                    if [[ ${res_tests} -ne 139 ]];then
                        echo -en " ${BC0} ⤷${E} 🚰 ${GU}Valgrind   :${E}"
                        if [[ -f "${test_txt}" ]];then
                            local res_val=$(${VALGRIND} ${exe} "$(dirname "${test_txt}")" "${FUN_LOG_DIR}" > "${FUN_LOG_DIR}/leaks.log" 2>&1 && echo ${?} || echo ${?})
                        else
                            local res_val=$(${VALGRIND} ${exe} > "${FUN_LOG_DIR}/leaks.log" 2>&1 && echo ${?} || echo ${?})
                        fi
                        if [[ ${res_val} -ne ${VAL_ERR} ]];then
                            echo -en " ✅ ${V0} No leak detected.${E}\n"
                        else
                            local leaks_log_file=$(print_shorter_path ${FUN_LOG_DIR}/leaks.log)
                            nb_err=$(( nb_err + 1 ))
                            echo -e "${fun}\tleaks\t${leaks_log_file}" >> ${LOG_FAIL}
                            echo -en " ❌ ${R0} Leak detected (valgrind return value=${res_val})\n"
                            echo "      🔸${Y0}check log file 👉 ${M0}${leaks_log_file}${E}"
                        fi
                        [[ ${DLOG} -gt 0 ]] && echo -e "${FUN_LOG_DIR}/leaks.log" >> ${DLOG_FILE}
                    fi
                else
                    [[ ${DLOG} -gt 0 ]] && echo -e "${FUN_LOG_DIR}/exec.log" >> ${DLOG_FILE}
                fi
            else
                echo " ${BC0} ⤷${E} ✖️  ${G0}Tests not found.${E}"
                rmdir "${FUN_LOG_DIR}" > /dev/null 2>&1
            fi
        else
            echo -e "${fun}\tmissing\t⭙" >> ${LOG_FAIL}
            nb_err=$(( nb_err + 1 ))
            echo " ${BC0} ⤷${E} ❌ ${R0}Function not found in object.${E}"
        fi
    done
    return ${nb_err}
}
# -[ LAUNCH_FUNCHECK ]----------------------------------------------------------------------------------------
# Launch funcheck test:
# IF FUN_NAME_PATTERN list not empty, launch matching funcheck for fun.name passed as argument to script
# ELSE, launch all funcheck files founded
launch_funcheck()
{
    print_in_box -t 2 -c y \
        "                          ${Y0}  ___                 _              _                    ${E}" \
        "                          ${Y0} | __|_  _  _ _   __ | |_   ___  __ | |__                 ${E}" \
        "                          ${Y0} | _|| || || ' \ / _|| ' \ / -_)/ _|| / /                 ${E}" \
        "                          ${Y0} |_|  \_,_||_||_|\__||_||_|\___|\__||_\_\                 ${E}" \
        "   "
    local nb_err=0
    local FUNCHECK_LIST=( )
    if [[ ${#FUN_NAME_PATTERN[@]} -eq 0 ]];then
        for file in $(find "${PARENT_DIR}/src/funcheck" -type f -name "funcheck_*");do FUNCHECK_LIST+=( "$(basename ${file})"  );done
    else
        for funame in ${FUN_NAME_PATTERN[@]};do
            for file in $(find "${PARENT_DIR}/src/funcheck" -type f -name "*${funame}*");do
                FUNCHECK_LIST+=( "$(basename ${file})" )
            done
        done
    fi
    for file in ${FUNCHECK_LIST[@]};do
        local fun=${file##*funcheck_}
        fun=${fun%%\.c*}
        print_in_box -t 1 -c m " 🔸 ${Y0}funcheck for ${fun}():${E}"
        local FUN_LOG_DIR="${LOG_DIR}/${fun}"
        [[ ! -d ${FUN_LOG_DIR} ]] && mkdir -p ${FUN_LOG_DIR}
        local test_main=$(find "${PARENT_DIR}/src/funcheck" -type f -name "*${fun}.c")
        local test_txt=$(find "${PARENT_DIR}/src" -type f -name *"${fun}.txt")
        # STEP 1 : COMPILATION --> IF NO BINARY OR IF SOURCES NEWER THAN BINARY
        [[ ! -d ${BIN_DIR} ]] && mkdir -p ${BIN_DIR}
        exe="${BIN_DIR}/funcheck_${fun%%\.c*}"
        local res_compile=0
        # cases where compilation needed: (1:if -c option enable),(2:if no bin alwready found),(3:if source code newer than bin),(3:text exist and newer than binary), (4:libft.a newer than bin), (5:if cub3d newer than bin)
        if [[ ( "${COMP}" -gt 0 ) || ( ! -f "${exe}" ) || ( "${test_main}" -nt "${exe}" ) || ( -n "${test_txt}" && "${test_txt}" -nt "${exe}" ) || ( "${LIBFT_A}" -nt "${exe}" ) || ( "${CUB3D}" -nt "${exe}" ) ]];then
            res_compile=$(${CC} ${test_main} ${LIBFT_A} -o ${exe} > "${FUN_LOG_DIR}/comp_stderr.log" 2>&1 && echo ${?} || echo ${?})
            if [[ "${res_compile}" -eq 0 ]];then
                [[ ${COMP} -gt 0 ]] && print_in_box -t 0 -c m "${M0}1) ⚙️  Compilation: ✅ ${V0} SUCCESS. ${G0}(forced)${E}" || print_in_box -t 0 -c m "${M0}1) ⚙️  Compilation: ✅ ${V0} SUCCESS.${E}"
                rm "${FUN_LOG_DIR}/comp_stderr.log"
            else
                local log_comp_fail=$(print_shorter_path ${FUN_LOG_DIR}/comp_stderr.log)
                nb_err=$(( nb_err + 1 ))
                echo -e "${fun}\tcomp-funcheck\t${log_comp_fail}" >> ${LOG_FAIL}
                print_in_box -t 0 -c m "${M0}1) ⚙️  Compilation: ❌ ${R0}FAILED${E}"
                sed 's/^/\x1b[0;31m       /' ${log_comp_fail}
                continue
            fi
        else
            print_in_box -t 0 -c m "${M0}1) ⚙️  Compilation: ☑️  ${BC0} Not needed.${E}"
        fi
        if [[ ( ${res_compile} -eq 0 ) && ( -f ${exe} ) ]];then
            print_in_box -t 0 -c m "${M0}2) 🚀 Execution  :${E}"
            local short_exe=$(print_shorter_path ${exe})
            local fun_log_file=$(print_shorter_path ${FUN_LOG_DIR}/funcheck.log)
            if [[ -f "${test_txt}" ]];then
                local arg_file=$(dirname "${test_txt}")
                script -q -c "funcheck ${short_exe} ${arg_file};echo \$? > ${FUN_LOG_DIR}/tmp.txt" -a ${fun_log_file}
            else
                script -q -c "funcheck ${short_exe};echo \$? > ${FUN_LOG_DIR}/tmp.txt" -a ${fun_log_file}
            fi
            local fun_res=$(< "${FUN_LOG_DIR}/tmp.txt")
            rm -f "${FUN_LOG_DIR}/tmp.txt"
            if [[ "${fun_res}" == "0" ]]; then
                print_in_box -t 1 -c g "🔸${Y0}FUNCHECK for ${fun}:${V0} ✅ PASS${E}" "🔸${Y0}check log file 👉 ${M0}${fun_log_file}${E}"
            else
                nb_err=$(( nb_err + 1 ))
                echo -e "${fun}\texec_funcheck\t${leaks_log_file}" >> ${LOG_FAIL}
                print_in_box -t 1 -c r "🔸${Y0}FUNCHECK for ${fun}:${R0} ❌ FAIL${E}" "🔸${Y0}check log file 👉 ${M0}${fun_log_file}${E}"
            fi
        else
            print_in_box -t 0 -c m "${M0}2) 🚀 Execution  : ❌ ${R0}NOT POSSIBLE${E}"
        fi
    done
    return ${nb_err}
}
# -[ EXEC_BINARY() ]------------------------------------------------------------------------------------------
# exec binary without producing any log file (launch_unitests without log)
# If VALG option enable, run in valgrind mode
exec_binary()
{
    print_in_box -t 2 -c y \
        " ${Y0}      ___  __  __  ___    ___      ___   ___   _  _     _     ___  __   __ ${E}" \
        " ${Y0}     | __| \ \/ / | __|  / __|    | _ ) |_ _| | \| |   /_\   | _ \ \ \ / / ${E}" \
        " ${Y0}     | _|   >  <  | _|  | (__     | _ \  | |  | .' |  / _ \  |   /  \ V /  ${E}" \
        " ${Y0}     |___| /_/\_\ |___|  \___|    |___/ |___| |_|\_| /_/ \_\ |_|_\   |_|   ${E}" \
        "   "
    [[ ${#} -eq 0 || ${#} -gt 2 ]] && { echo "${R0}WRONG USAGE OF exec_binary():wrong number of argument" && exit 2 ; }
    local -a FUN_LIST=( ) # list of all fun needed, (set as arg2 if given, else is a copy of arg1)
    [[ -n ${2} ]] && eval "local -a FUN_LIST+=( \"\${${2}[@]}\" )" || eval "local -a FUN_LIST+=( \"\${${1}[@]}\" )"
    [[ ${#FUN_LIST[@]} -eq 0 ]] && { echo "${R0}WRONG USAGE OF exec_binary():FUN_LIST created is an empty list" && exit 2 ; }

    for fun in ${FUN_LIST[@]};do
        local FUN_LOG_DIR="${LOG_DIR}/${fun}"
        [[ ! -d ${FUN_LOG_DIR} ]] && mkdir -p ${FUN_LOG_DIR}
        local test_main=$(find "${PARENT_DIR}/src/unitests" -type f -name *"${fun}.c")
            if [[ -f ${test_main} ]];then
            print_box_title -t 1 -c m " 🔶  ${YU}${fun}()${E} ${Y0}:${E}"
            # STEP 1 : COMPILATION --> IF NO BINARY OR IF SOURCES NEWER THAN BINARY
            local test_txt=$(find "${PARENT_DIR}/src/unitests" -type f -name *"${fun}.txt")
            [[ ! -d ${BIN_DIR} ]] && mkdir -p ${BIN_DIR}
            exe="${BIN_DIR}/test_${fun}"
            # cases where compilation needed: (1:no binary),(2:unitests source code newer than bin),(3:text exist and newer than binary), (4:libft.a newer than bin), (5:cub3d newer than bin)
            if [[ ( "${COMP}" -gt 0 ) || ( ! -f "${exe}" ) || ( "${test_main}" -nt "${exe}" ) || ( -n "${test_txt}" && "${test_txt}" -nt "${exe}" ) || ( "${LIBFT_A}" -nt "${exe}" ) || ( "${CUB3D}" -nt "${exe}" ) ]];then
                local res_compile=$(${CC} ${test_main} ${LIBFT_A} -o ${exe} > "${FUN_LOG_DIR}/comp_stderr.log" 2>&1 && echo ${?} || echo ${?})
                if [[ "${res_compile}" -eq 0 ]];then
                    [[ ${COMP} -gt 0 ]] && echol -i 0 -c m -t 1 " ⚙️  ${BU}Compilation:${E}  ✅ ${V0} Successfull. ${G0}(forced)${E}" || echol -i 0 -c m -t 1 " ⚙️  ${BU}Compilation:${E}  ✅ ${V0} Successfull.${E} "
                    rm "${FUN_LOG_DIR}/comp_stderr.log"
                else
                    echo -e "${FUN_LOG_DIR}/comp_stderr.log" >> ${DLOG_FILE}
                    local log_comp_fail=$(print_shorter_path ${FUN_LOG_DIR}/comp_stderr.log)
                    echo -e "${fun}\tcompilation\t${log_comp_fail}" >> ${LOG_FAIL}
                    echol -i 0 -c m -t 1 " ⚙️  ${BU}Compilation:${E}  ❌ ${R0}Compilation failed.   ${G0}Here the first 10 lines (out of $(cat ${log_comp_fail} | wc -l))${E}"
                    head -n 10 ${log_comp_fail} | sed 's/^/\x1b[0;31m       /'
                    continue
                fi
            else
                echol -i 0 -c m -t 1 " ⚙️  ${BU}Compilation:${E}  ☑️  ${BC0} Not needed.${E}"
            fi
            # STEP 2 : EXECUTION
            echol -i 0 -c m -t 1 " 🚀 ${BU}Execution  :${E}"
            print_last -t 1 -c m
            if [[ ${VALG} -gt 0 ]];then
                if [[ -f "${test_txt}" ]];then
                    ${VALGRIND} ${exe} "$(dirname ${test_txt})" "${FUN_LOG_DIR}"
                else                              
                    ${VALGRIND} ${exe}
                fi
            else
                if [[ -f "${test_txt}" ]];then
                    ${exe} "$(dirname ${test_txt})" "${FUN_LOG_DIR}"
                else
                    ${exe}
                fi
            fi
        else
            print_in_box -t 1 -c m " ✖️  ${YU}${fun}()${E} ${G0}(No unitest.c found)${E}"
        fi
    done
}
# -[ EXEC_TESTS() ]-------------------------------------------------------------------------------------------
# exec cub3d's tests
exec_tests()
{
    local nb_err=0
    [[ ! -d ${LOG_DIR}/tests ]] && mkdir -p ${LOG_DIR}/tests
    for tst_file in ${TEST_FILE[@]};do
        local filename=${tst_file##*\/}
        local res_name=${filename%%\.test*}
        local bash_res_name=${LOG_DIR}/tests/$res_name.bsp
        local msll_res_name=${LOG_DIR}/tests/$res_name.msl
        local comp_file=${LOG_DIR}/tests/$res_name.diff
        local fun_log_file=$(print_shorter_path ${comp_file})
        <${tst_file} bash --posix >${bash_res_name} 2>&1
        <${tst_file} $PROGRAMM >${msll_res_name} 2>&1
        RES_DIFF=$(diff ${bash_res_name} ${msll_res_name} > ${comp_file} && echo 0 || echo 1)
        echo -en "🔹${BCU}${res_name}:${M0}"
        pnt "." $(($LEN - ${#res_name} - 15))
        if [[ "${RES_DIFF}" -eq 0 ]];then # PASS --> remove .diff file (empty)
            rm ${comp_file}
            echo "${V0} ✅ PASS${E}"
        else                              # FAIL --> display error
            nb_err=$(( nb_err + 1 ))
            echo "${G0} ✖️  DIFF${E}"
            echo "  ${Y0}👉 Check log file:${M0}${fun_log_file}${E}"
        fi
    done
    return 0
}

# -[ DISPLAY_RESUME() ]---------------------------------------------------------------------------------------
# Display the resume of test (norminette, tests results, log files produces ...)
# Take on optionnal argument, text to add between the <🔶 RESUME> and the <:>.
display_resume()
{
    [[ -n "${1}" ]] && local args=( "🔶 ${YU}RESUME ${1}:${E}" ) || local args=( "🔶 ${YU}RESUME :${E}" )
    # -[ BUILT-IN STEP ]--------------------------------------------------------------------------------------
    if [[ ${BUIN} -gt 0 ]];then
        local OK_BI=( )
        local KO_BI=( )
        for function in "${BUILTIN_FUNUSED[@]}";do
            local fun="${function%%\@*}"
            if [[ "${fun}" != "_"* ]];then
                [[ "${ALLOWED_FUN[@]}" =~ "${fun}" ]] && OK_BI+=( " ${fun} " ) || KO_BI+=( "       ${R0}✗ ${fun}() ${Y0}➽ ${M0}${function##*\@}${E} " )
            fi
        done
        local okc=$(printf "%02d" "${#OK_BI[@]}")
        local koc=$(printf "%02d" "${#KO_BI[@]}")
        if [[ ${#KO_BI[@]} -eq 0 ]];then
            args+=( "  🔸 ${YU}STEP 1-BUILT-IN)${Y0} ${okc} built-in fun. detected:${V0}          ✅ ALL PASS${E}" )
        else
            local TOT_BI=$(printf "%02d" $(( ${#OK_BI[@]} + ${#KO_BI[@]} )) )
            args+=( "  🔸 ${YU}STEP 1-BUILT-IN)${Y0} ${TOT_BI} built-in fun. detected:${E}" )
            args+=( "                ✅ ${V0}${okc} Allowed${E}" )
            args+=( "                ❌ ${R0}${koc} NOT Allowed${E}" )
            args+=( "${KO_BI[@]}" )
        fi
    else
        args+=( "  🔸 ${YU}STEP 1-BUILT-IN)${E}                                    ${G0} ✖️  Step Desabled${E}" )
    fi
    # -[ NORMINETTE STEP ]------------------------------------------------------------------------------------
    if [[ ${NORM} -gt 0 ]];then
        if [[ ${res_normi} -eq 0 ]];then
            args+=( "  🔸 ${YU}STEP 2-NORM-CHECK)${V0}                                   ✅ ALL PASS${E}" )
        else
            args+=( "  🔸 ${YU}STEP 2-NORM-CHECK)${R0}                                   ❌ FAIL (${res_normi} wrong files detected)${E}" )
        fi
    else
        args+=( "  🔸 ${YU}STEP 2-NORM-CHECK)${E}                                 ${G0}  ✖️  Step Desabled${E}" )
    fi
    # -[ UNITESTS STEP ]--------------------------------------------------------------------------------------
    if [[ ${UNIT} -gt 0 ]];then
        local short_log_dir=$(print_shorter_path ${LOG_DIR})
        local tot_tested=$(find ${short_log_dir} -mindepth 1 -maxdepth 1 -type d | wc -l )
        local lst_fail=( )
        [[ -f "${LOG_FAIL}" ]] && for ff in $(cat ${LOG_FAIL} | awk '{print $1}' | sort -u);do [[ ! "${lst_fail[@]}" =~ "${ff}" ]] && lst_fail+=( "${ff}" );done
        if [[ ${#lst_fail[@]} -eq 0 ]];then
            args+=( "  🔸 ${YU}STEP 3-UNITESTS)${Y0} $(printf "%02d" "${tot_tested}") user-made fun. have been tested:${V0} ✅ ALL PASS${E}" ) 
        else
            args+=( "  🔸 ${YU}STEP 3-UNITESTS)${Y0} $(printf "%02d" "${tot_tested}") user-made fun. have been tested:${E}" )
            args+=( \
                "    ${V0}✅ $(( tot_tested - ${#lst_fail[@]} )) functions ${V0}PASSED.${E}" \
                "    ${R0}❌ ${#lst_fail[@]} functions ${R0}FAILLED:${E}" \
            )
            for fun in "${lst_fail[@]}";do
                args+=( "      ${R0}✘ ${RU}${fun}():${E}" )
                local link1=$(awk -v f="${fun}" '$1 == f &&  $2 == "compilation" {print $3}' ${LOG_FAIL})
                local link2=$(awk -v f="${fun}" '$1 == f &&  $2 == "errors" {print $3}' ${LOG_FAIL})
                local link3=$(awk -v f="${fun}" '$1 == f &&  $2 == "leaks" {print $3}' ${LOG_FAIL})
                local link4=$(awk -v f="${fun}" '$1 == f &&  $2 == "missing" {print $3}' ${LOG_FAIL})
                local link5=$(awk -v f="${fun}" '$1 == f &&  $2 == "segfault" {print $3}' ${LOG_FAIL})
                local link6=$(awk -v f="${fun}" '$1 == f &&  $2 == "comp-funcheck" {print $3}' ${LOG_FAIL})
                [[ -n "${link1}" ]] && args+=( "      ${R0}⤷ Error occure will compilling unitests:${M0}👉 ${link1}${E}" )
                [[ -n "${link2}" ]] && args+=( "      ${R0}⤷ Error detected ${M0}👉 ${link2}${E}" )
                [[ -n "${link3}" ]] && args+=( "      ${R0}⤷ Leaks detected ${M0}👉 ${link3}${E}" )
                [[ -n "${link4}" ]] && args+=( "      ${R0}⤷ Missing function, not found in object file.${E}" )
                [[ -n "${link5}" ]] && args+=( "      ${R0}⤷ Segmentation Fault${M0}👉 ${link5}${E}" )
                [[ -n "${link6}" ]] && args+=( "      ${R0}⤷ Error occure will compilling funcheck unitest:${M0}👉 ${link6}${E}" )
            done
        fi
    else
        args+=( "  🔸 ${YU}STEP 3-UNITESTS)${E}                                    ${G0} ✖️  Step Desabled${E}" ) 
    fi
    # -[ FUNCHECK CHECKER ] ----------------------------------------------------------------------------------
    if [[ ${FUNC} -gt 0 ]];then
        args+=( "  🔸 ${YU}STEP 4-FUNCHECK-CHECKER)${E}                            ${V0} ✅ Step Enable${E}" )
    else
        args+=( "  🔸 ${YU}STEP 4-FUNCHECK-CHECKER)${E}                            ${G0} ✖️  Step Desabled${E}" )
    fi
    # -[ EXEC ] ----------------------------------------------------------------------------------------------
    if [[ ${EXEC} -gt 0 ]];then
        args+=( "  🔸 ${YU}STEP 5-EXEC)${E}                                        ${V0} ✅ Step Enable${E}" )
    else
        args+=( "  🔸 ${YU}STEP 5-EXEC)${E}                                        ${G0} ✖️  Step Desabled${E}" )
    fi
    print_in_box -t 2 -c y "${args[@]}"
}

# ============================================================================================================
# MAIN
# ============================================================================================================
# =[ HANDLE SCRIPTS OPTIONS ]=================================================================================
for arg in "${ARGS[@]}";do
    shift
    if [[ "$arg" =~ ^(\+\+|--).*$ ]];then
        case "${arg}" in
            --[Aa]ll ) BUIN=1;COMP=1;DLOG=1;EXEC=1;FUNC=1;NORM=1;OPTI=1;UNIT=1;VALG=1;;
            --[Nn]o-[Aa]ll ) BUIN=0;COMP=0;DLOG=0;EXEC=0;FUNC=0;NORM=0;OPTI=0;UNIT=0;VALG=0;;
            --[Bb]uil[td]-in ) BUIN=$(( BUIN + 1 )) ;;
            --[Nn]o-[Bb]uil[td]-in ) BUIN=$(max 0 $(( BUIN - 1 ))) ;;
            --[Cc]omp ) COMP=$(( COMP + 1 )) ;;
            --[Nn]o-[Cc]omp ) COMP=$(max 0 $(( COMP - 1 ))) ;;
            --[Dd]log ) DLOG=$(( DLOG + 1 )) ;;
            --[Nn]o-[Dd]log ) DLOG=$(max 0 $(( DLOG - 1 ))) ;;
            --[Ee]xec ) EXEC=$(( EXEC + 1 )) ;;
            --[Nn]o-[Ee]xec ) EXEC=$(max 0 $(( EXEC - 1 ))) ;;
            --[Ff]uncheck ) FUNC=$(( FUNC + 1 )) ;;
            --[Nn]o-[fF]uncheck ) FUNC=$(max 0 $(( FUNC - 1 ))) ;;
            --[Hh]elp ) HELP=$(( HELP + 1 )) ;;
            --[Nn]o-[Hh]elp ) HELP=$(max 0 $(( HELP + 1 ))) ;;
            --[Nn]orm ) NORM=$(( NORM + 1 )) ;;
            --[Nn]o-[Nn]orm ) NORM=$(max 0 $(( NORM - 1 ))) ;;
            --[Oo]pti ) OPTI=$(( OPTI + 1 )) ;;
            --[Nn]o-[Oo]pti ) OPTI=$(max 0 $(( OPTI - 1 ))) ;;
            --[Uu]nitests ) UNIT=$(( UNIT + 1 )) ;;
            --[Nn]o-[Uu]nitests ) UNIT=$(max 0 $(( UNIT - 1 ))) ;;
            --[Vv]algrind ) VALG=$(( VALG + 1 )) ;;
            --[Nn]o-[Vv]algrind ) VALG=$(max 0 $(( VALG - 1 ))) ;;
            *) script_usage "${R0}unknown option:${RU}${arg}${E}" 4 ;;
        esac
    elif [[ "${arg}" =~ ^[+-][^+-]*$ ]];then
        symb=${arg:0:1}
        for i in $(seq 1 $((${#arg} - 1)));do
            char="${arg:i:1}"
            case "${char}" in
                [Aa] ) [[ "${symb}" == "+" ]] && { BUIN=1;COMP=1;DLOG=1;EXEC=1;FUNC=1;NORM=1;OPTI=1;UNIT=1;VALG=1;} || { BUIN=0;COMP=0;DLOG=0;EXEC=0;FUNC=0;NORM=0;OPTI=0;UNIT=0;VALG=0;} ;;
                [Bb] ) [[ "${symb}" == "+" ]] && BUIN=$(( BUIN + 1 )) || BUIN=$(max 0 $(( BUIN - 1 ))) ;;
                [Cc] ) [[ "${symb}" == "+" ]] && COMP=$(( COMP + 1 )) || COMP=$(max 0 $(( COMP - 1 ))) ;;
                [Dd] ) [[ "${symb}" == "+" ]] && DLOG=$(( DLOG + 1 )) || DLOG=$(max 0 $(( DLOG - 1 ))) ;;
                [Ee] ) [[ "${symb}" == "+" ]] && EXEC=$(( EXEC + 1 )) || EXEC=$(max 0 $(( EXEC - 1 ))) ;;
                [Ff] ) [[ "${symb}" == "+" ]] && FUNC=$(( FUNC + 1 )) || FUNC=$(max 0 $(( FUNC - 1 ))) ;;
                [Hh] ) [[ "${symb}" == "+" ]] && HELP=$(( HELP + 1 )) || HELP=$(max 0 $(( HELP - 1 ))) ;;
                [Nn] ) [[ "${symb}" == "+" ]] && NORM=$(( NORM + 1 )) || NORM=$(max 0 $(( NORM - 1 ))) ;;
                [Oo] ) [[ "${symb}" == "+" ]] && OPTI=$(( OPTI + 1 )) || OPTI=$(max 0 $(( OPTI - 1 ))) ;;
                [Uu] ) [[ "${symb}" == "+" ]] && UNIT=$(( UNIT + 1 )) || UNIT=$(max 0 $(( UNIT - 1 ))) ;;
                [Vv] ) [[ "${symb}" == "+" ]] && VALG=$(( VALG + 1 )) || VALG=$(max 0 $(( VALG - 1 ))) ;;
                *) script_usage "${R0}unknown option:${RU}${symb}${char}${E}" 5 ;;
            esac
        done
    else
        FUN_NAME_PATTERN+=( "${arg}" )
        continue
    fi
done
# =[ HELP ]===================================================================================================
[[ ${HELP} -ne 0 ]] && script_usage
# =[ CHECK IF LIBFT.A FOUNDED ]===============================================================================
[[ -x ${PROGRAMM} ]] || { script_usage "${R0}Programm not found: No ${BC0}${PROGRAMM}${R0} found.${E}" 2; }
# =[ CREATE LOG_DIR ]=========================================================================================
[[ ! -d ${LOG_DIR} ]] && mkdir -p ${LOG_DIR}
# =[ SET LISTS ]==============================================================================================
# -[ CHECK IF OS KNOWN ]--------------------------------------------------------------------------------------
[[ ( "$(uname)" != "Linux" ) && ( "$(uname)" != "Darwin" ) ]] && { echo "${R0}UNKNOWN OS${E}" && exit 3 ; }
# -[ SET LIBFT_FUN ]------------------------------------------------------------------------------------------
if file "${LIBFT_A}" | grep -qE 'relocatable|executable|shared object|ar archive';then
    for fun in $(nm -g "${LIBFT_A}" 2>/dev/null | grep " T " | awk '{print $NF}' | sort | uniq);do
        if [[ ! "${LIBFT_FUN[@]}" =~ "${fun}" ]];then
            [[ "$(uname)" == "Linux" ]] && LIBFT_FUN+=( "${fun}" ) || LIBFT_FUN+=( "${fun#*\_}" )
        fi
    done
else
    echo -e "LIBFT_A=${BC0}${LIBFT_A}${E} is not an object file\033[m"
fi
# -[ SET HOMEMADE_FUNUSED & BUILTIN_FUNUSED ]-----------------------------------------------------------------
if file "${PROGRAMM}" | grep -qE 'relocatable|executable|shared object|ar archive';then
    if [[ "$(uname)" == "Linux" ]];then
        for fun in $(nm -g "${PROGRAMM}" 2>/dev/null | grep " T " | awk '{print $NF}' | sort | uniq);do
            if [[ "${FUN_TO_EXCLUDE[@]}" =~ "${fun}" && " ${fun} " != " main " ]];then
                [[ ! "${BUILTIN_FUNUSED[@]}" =~ "${fun}" ]] && BUILTIN_FUNUSED+=( "${fun}" )
            else
                [[ ! "${HOMEMADE_FUNUSED[@]}" =~ "${fun}" ]] && HOMEMADE_FUNUSED+=( "${fun}" )
            fi
        done
        for fun in $(nm -g "${PROGRAMM}" 2>/dev/null | grep " U " | awk '{print $NF}' | sort | uniq);do
            if [[ ! "${HOMEMADE_FUNUSED[@]}" =~ "${fun}" ]];then
                [[ ! "${BUILTIN_FUNUSED[@]}" =~ "${fun}" ]] && BUILTIN_FUNUSED+=( "${fun}" )
            fi
        done
    else
        for fun in $(nm -g "${PROGRAMM}" 2>/dev/null | grep " T " | awk '{print $NF}' | sort | uniq);do
            if [[ "${FUN_TO_EXCLUDE[@]}" =~ "${fun#*_}" && " ${fun#*_} " != " main " ]];then
                [[ ! "${BUILTIN_FUNUSED[@]}" =~ "${fun#*_}" ]] && BUILTIN_FUNUSED+=( "${fun#*_}" )
            else
                [[ ! "${HOMEMADE_FUNUSED[@]}" =~ "${fun#*_}" ]] && HOMEMADE_FUNUSED+=( "${fun#*_}" )
            fi
        done
        for fun in $(nm -g "${PROGRAMM}" 2>/dev/null | grep " U " | awk '{print $NF}' | sort | uniq);do
            if [[ ! "${HOMEMADE_FUNUSED[@]}" =~ "${fun#*_}" ]];then
                [[ ! "${BUILTIN_FUNUSED[@]}" =~ "${fun#*_}" ]] && BUILTIN_FUNUSED+=( "${fun#*_}" )
            fi
        done
    fi
else
    echo -e "${BC0}${PROGRAMM}${E} is not an object file\033[m"
fi
# -[ SET FUN_TO_TEST && FUN_WITH_UNITEST ]--------------------------------------------------------------------
if [[ ${#FUN_NAME_PATTERN[@]} -eq 0 ]];then
    FUN_TO_TEST=($(printf "%s\n" "${HOMEMADE_FUNUSED[@]}" | grep -vxF -f <(printf "%s\n" "${LIBFT_FUN[@]}" "${FUN_TO_EXCLUDE[@]}")))
    for fun in "${FUN_TO_TEST[@]}";do [[ -n "$(find "${PARENT_DIR}/src/unitests/" -type f -name *"${fun}.c")" ]] && FUN_WITH_UNITEST+=( "${fun}" );done
else
    for fun in "${FUN_NAME_PATTERN[@]}";do
        for file in $(find "${PARENT_DIR}/src/unitests" -type f -name *"${fun}"*.c);do
            filename=$(basename ${file})
            filename=${filename##*\test_}
            FUN_ASKED_FOR+=( "${filename%%\.c*}" )
        done
    done
fi
# =[ START ]==================================================================================================
display_start
# =[ STEPS ]==================================================================================================
# -[ STEP 1 | CHECK-FUNUSED ]---------------------------------------------------------------------------------
if [[ ${BUIN} -gt 0 ]];then
    print_in_box -t 2 -c y \
        "      ${Y0}   ___   _                 _       ___                 _   _                 _  ${E}" \
        "      ${Y0}  / __| | |_    ___   __  | |__   | __|  _  _   _ _   | | | |  ___  ___   __| | ${E}" \
        "      ${Y0} | (__  | ' \  / -_) / _| | / /   | _|  | || | | ' \  | |_| | (_-< / -_) / _' | ${E}" \
        "      ${Y0}  \___| |_||_| \___| \__| |_\_\   |_|    \_,_| |_||_|  \___/  /__/ \___| \__,_| ${E}" \
        "   "
    exec_anim_in_box "check_funused" "Display built-in function used"
fi
# -[ STEP 2 | NORM-CHECK ]------------------------------------------------------------------------------------
if [[ ${NORM} -gt 0 ]];then
    print_in_box -t 2 -c y \
    " ${Y0}                    _  _                       _                _     _          ${E}" \
    " ${Y0}                   | \| |  ___   _ _   _ __   (_)  _ _    ___  | |_  | |_   ___  ${E}" \
    " ${Y0}                   | .' | / _ \ | '_| | '  \  | | | ' \  / -_) |  _| |  _| / -_) ${E}" \
    " ${Y0}                   |_|\_| \___/ |_|   |_|_|_| |_| |_||_| \___|  \__|  \__| \___| ${E}"
    exec_anim_in_box "check42_norminette ${MS_DIR}" "Check Norminette"
    res_normi=${?}
fi
# -[ STEP 3.1 | UNITESTS ]------------------------------------------------------------------------------------
if [[ ${UNIT} -gt 0 ]];then
    print_in_box -t 2 -c y \
    " ${Y0}                     _   _   _  _   ___   _____   ___   ___   _____   ___                ${E}" \
    " ${Y0}                    | | | | | \| | |_ _| |_   _| | __| / __| |_   _| / __|               ${E}" \
    " ${Y0}                    | |_| | | .' |  | |    | |   | _|  \__ \   | |   \__ \               ${E}" \
    " ${Y0}                     \___/  |_|\_| |___|   |_|   |___| |___/   |_|   |___/               ${E}"
    if [[ ${#FUN_NAME_PATTERN[@]} -gt 0 ]];then
        exec_anim_in_box "launch_unitests FUN_ASKED_FOR" "Launch Unitests on cub3d's functions given as script argument"
    else
        if [[ ${OPTI} -gt 0 ]];then
            exec_anim_in_box "launch_unitests FUN_WITH_UNITEST" "Launch Unitests on cub3d's functions with unitests"
        else
            exec_anim_in_box "launch_unitests FUN_TO_TEST" "Launch Unitests on cub3d's functions"
        fi
    fi
fi
# -[ STEP 3.2 | DISPLAY LOG FILES ]---------------------------------------------------------------------------
if [[ ${DLOG} -gt 0 ]];then
    print_in_box -t 2 -c y \
    " ${Y0}    ___    _               _                   _                   ___   _   _            ${E}" \
    " ${Y0}   |   \  (_)  ___  _ __  | |  __ _   _  _    | |     ___   __ _  | __| (_) | |  ___   ___${E}" \
    " ${Y0}   | |) | | | (_-< | '_ \ | | / _' | | || |   | |__  / _ \ / _' | | _|  | | | | / -_) (_-<${E}" \
    " ${Y0}   |___/  |_| /__/ | .__/ |_| \__,_|  \_, |   |____| \___/ \__, | |_|   |_| |_| \___| /__/${E}" \
    " ${Y0}                   |_|                |__/                 |___/                          ${E}"
    if [ -f "$log_file" ]; then
        while IFS= read -r log_file || [ -n "$log_file" ]; do
            fun_name=$(dirname ${log_file})
            fun_name="${Y0}${fun_name##*\/}()${E}"
            print_box_title -t 1 -c m "${fun_name}"
            while IFS= read -r log_file_line; do
                echol -i 0 -c m -t 1 "${log_file_line}"
            done < "${log_file}"
            print_last -t 1 -c m
        done < "$DLOG_FILE"
        else
            echo "File not found: $log_file"
        fi
fi
# -[ STEP 4 | FUNCHECK ]--------------------------------------------------------------------------------------
[[ ${FUNC} -gt 0 ]] && launch_funcheck
# -[ STEP 5 | EXEC  ]-----------------------------------------------------------------------------------------
if [[ ${EXEC} -gt 0 ]];then
    if [[ ${#FUN_NAME_PATTERN[@]} -gt 0 ]];then
        exec_binary "FUN_ASKED_FOR"
    else
        if [[ ${OPTI} -gt 0 ]];then
            exec_binary "FUN_WITH_UNITEST"
        else
            exec_binary "FUN_TO_TEST"
        fi
    fi
fi
# =[ STOP ]===================================================================================================
display_resume "cub3d's tests"
