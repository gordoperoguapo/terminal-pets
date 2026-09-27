#!/usr/bin/env bash
# terminal-pets for bash and zsh: Mote and friends from the upcoming Kuni app
# https://github.com/gordoperoguapo/terminal-pets
# Code: MIT license. Character designs: all rights reserved (see LICENSE).

PET_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SKINS_FILE="$PET_DIR/skins.txt"
SKIN_CHOICE_FILE="$PET_DIR/pet-skin.txt"
ESC=$'\033'
UPPER=$'\xe2\x96\x80'
LOWER=$'\xe2\x96\x84'

skin_names() {
    awk '$1 == "skin" { print $2 }' "$SKINS_FILE"
}

canonical_skin() {
    local want name
    want=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')
    for name in $(skin_names); do
        if [ "$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]')" = "$want" ]; then
            printf '%s' "$name"
            return 0
        fi
    done
    return 1
}

require_skin() {
    canonical_skin "$1" && return
    echo "Unknown skin '$1'. Choose from: $(skin_names | tr '\n' ' ')" >&2
    return 1
}

current_skin() {
    local saved=""
    [ -f "$SKIN_CHOICE_FILE" ] && saved=$(head -n 1 "$SKIN_CHOICE_FILE")
    canonical_skin "$saved" || printf 'Mote'
}

load_skin() {
    local want=$1 line key rest current="" in_body=0 like="" face="" colors="" pair var
    BODY=()
    while IFS= read -r line || [ -n "$line" ]; do
        line=${line%$'\r'}
        if [ $in_body = 1 ]; then
            if [ "$line" = end ]; then
                in_body=0
            elif [ "$current" = "$want" ]; then
                BODY+=("$line")
            fi
            continue
        fi
        case $line in '' | '#'*) continue ;; esac
        key=${line%% *}
        rest=${line#"$key"}
        rest=${rest# }
        [ "$key" = skin ] && current=$rest
        [ "$current" = "$want" ] || continue
        case $key in
            face) face=$rest ;;
            colors) colors=$rest ;;
            body) if [ -n "$rest" ]; then like=${rest#like }; else in_body=1; fi ;;
        esac
    done < "$SKINS_FILE"

    if [ -n "$like" ]; then
        load_skin "$like"
    fi

    set -- $face
    FACE_TOP=$1 EYES=$2 MOUTH=$3 BLUSH=$4
    for var in ${!C_*}; do unset "$var"; done
    for pair in $colors; do
        var=${pair#*=}
        printf -v "C_${pair%%=*}" '%d;%d;%d' "0x${var:0:2}" "0x${var:2:2}" "0x${var:4:2}"
    done
}

px() {
    G[$1]="${G[$1]:0:$2}$3${G[$1]:$(($2 + 1))}"
}

build_sprite() {
    local look=$1 blink=$2 ft=$FACE_TOP eye x out c
    G=("${BODY[@]}")
    for eye in 2 7; do
        x=$((eye + look))
        if [ $eye = 2 ]; then out=-1; else out=1; fi
        case $EYES in
            rumble)
                px $((ft - 2)) $((x + out)) E; px $((ft - 1)) $x E; px $((ft - 1)) $((x - out)) E
                if [ $blink = 1 ]; then px $((ft + 1)) $x E; px $((ft + 1)) $((x + out)) E
                else px $ft $x G; px $((ft + 1)) $x R; fi
                ;;
            sleepy)
                px $ft $((x - 1)) E; px $ft $((x + 1)) E; px $((ft + 1)) $x E
                ;;
            *)
                if [ $blink = 1 ]; then px $ft $x E; px $((ft + 1)) $((x - 1)) E; px $((ft + 1)) $((x + 1)) E
                elif [ "$EYES" = star ]; then px $ft $x I; px $((ft + 1)) $x J
                else px $ft $x E; px $((ft + 1)) $x E; fi
                ;;
        esac
    done
    if [ "$BLUSH" = blush ]; then px $((ft + 2)) 1 P; px $((ft + 2)) 8 P; fi
    if [ "$MOUTH" = fangs ]; then
        for c in 3 4 5 6; do px $((ft + 2)) $((c + look)) E; done
        px $((ft + 3)) $((3 + look)) W; px $((ft + 3)) $((6 + look)) W
    else
        px $((ft + 3)) $((4 + look)) E; px $((ft + 3)) $((5 + look)) E
    fi
}

render_sprite() {
    local offset=$1 n=${#G[@]} w=${#G[0]} h r c ch var top bottom t b line blank="" rows=()
    h=$((n + 2 + n % 2))
    for ((c = 0; c < w; c++)); do blank+=.; done
    for ((r = 0; r < h; r++)); do rows[r]=$blank; done
    for ((r = 0; r < n; r++)); do rows[offset + r]=${G[r]}; done
    RENDERED=()
    for ((r = 0; r < h; r += 2)); do
        top=${rows[r]} bottom=${rows[r + 1]} line=""
        for ((c = 0; c < w; c++)); do
            ch=${top:c:1}; if [ "$ch" = . ]; then t=""; else var="C_$ch"; t=${!var}; fi
            ch=${bottom:c:1}; if [ "$ch" = . ]; then b=""; else var="C_$ch"; b=${!var}; fi
            if [ -z "$t" ] && [ -z "$b" ]; then line+="${ESC}[0m "
            elif [ -z "$b" ]; then line+="${ESC}[0;38;2;${t}m${UPPER}"
            elif [ -z "$t" ]; then line+="${ESC}[0;38;2;${b}m${LOWER}"
            else line+="${ESC}[38;2;${t};48;2;${b}m${UPPER}"; fi
        done
        RENDERED+=("${line}${ESC}[0m")
    done
}

add_frame() {
    render_sprite $1
    FRAMES+=("${RENDERED[@]}")
}

build_frames() {
    local look offset
    FRAMES=()
    for look in -1 0 1; do
        build_sprite $look 0
        for offset in 0 1 2; do add_frame $offset; done
    done
    build_sprite 0 1
    add_frame 2
    add_frame 0
    FRAME_HEIGHT=${#RENDERED[@]}
    FRAME_WIDTH=${#BODY[0]}
}

draw_frame() {
    local f=$1 indent=$2 erase=$3 i
    printf '%s[%dA' "$ESC" "$FRAME_HEIGHT"
    for ((i = 0; i < FRAME_HEIGHT; i++)); do
        printf '\r%*s%s%s\n' "$indent" '' "${FRAMES[f * FRAME_HEIGHT + i]}" "$erase"
    done
}

show_banner() {
    local skin=$1 shell_info=$2 animate=$3 mid info i f host
    load_skin "$skin"
    build_frames
    host=${HOSTNAME:-$(hostname)}
    mid=$((FRAME_HEIGHT / 2 - 1))
    for ((i = 0; i < FRAME_HEIGHT; i++)); do
        case $((i - mid)) in
            0) info="${ESC}[1m${shell_info}${ESC}[0m" ;;
            1) info="${ESC}[90m${USER:-$(whoami)} @ ${host%%.*}${ESC}[0m" ;;
            2) info="${ESC}[90m${PWD/#$HOME/~}${ESC}[0m" ;;
            *) info="" ;;
        esac
        printf '  %s    %s\n' "${FRAMES[5 * FRAME_HEIGHT + i]}" "$info"
    done
    echo

    [ "$animate" = 1 ] && [ -t 1 ] || return 0
    printf '%s[?25l' "$ESC"
    printf '%s[1A' "$ESC"
    for f in 5 4 3 3 4 5 5 4 3 4 5 5 5 9 9 9 5 5 5 9 5; do
        draw_frame $f 2 ""
        sleep 0.07
    done
    printf '\n%s[?25h' "$ESC"
}

walk() {
    local skin=$1 speed=$2 cols max_x x=0 dir=1 step=0 rest=0 mood=calm hop=0 f offset look i old_stty key tenths
    if [ ! -t 0 ] || [ ! -t 1 ]; then
        echo "pet needs an interactive terminal." >&2
        return 1
    fi
    load_skin "$skin"
    build_frames
    cols=$(tput cols 2>/dev/null || echo 80)
    max_x=$((cols - FRAME_WIDTH - 1))
    [ $max_x -lt 1 ] && max_x=1
    tenths=$(((speed + 50) / 100))
    [ $tenths -lt 1 ] && tenths=1

    old_stty=$(stty -g)
    trap 'stty "$old_stty"; printf "%s[0m%s[?25h" "$ESC" "$ESC"; exit' INT TERM
    stty -icanon -echo min 0 time $tenths
    printf '%s[?25l' "$ESC"
    for ((i = 0; i < FRAME_HEIGHT; i++)); do echo; done

    while :; do
        step=$((step + 1))
        if [ $rest -gt 0 ]; then
            rest=$((rest - 1))
            case $mood in
                happy) if [ $((step % 4)) -lt 2 ]; then f=10; else f=9; fi ;;
                curious) look=$(( (step / 6) % 4 )); case $look in 0) f=2 ;; 2) f=8 ;; *) f=5 ;; esac ;;
                *) if [ $((rest % 16)) -lt 2 ]; then f=9; else f=5; fi ;;
            esac
        else
            x=$((x + dir))
            if [ $x -ge $max_x ]; then x=$max_x; dir=-1; fi
            if [ $x -le 0 ]; then x=0; dir=1; fi
            if [ $hop -gt 0 ]; then
                hop=$((hop - 1)); offset=0
            else
                if [ $((step % 4)) -lt 2 ]; then offset=2; else offset=1; fi
                [ $((RANDOM % 40)) = 0 ] && hop=3
            fi
            f=$(((dir + 1) * 3 + offset))
            if [ $((RANDOM % 70)) = 0 ]; then
                rest=$((20 + RANDOM % 30))
                case $((RANDOM % 3)) in 0) mood=calm ;; 1) mood=happy ;; 2) mood=curious ;; esac
            fi
        fi
        draw_frame $f $x "${ESC}[K"
        key=$(dd bs=1 count=1 2>/dev/null)
        [ -n "$key" ] && break
    done

    stty "$old_stty"
    printf '%s[0m%s[?25h' "$ESC" "$ESC"
}

list_skins() {
    local current
    current=$(current_skin)
    awk -v current="$current" '
        $1 == "skin" { name = $2 }
        $1 == "about" { sub(/^about /, ""); printf "  %-10s %s%s\n", name, $0, (name == current ? "  <-" : "") }
    ' "$SKINS_FILE"
}

usage() {
    cat <<'EOF'
Usage:
  pet                  watch your pet bob around (press any key to stop)
  pet --skin Ember     try a different skin just this once
  pet --speed 60       faster (milliseconds per frame, default 110)
  pet skins            list the skins
  pet skin Rumble      switch skins (remembered for next time)
  pet banner           show the welcome banner again
EOF
}

main() {
    local skin speed=110 shell_info="" animate=1 name
    skin=$(current_skin)
    case $1 in
        skins) list_skins; return ;;
        skin)
            name=$(require_skin "$2") || return 1
            printf '%s\n' "$name" > "$SKIN_CHOICE_FILE"
            show_banner "$name" "$(basename "${SHELL:-shell}")" 1
            return
            ;;
        banner)
            shift
            while [ $# -gt 0 ]; do
                case $1 in
                    --shell) shell_info=$2; shift ;;
                    --no-animation) animate=0 ;;
                esac
                shift
            done
            show_banner "$skin" "${shell_info:-$(basename "${SHELL:-shell}")}" $animate
            return
            ;;
        help | -h | --help) usage; return ;;
    esac
    while [ $# -gt 0 ]; do
        case $1 in
            --skin) skin=$(require_skin "$2") || return 1; shift ;;
            --speed) speed=$2; shift ;;
            *) usage >&2; return 1 ;;
        esac
        shift
    done
    walk "$skin" "$speed"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    main "$@"
fi
