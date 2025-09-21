#!/bin/bash

brew update

# Install pyenv and Python 3.13.7
brew install pyenv
pyenv install -s 3.13.7
brew install pyenv-virtualenv

# Install GNU Make
brew install make

# Install tfenv and Terraform 1.13.0
brew install tfenv
tfenv install 1.13.0
tfenv use 1.13.0

# Initialize pyenv and pyenv-virtualenv
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Create and activate the virtual environment and install dependencies
pyenv virtualenv 3.13.7 demo-data-product-at-scale
pyenv activate demo-data-product-at-scale
pip install -r ./scripts/requirements.txt