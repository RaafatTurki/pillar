Y="Y"
N="N"

log() {
    TYPE="$1"
    MSG="$2"
    echo "$TYPE: $MSG"
}
err() {
    local MSG="$1"
    log "ERR" "$MSG"
}
assert() {
    local MSG="$1"
    log "ASSERT" "$MSG"
    exit 1
}

# whitespace included
is_empty() {
    local VAR="$1"

    if [ -z "$VAR" ]; then
        return 0
    else
        return 1
    fi
}

# positive numbers only
is_number() {
    local VAR="$1"

    case $VAR in
        *[!0-9]*)
            return 1 ;;
        *)
            return 0 ;;
    esac
}

yesno() {
    local PROMPT="$1"
    local DEFAULT="$2"
    local INDIC="[y/n]"

    case "$DEFAULT" in
        "$Y") INDIC="[Y/n]" ;;
        "$N") INDIC="[y/N]" ;;
    esac

    while true; do
        read -p "$PROMPT $INDIC: " ANSWER
        local ANSWER=${ANSWER:-"$DEFAULT"}

        case "$ANSWER" in
            [Yy] | [Yy][Ee][Ss])
                echo "$Y"
                return 0 ;;
            [Nn] | [Nn][Oo])
                echo "$N"
                return 1 ;;
        esac
    done
}

input() {
    local PROMPT="$1"
    local DEFAULT="$2"
    local INDIC=""

    if [ "$DEFAULT" != "" ]; then
        INDIC=" ($DEFAULT)"
    fi

    read -p "$PROMPT$INDIC: " ANSWER
    local ANSWER=${ANSWER:-"$DEFAULT"}
    echo $ANSWER
}

input_valid() {
    local PROMPT="$1"
    local DEFAULT="$2"
    local VALIDATIONS="$3"
    local WARN
    local VALUE

    while true; do
        VALUE=$(input $PROMPT $DEFAULT)

        case "$VALIDATIONS" in
            *is_number*)
                if ! is_number $VALUE; then
                    continue
                fi
                ;&
            *is_not_empty*)
                if is_empty $VALUE; then
                    continue
                fi
                ;&
        esac

        echo $VALUE
        break
    done
}
