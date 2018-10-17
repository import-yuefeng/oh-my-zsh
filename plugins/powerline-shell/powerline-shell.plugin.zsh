function powerline_precmd() {
	export PS1="$(/usr/bin/env $python2_name $ZSH/plugins/powerline-shell/powerline-shell.py $? --shell zsh 2> /dev/null)"
	export RPS1='%(?..%{[0m%}%{[38;5;124m%}%{[38;5;254m%}%{[48;5;124m%} $?%{[48;5;124m%}) %{[38;5;236m%}%{[38;5;15m%}%{[48;5;236m%} %D{%H:%M:%S} %{[0m%}'
}

function install_powerline_precmd() {
	for s in "${precmd_functions[@]}"; do
		if [ "$s" = "powerline_precmd" ]; then
			return
		fi
	done
	precmd_functions+=(powerline_precmd)
}

function get_python2_path() {
    for ipath in python2 python2.7 python; do
        if  `type $ipath >/dev/null 2>&1`; then
            echo $ipath
            break
        fi
    done
}

if [ "$LC_POWERLINE_FONT" = "true" ]; then
	install_powerline_precmd
fi
export python2_name=$(get_python2_path)
