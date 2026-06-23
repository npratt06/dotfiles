#!/bin/zsh

SESSION="main"

# Check if the session already exists — if so, just attach
tmux has-session -t $SESSION 2>/dev/null

if [ $? != 0 ]; then
    # ── Window 1: home ────────────────────────────────────────────────────────
    # General purpose window — downloads, config editing, misc CLI tasks.
    # Starting point for any new machine where repo layout isn't assumed.
    tmux new-session -d -s $SESSION -n home -c ~
fi

# Attach to the session
tmux attach -t $SESSION
