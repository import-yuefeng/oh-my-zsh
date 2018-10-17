# Description
# ------------
#
# exit plugin will bind a key meta-E to type exit in the current shell
#
# ------------------------------------------------------------
# Authors
# ---------
#
# Yifan Gao <ylgaoyifan@gmail.com>
#
# ------------------------------------------------------------
#

sudo-command-line() {
    [[ -z $BUFFER ]] && zle up-history
    if [[ $BUFFER == sudo\ * ]]; then
        LBUFFER="${LBUFFER#sudo }"
    else
        LBUFFER="sudo $LBUFFER"
    fi
}
zle -N sudo-command-line
bindkey "^[s" sudo-command-line

