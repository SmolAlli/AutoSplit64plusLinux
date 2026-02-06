#!/bin/bash
# AppImage entry point

# The AppImage runtime sets APPDIR
if [ -z "$APPDIR" ]; then
    APPDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi

# Set up environment
export PATH="$APPDIR/usr/bin:$PATH"
export LD_LIBRARY_PATH="$APPDIR/usr/lib:$LD_LIBRARY_PATH"
# Add application source to PYTHONPATH
export PYTHONPATH="$APPDIR/usr/src:$PYTHONPATH"

# Run the application
# We use the python executable bundled in the AppImage
exec "$APPDIR/usr/bin/python3" "$APPDIR/usr/src/AutoSplit64.py" "$@"
