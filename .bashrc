#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return
PS1='\[\033[01;31m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Default sudo editor
export EDITOR="nvim"
export VISUAL="nvim"
export XCURSOR_SIZE=24
export QT_QPA_PLATFORMTHEME=qt6ct # change to qt6ct if you have that
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=Hyprland
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export QT_QPA_PLATFORM=wayland
export QT_QPA_PLATFORMTHEME=gtk3
export XDG_CONFIG_HOME=$HOME/.config
export QT_QPA_PLATFORM=wayland
export HF_HOME="$HOME/huggingface"

# Aliases
if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases
fi

# VCPKG
export VCPKG_ROOT="$HOME/external_repos/vcpkg"
export VCPKG_DISABLE_METRICS=1
export PATH=$VCPKG_ROOT:$PATH

# быстрые команды для управления zapret
alias zapret-config='$HOME/zapret-configs/install.sh'
alias zapret-utils='$HOME/zapret-configs/utils-zapret.sh'

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"

