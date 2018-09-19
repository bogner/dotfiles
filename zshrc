# -*- Shell-script -*-

# setup the prompt
setopt prompt_subst

precmd () {
    [ -w "$(pwd)" ] && typeset is_cwd_writeable=true
    psvar=("$SSH_CLIENT" "$is_cwd_writeable")
}

_err='%(?..%F{red}[%?]%f)'
_user='%(g.%F{red}.%F{green})%n%f'
_host='%1(V.%B.)%F{green}@%m%f%1(V.%b.) '
_jobs='%1(j.%F{yellow}(%j)%f .)'
_cwd='%2(V.%F{blue}.%F{red})%$((COLUMNS/4))<...<%~%f '
_prompt='%F{blue}%#%f '

PROMPT="${_err}${_user}${_host}${_jobs}${_trunc}${_cwd}${_prompt}"
PROMPT2='%_%F{8}>%f '
RPROMPT='%F{0}# %F{8}%D{%Y-%m-%d %H:%M:%S}%f'
unset _err _user _host _jobs _trunc _cwd _prompt

# update window titles
chpwd() {
    [ -t 1 ] || return
    case $TERM in
        xterm*|rxvt*|screen*|st*) print -Pn "\e]2;%~ ($TERM)\a";;
    esac
}
# call this now, since it doesn't happen on start up
chpwd

# set up completion
autoload -U compinit
compinit
setopt complete_aliases
setopt no_auto_menu
zstyle ':completion:*:descriptions' format '%B%U%F{8}%d%f%b%u'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-prompt ''

# configure history
export HISTSIZE=10000
export SAVEHIST=HISTSIZE
export HISTFILE="$HOME/.zsh_history"
setopt inc_append_history
setopt hist_ignore_dups
setopt hist_reduce_blanks
setopt share_history

# Fix up word-based movement commands
autoload -U select-word-style
select-word-style bash

# Make directory traversal more convenient
setopt autopushd
setopt pushd_minus
setopt pushd_ignore_dups

# Comments are useful, enable them interactively
setopt interactive_comments

# disable XON/XOFF (c-s should search, not pause)
stty -ixon

# make less more friendly for non-text input
$(which lesspipe.sh &>/dev/null) && eval "$(lesspipe.sh)"
$(which lesspipe &>/dev/null) && eval "$(lesspipe)"

# Enable colors for ls, etc.
if which dircolors >/dev/null; then
    [ -e ~/.dir_colors ] || dircolors -p >~/.dir_colors
    eval `dircolors -b ~/.dir_colors`
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
fi

isgnu () {
    [[ "$($1 --version 2>/dev/null | head)" == *GNU* ]] && return 0
    return 1
}

# Alias definitions.
isgnu ls && alias ls="ls --color=auto" || alias ls="ls -G"
alias ll="ls -l"
alias la="ls -A"
alias l="ls -Al"
alias grep="grep --color=auto"
alias psu="ps -U $USER"
alias enscript="enscript -2rE"
alias lpr="lpr -h"
alias vncviewer='vncviewer -shared'
alias et="emacsclient -t"
alias ec="emacsclient -c"
alias en="emacsclient -n"

function extglob() { zsh -c "setopt extendedglob; $*" }
alias extglob="noglob \extglob"

export EDITOR="emacsclient -t -a emacs"
export VISUAL=$EDITOR
export PAGER="less"
export LESS="-FRX"

# if the right terminfo isn't installed, remove qualifiers until we
# find one that is.
while [[ "$TERM" == *-* ]]; do
    tput cols &>/dev/null
    [ $? -eq 3 ] && export TERM=${TERM%-*} || break
done

# we want to know our fortune
which fortune &>/dev/null && fortune
true
