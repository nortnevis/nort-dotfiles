# This is user's file, that is should be sourced in '.bashrc' file

ssh() {
	if [ "$TERM" = "xterm-kitty" ]; then
		kitty +kitten ssh "$@"
	else
		command ssh "$@"
	fi
}

alias ls='ls --color=auto'
alias snvim='sudo nvim'

cl() {
    local cur_dir="${1:-.}"
    cd "$cur_dir" && ls ./
}

cla() {
    local cur_dir="${1:-.}"
    cd "$cur_dir" && ls -a ./
}

cll() {
    local cur_dir="${1:-.}"
    cd "$cur_dir" && ls -lath ./
}

