#!/bin/bash
# AutoSplit64+ Linux Launcher
# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Activate the virtual environment and run the script
if [ -d "$SCRIPT_DIR/.venv" ]; then
    "$SCRIPT_DIR/.venv/bin/python" "$SCRIPT_DIR/AutoSplit64.py"
else
    echo "Virtual environment not found in $SCRIPT_DIR/.venv"
    echo "Please run 'pip install -r requirements.txt' to install dependencies first."
    exit 1
fi
