#!/bin/bash

set -eu -o pipefail

# check if macOS is used warn if not
if [[ $(uname) != "Darwin" ]]; then
    echo "[WARN] This script is intended to be run on macOS."
fi


# Variables
BREW_PYTHON="/opt/homebrew/opt/python@3/libexec/bin/python"


# Function to install brew packages
brew_install() {    
    brew update

    echo "Installing sqlite3, spatialite-tools, and python3 using brew..."
    # for macos, setup sqlite3 for enabling extension
    # since built-in sqlite3 does not support extension
    brew install sqlite3
    brew install spatialite-tools

    echo
    echo "To add brew installed sqlite3 to PATH, add the following line to your shell configuration file (e.g. ~/.zshrc)"
    echo "export PATH=\"/opt/homebrew/opt/sqlite/bin:\$PATH\" >> ~/.zshrc"
    echo

}

brew_venv_python() {
    # to avoid error message: `AttributeError: 'sqlite3.Connection' object has no attribute 'enable_load_extension'`
    # use brew installed python. see: https://docs.datasette.io/en/stable/installation.html#a-note-about-extensions

    echo "Installing python3 using brew and creating a virtual environment at $1..."
    brew install python3

    # create virtual environment
    $BREW_PYTHON -m venv $1

    echo
    echo "To activate the virtual environment, run the following command:"
    echo "source $1/bin/activate"
    echo
}


# Main
brew_install

# if $1 is set, install python3 using brew and create a virtual environment at $1
if [[ -n "${1:-}" ]]; then
    brew_venv_python $1
else
    echo
    echo "To install python3 using brew and create a virtual environment at a custom location, run the following command:"
    echo "$0 /path/to/virtualenv"
fi
