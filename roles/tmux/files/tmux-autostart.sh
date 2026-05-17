#!/bin/bash
# Auto-start tmux on interactive login.
#
# Guards (all must pass before tmux is started):
#   - tmux is installed
#   - this is an interactive shell ($- contains 'i') with a prompt ($PS1 set)
#   - we are not already inside a tmux session ($TMUX unset)
# These prevent the script from interfering with scp/sftp, cron, or
# Ansible's own non-interactive SSH sessions.
if command -v tmux >/dev/null 2>&1 \
  && [ -n "$PS1" ] \
  && [[ "$-" == *i* ]] \
  && [ -z "$TMUX" ]; then
  # Attach to an existing "main" session, or create one if none exists.
  exec tmux new-session -A -s main
fi
