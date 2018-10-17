# -*- sh -*- vim:set ft=sh ai et sw=4 sts=4:
# It might be bash like, but I can't have my co-workers knowing I use zsh

local return_code="%(?..%{$fg_bold[red]%}%? ↵%{$reset_color%})"

function my_git_prompt_info() {
        ref=$(git symbolic-ref HEAD 2> /dev/null) || return
        GIT_STATUS=$(git_prompt_status)
        [[ -n $GIT_STATUS ]] && GIT_STATUS=" $GIT_STATUS"
        echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$GIT_STATUS$ZSH_THEME_GIT_PROMPT_SUFFIX"
}

# Colored prompt
ZSH_THEME_COLOR_USER="%{$fg_bold[green]%}"
ZSH_THEME_COLOR_HOST="%{$fg_bold[green]%}"
ZSH_THEME_COLOR_PWD="%{$fg_bold[blue]%}"
test -n "$SSH_CONNECTION" && ZSH_THEME_COLOR_USER="%{$fg_bold[red]%}" && ZSH_THEME_COLOR_HOST="%{$fg_bold[red]%}"
test `id -u` = 0 && ZSH_THEME_COLOR_USER="%{$fg_bold[magenta]%}" && ZSH_THEME_COLOR_HOST="%{$fg_bold[magenta]%}"
PROMPT='$ZSH_THEME_COLOR_USER%n@$ZSH_THEME_COLOR_HOST%m%{$reset_color%}:$ZSH_THEME_COLOR_PWD%~%{$reset_color%} $(my_git_prompt_info)%(!.#.$) '
RPS1="${return_code}"

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[cyan]%}("
ZSH_THEME_GIT_PROMPT_SUFFIX=") %{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%%"
ZSH_THEME_GIT_PROMPT_ADDED="+"
ZSH_THEME_GIT_PROMPT_MODIFIED="*"
ZSH_THEME_GIT_PROMPT_RENAMED="~"
ZSH_THEME_GIT_PROMPT_DELETED="!"
ZSH_THEME_GIT_PROMPT_UNMERGED="?"

