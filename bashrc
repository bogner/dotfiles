#!/bin/bash

### This top part should be POSIX sh compatible, so that we can source
### it non-interactively and get our path
shell="$(ps -p $$ -o command 2>/dev/null | sed '1d; s/^-//; s/ .*$//')"
if [ -z "$shell" ]; then
    # The above attempts to be portable, but if something goes wrong
    # just give up and use "$0", which is usually fine.
    shell="$0"
fi
shell="$(basename $shell)"

prepend_path () {
    local append newpath path
    if [ "$1" = -a ] || [ "$1" = --append ]; then
        append=true
        shift
    fi
    old_ifs="$IFS"
    IFS=:
    while [ -n "$1" ]; do
        [ "$append" != true ] && newpath="$1:"
        for path in $PATH; do
            [ "$path" = "$1" ] && continue;
            newpath="$newpath$path:"
        done
        [ "$append" = true ] && newpath="$newpath$1:"
        PATH="${newpath%:}"
        shift
    done;
    IFS="$old_ifs"
}

prepend_path $HOME/local/bin $HOME/scripts

# Only continue if we're interactively running bash
[ -z "$PS1" ] || [ "$shell" != "bash" ] && return

### end of POSIX compatibility

# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=ignoredups
# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize
# make less more friendly for non-text input files, see lesspipe(1)
$(which lesspipe.sh &>/dev/null) && eval "$(lesspipe.sh)"
$(which lesspipe &>/dev/null) && eval "$(lesspipe)"
# set a fancy prompt
case $TERM in
    dumb)
        ;;
    *)
        c_bright='\[\e[1m\]'
        c_yellow='\[\e[0;33m\]'
        c_green='\[\e[0;32m\]'
        c_blue='\[\e[0;34m\]'
        c_red='\[\e[0;31m\]'
        c_nc='\[\e[0m\]'
        ;;
esac

[ $EUID = 0 ] && c_user=$c_red || c_user=$c_green
[ "$SSH_CLIENT" ] && c_host=$c_green$c_bright || c_host=$c_green

__jobcount () {
    local stopped=$(echo $(jobs -s | wc -l))
    local result=" "
    [ $stopped -gt 0 ] && result="$result($stopped) "
    echo "$result"
}

__shorten () {
    local max=$(($COLUMNS/4))
    local result="$@"
    [[ $result == $HOME/* ]] && result="~${result#$HOME}"
    local offset=$(( ${#result} - $max + 3 ))
    [ $offset -gt 0 ] && result="...${result:$offset:$max}"
    [[ $result == ...*/* ]] && result="$(echo $result | sed 's/^[^/]*/.../')"
    echo $result
}

_err='$(rc=$?; [ $rc -ne 0 ] && echo '"'$c_red'"'[$rc])'
_user="${c_user}\u"
_host="${c_host}@\h"
_jobs="${c_yellow}"'$(__jobcount)'
_cwd='$([ -w "$PWD" ]'" && echo '$c_blue' || echo '$c_red')"'$(__shorten \w)'
_prompt=" ${c_blue}"'\$'" ${c_nc}"

PS1="${_err}${_user}${_host}${_jobs}${_cwd}${_prompt}"

unset c_yellow c_green c_blue c_red c_nc _err _user _host _cwd _prompt

# Change the window title of X terminals
case $TERM in
    xterm*|rxvt*|screen*|st*)
        prompt='${WINDOW:+$WINDOW. }${PWD/$HOME\//~/} ($TERM)'
        PROMPT_COMMAND='echo -ne "\033]0;'"$prompt"'\007"'
        unset prompt
        ;;
esac

# disable XON/XOFF (c-s should search, not pause)
stty -ixon
# programmable completion
if [ -r /etc/bash_completion ]; then
    . /etc/bash_completion
elif [ -f /usr/local/etc/bash_completion ]; then
    . /usr/local/etc/bash_completion
elif [ -r ~/.bash_completion ]; then
    . ~/.bash_completion
fi

# readline behaviour
bind "set bell-style none"
bind "set show-all-if-unmodified on"
bind "set mark-symlinked-directories on"
bind "set visible-stats on"

if which dircolors >/dev/null; then
    # Enable colors for ls, etc.
    [ -e ~/.dir_colors ] || dircolors -p >~/.dir_colors
    eval `dircolors -b ~/.dir_colors`
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

export EDITOR="emacsclient -t -a emacs"
export VISUAL=$EDITOR
export PAGER="less"
export LESS="-FRX"

# if the right terminfo isn't installed, remove qualifiers until we
# find one that is.
while [[ "$TERM" == *-* ]]; do
    tput cols >/dev/null 2>&1
    [ $? -eq 3 ] && export TERM=${TERM%-*} || break
done

# we want to know our fortune
which fortune 2>/dev/null >/dev/null && fortune
true
