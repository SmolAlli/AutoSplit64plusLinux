#!/bin/bash
# AutoSplit64+ Linux Launcher
# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Check if python 3.11 is available
if command -v python3.11 &> /dev/null; then
    PYTHON_CMD="python3.11"
else
    # Fallback to python3, but warn
    PYTHON_CMD="python3"
    echo "Warning: Python 3.11 not explicitly found, trying $PYTHON_CMD"
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
