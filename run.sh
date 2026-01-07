#!/bin/bash
# AutoSplit64+ Linux Launcher
# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Check if python 3.11 is available
PYTHON_CMD=""

# Try to detect pyenv and configure it for this session
if command -v pyenv &> /dev/null; then
  # Find installed 3.11 version
  PY_VER=$(pyenv versions --bare | grep "^3\.11" | head -n 1)
  if [ -n "$PY_VER" ]; then
    export PYENV_VERSION="$PY_VER"
    echo "Using pyenv python version: $PY_VER"
    PYTHON_CMD="python"
  fi
fi

if [ -z "$PYTHON_CMD" ]; then
    if command -v python3.11 &> /dev/null; then
        PYTHON_CMD="python3.11"
    else
        # Fallback to python3, but warn
        PYTHON_CMD="python3"
        echo "Warning: Python 3.11 not explicitly found, trying $PYTHON_CMD"
    fi
fi

# Check for virtual environment
if [ ! -d "$SCRIPT_DIR/.venv" ]; then
    echo "Creating virtual environment..."
    $PYTHON_CMD -m venv "$SCRIPT_DIR/.venv"
    if [ $? -ne 0 ]; then
        echo "Failed to create virtual environment with $PYTHON_CMD"
        exit 1
    fi
    
    echo "Installing dependencies..."
    "$SCRIPT_DIR/.venv/bin/pip" install -r "$SCRIPT_DIR/requirements.txt"
    if [ $? -ne 0 ]; then
        echo "Failed to install dependencies"
        exit 1
    fi
fi

# Run the application
"$SCRIPT_DIR/.venv/bin/python" "$SCRIPT_DIR/AutoSplit64.py"
