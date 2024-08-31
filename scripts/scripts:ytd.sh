
# for macos, setup sqlite3 for enabling extension
# since built-in sqlite3 does not support extension
brew install sqlite3

# if you like, add path to .zshrc
# echo 'export PATH="/opt/homebrew/opt/sqlite/bin:$PATH"' >> ~/.zshrc

brew install spatialite-tools

# to avoid error message: `AttributeError: 'sqlite3.Connection' object has no attribute 'enable_load_extension'`
# use brew installed python. see: https://docs.datasette.io/en/stable/installation.html#a-note-about-extensions
brew install python

 /opt/homebrew/opt/python@3/libexec/bin/python -m venv .venv

# `brew --prefix` to show the path of installed package
source .venv/bin/activate
python -m pip install sqlite-utils

python -m sqlite_utils --load-extension=/opt/homebrew/lib/mod_spatialite.dylib \
    nakaji-map-data.db "select spatialite_version()"


SPATIALITE_SECURITY=relaxed python -m sqlite_utils --load-extension=/opt/homebrew/lib/mod_spatialite.dylib \
    nakaji-map-data.db "select DropTable(NULL,'app_geojson')"

SPATIALITE_SECURITY=relaxed python -m sqlite_utils --load-extension=/opt/homebrew/lib/mod_spatialite.dylib \
    nakaji-map-data.db "select ImportGeoJSON('nakaji-map/data/app-geojson.json', 'app_geojson')"

SPATIALITE_SECURITY=relaxed python -m sqlite_utils --load-extension=/opt/homebrew/lib/mod_spatialite.dylib \
    nakaji-map-data.db "select ImportGeoJSON('nakaji-map/data/app-geojson.json', 'app_geojson', 'geometry', FALSE, 0, 'SAME')"

# cannot invoke -m geojson_to_sqlite directly
python -c "from geojson_to_sqlite.cli import cli;cli()" \
  nakaji-map-data.db features nakaji-map/data/app-geojson.json --spatialite --pk video_id
