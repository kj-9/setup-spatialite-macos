brew update

# for macos, setup sqlite3 for enabling extension
# since built-in sqlite3 does not support extension
brew install sqlite3
# add path to .zshrc
# echo 'export PATH="/opt/homebrew/opt/sqlite/bin:$PATH"' >> ~/.zshrc

brew install spatialite-tools

# to avoid error message: `AttributeError: 'sqlite3.Connection' object has no attribute 'enable_load_extension'`
# use brew installed python. see: https://docs.datasette.io/en/stable/installation.html#a-note-about-extensions
brew install python3
