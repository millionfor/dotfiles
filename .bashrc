# vim: et:ts=4:sw=4:sts=4:ff=unix:fdm=marker:

# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples
# author: Allex Wang (allex.wxn@gmail.com)

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

cmd_exists () { type "$1" &> /dev/null; }

# Colors
export GREP_OPTIONS='--color=auto'
export CLICOLOR=1

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000
HISTIGNORE="&:ls:cd:[bf]g:exit:q:..:...:ll:la:l:h:history"

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

if cmd_exists dircolors ; then
    alias ls='ls --color=auto' # For linux, etc
else
    if [ $OS = "darwin" ]; then
        export LSCOLORS=gxfxcxdxbxegedabagacad
        alias ls='ls -G' # OS-X SPECIFIC - the -G command in OS-X is for colors, in Linux it's no groups
    fi
fi

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='\[\e[1;32m\][\u@\h \W]\$\[\e[0m\] '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi

## complex prompt {{{
## http://bash.cyberciti.biz/guide/Changing_bash_prompt

bash_prompt_command() {
    # How many characters of the $PWD should be kept
    local pwdmaxlen=20
    # Indicate that there has been dir truncation
    local trunc_symbol=".."
    local dir=${PWD##*/}
    pwdmaxlen=$(( ( pwdmaxlen < ${#dir} ) ? ${#dir} : pwdmaxlen ))
    NEW_PWD=${PWD/#$HOME/\~}
    local pwdoffset=$(( ${#NEW_PWD} - pwdmaxlen ))
    if [ ${pwdoffset} -gt "0" ]
    then
        NEW_PWD=${NEW_PWD:$pwdoffset:$pwdmaxlen}
        NEW_PWD=${trunc_symbol}/${NEW_PWD#*/}
    fi

    # Additionally get current git branch name
    local branch=""
    if [ -d .git ]; then
        read branch <.git/HEAD
        [[ $branch < g ]] && branch=${branch::7} || branch=${branch/*\/}
    else
        branch=`git rev-parse --abbrev-ref HEAD 2>/dev/null`
    fi
    if [ -n "$branch" ]; then
        branch=":$branch"
    fi
    GIT_BRANCH=$branch
}
bash_prompt() {
    local NONE="\[\033[0m\]"    # unsets color to term's fg color
 
    # regular colors
    local K="\[\033[0;30m\]"    # black
    local R="\[\033[0;31m\]"    # red
    local G="\[\033[0;32m\]"    # green
    local Y="\[\033[0;33m\]"    # yellow
    local B="\[\033[0;34m\]"    # blue
    local M="\[\033[0;35m\]"    # magenta
    local C="\[\033[0;36m\]"    # cyan
    local W="\[\033[0;37m\]"    # white
 
    # emphasized (bolded) colors
    local EMK="\[\033[1;30m\]"
    local EMR="\[\033[1;31m\]"
    local EMG="\[\033[1;32m\]"
    local EMY="\[\033[1;33m\]"
    local EMB="\[\033[1;34m\]"
    local EMM="\[\033[1;35m\]"
    local EMC="\[\033[1;36m\]"
    local EMW="\[\033[1;37m\]"
 
    # background colors
    local BGK="\[\033[40m\]"
    local BGR="\[\033[41m\]"
    local BGG="\[\033[42m\]"
    local BGY="\[\033[43m\]"
    local BGB="\[\033[44m\]"
    local BGM="\[\033[45m\]"
    local BGC="\[\033[46m\]"
    local BGW="\[\033[47m\]"
 
    local UC=$W                 # user's color
    [ $UID -eq "0" ] && UC=$R   # root's color
 
    PS1="${EMG}\u@\h ${EMB}\${NEW_PWD}${EMM}\${GIT_BRANCH}${UC}> ${NONE}"
}

if [ "$color_prompt" = yes ]; then
    # init it by setting PROMPT_COMMAND
    PROMPT_COMMAND=bash_prompt_command
    bash_prompt
else
    unset bash_prompt_command
fi
unset bash_prompt

## END complex prompt }}}

unset color_prompt force_color_prompt

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# Adding Git Autocomplete to Bash
if [ -f "$HOME/.dotfiles/git-completion.bash" ]; then
    source "$HOME/.dotfiles/git-completion.bash"
fi

# Make Terminal’s autocompletion case-insensitive
bind 'set completion-ignore-case On'

# Cycle through autocomplete options in Ubuntu’s Terminal with the TAB key
bind '"\C-i" menu-complete'

if [ -f ~/.bash_local ]; then
    . ~/.bash_local
fi

unset -f cmd_exists
