#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tmux bind-key -T prefix r run-shell "bash -c 'source $CURRENT_DIR/scripts/menu.sh && show_menu'"
