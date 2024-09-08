# add path brew sqlite to PATH
export PATH := /opt/homebrew/opt/sqlite/bin:$(PATH)

SHELL := /bin/bash

VENV := .venv
VENV_ACTIVATE := $(VENV)/bin/activate

BREW_PYTHON := /opt/homebrew/opt/python@3/libexec/bin/python 
VENV_PYTHON := $(VENV)/bin/python

ifneq ($(shell uname), Darwin)
$(warning This makefile is intended to be run on macOS)
endif

# create venv with brew python
$(VENV):
	$(BREW_PYTHON) -m venv $(VENV)

.PHONY: brew-install
brew-install:
	bash scripts/brew-install.sh

.PHONY: pip-install
pip-install:
	$(VENV_PYTHON) -m pip install -r requirements.txt

.PHONY: setup
setup: brew-install $(VENV) pip-install
	

