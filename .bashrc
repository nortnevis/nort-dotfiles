#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

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

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/nort/.lmstudio/bin"
# End of LM Studio CLI section


if [ -f ~/.bash_user_defined.sh ]; then
	. ~/.bash_user_defined.sh
fi

