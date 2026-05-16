#!/bin/bash
# Colored bash prompt configuration

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'  # No Color

# Build prompt with colors
if [ "$EUID" -eq 0 ]; then
  # Root user - red prompt
  PS1="${GREEN}\u${NC}@${BLUE}\h${NC}:${YELLOW}\w${NC}${RED}# ${NC}"
else
  # Regular user - white prompt
  PS1="${GREEN}\u${NC}@${BLUE}\h${NC}:${YELLOW}\w${NC}${WHITE}\$ ${NC}"
fi

# Enable color for ls command
export LS_OPTIONS='--color=auto'
alias ls='ls $LS_OPTIONS'

# Export PS1 so it's used in all shells
export PS1
