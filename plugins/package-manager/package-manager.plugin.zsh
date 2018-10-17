# local pm_shell

alias pmi='pm install'
alias pmu='pm update'
alias pmug='pm upgrade'
alias pmuu='pmu && pmug'
alias pmdu='pm dist-upgrade'
alias pmr='pm remove'
alias pms='pm search'
alias pmri='pm reinstall'
alias pmif='pm info'

if `type aptitude >/dev/null 2>&1` ; then
    pm_shell='aptitude'
    if [[ "$USER" != "root" ]]; then
        pm_shell="sudo $pm_shell"
    fi
    alias pmif='pm show'
    alias pmug='pm full-upgrade'
elif `type apt-get >/dev/null 2>&1` ; then
    pm_shell='apt-get'
    if [[ "$USER" != "root" ]]; then
        pm_shell="sudo $pm_shell"
    fi
    alias pms='apt-cache search'
    alias pmif='apt-cache show'
elif `type pacman >/dev/null 2>&1` ; then
    pm_shell='pacman'
    if [[ "$USER" != "root" ]]; then
        pm_shell="sudo $pm_shell"
    fi
    alias pmi='pm -S'
    alias pmri='pmi'
    alias pmu='pm -Sy'
    alias pmug='pm -Su'
    alias pmuu='pm -Syu'
    alias pms='pm -Ss'
    alias pmif='pm -Qi'
    alias pmr='pm -Rsc'
elif `type opkg >/dev/null 2>&1` ; then
    pm_shell='opkg'
elif `type brew >/dev/null 2>&1` ; then
    pm_shell='brew'
    alias pmug='pm upgrade'
    alias pml='pm list'
    alias pmd='pm desc'
    alias pmds='pm desc -s'
elif `type yum >/dev/null 2>&1` ; then
    pm_shell='yum'
    if [[ "$USER" != "root" ]]; then
        pm_shell="sudo $pm_shell"
    fi
    alias pmu='pm makecache'
elif `type dnf >/dev/null 2>&1` ; then
    pm_shell='dnf'
    if [[ "$USER" != "root" ]]; then
        pm_shell="sudo $pm_shell"
    fi
    alias pmu='pm makecache'
fi

alias pm="$pm_shell"
