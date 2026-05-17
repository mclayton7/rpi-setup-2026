#!/bin/bash
# Quality-of-life bash settings.
# (Readline/tab-completion tweaks live in /etc/inputrc, not here.)

# Only configure interactive shells.
case $- in
  *i*) ;;
  *) return ;;
esac

# --- History ---
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth        # drop duplicates and space-prefixed commands
HISTTIMEFORMAT='%F %T '       # timestamp each history entry
shopt -s histappend           # append on exit instead of overwriting
shopt -s cmdhist              # keep multi-line commands as one entry
export HISTSIZE HISTFILESIZE HISTCONTROL HISTTIMEFORMAT

# --- Shell behavior ---
shopt -s checkwinsize         # keep LINES/COLUMNS correct after resize
shopt -s cdspell              # autocorrect small typos in `cd` paths
shopt -s dirspell             # autocorrect dir names during completion
shopt -s globstar             # ** matches directories recursively
shopt -s autocd 2>/dev/null   # type a directory name to cd into it
shopt -s no_empty_cmd_completion  # no completion on an empty line

# --- Editor / pager ---
export EDITOR=vim
export VISUAL=vim
export LESS='-R -F -X'        # keep color, quit if one screen, no clear

# --- Aliases ---
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias df='df -h'
alias free='free -h'
