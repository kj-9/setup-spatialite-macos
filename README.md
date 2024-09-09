# setup-spatialite-macos

this repo is a simple way to setup python virtual environment with [spatialite](https://www.gaia-gis.it/fossil/libspatialite/index) support on macos.

## setup
run:
```
curl -sL https://raw.githubusercontent.com/kj-9/setup-spatialite-macos/main/scripts/setup.sh | \
  bash -s -- .venv
```

does:
- run brew to install sqlite3 (with extension support) and spatialite-tools
- run brew to install python3 (with sqlite3 extension support)
- create a python virtual environment at `.venv` (you can change the path as needed)


created venv uses brew installed python3, so it should have sqlite3 with extension support.
after running the setup script, you need to use brew installed sqlite3, so you might want to run:

```sh
echo "export PATH=/usr/local/opt/sqlite/bin:$PATH" >> .zshrc
```

you can change venv path by changing the `.venv` in the command above.

if only runs `bash -s` without the venv path, it will not create a virtual environment, but will install the required packages.


## why use brew installed python3

- macOS's system sqlite3 is not compiled with extension (like spatialite) support
- if you use spatialite from python, it needs to be built with sqlite extension support (see also: [here](https://docs.datasette.io/en/stable/installation.html#a-note-about-extensions))

using brew to install sqlite3 and python3 and using these are the basis for this setup.


## example usage

activate the virtual environment:
```sh
source .venv/bin/activate
```

initialize a new sqlite database with spatialite extension:
```sh
python -m sqlite_utils create-database sample.db --init-spatialite
```
where
- `sample.db` is the sqlite database file, created by sqlite-utils
- use `python -m` to run the sqlite-utils module to ensure the brew isntalled python venv environment is used

using sqlite-utils to load spatialite extension and check version:
```sh
python -m sqlite_utils --load-extension=spatialite \
    sample.db "select spatialite_version()"
```

loading geojson data into the database using spatialite function `ImportGeoJSON`:
```sh
SPATIALITE_SECURITY=relaxed python -m sqlite_utils --load-extension=spatialite \
    sample.db "select ImportGeoJSON('points.json', 'points')"
```

where
- `SPATIALITE_SECURITY=relaxed` is required for some functions like `ImportGeoJSON` / `ExportGeoJSON` to work
   - check [each functions documentation](https://www.gaia-gis.it/gaia-sins/spatialite-sql-latest.html) for more details

`ImportGeoJSON` is great but it auto create `pk_uid` primary key column, which is not always what you want:

show table ddl:
```sh
python -m sqlite_utils schema sample.db points

CREATE TABLE "points" (
        pk_uid INTEGER PRIMARY KEY AUTOINCREMENT,
        "name" TEXT, "geometry" POINT)
```

so drop the table and recreate it with `geojson-to-sqlite`:
```sh
python -m sqlite_utils --load-extension=spatialite \
    sample.db "select DropTable(NULL,'points')"

python -c "from geojson_to_sqlite.cli import cli;cli()" \
  sample.db points points.json --spatialite --pk name

python -m sqlite_utils schema sample.db points

CREATE TABLE [points] (
   [name] TEXT PRIMARY KEY
, "geometry" GEOMETRY)
```

where `--pk name` is used to specify the primary key column name to be used.

you can export spatialite table to geojson using `ExportGeoJSON`:
```sh
SPATIALITE_SECURITY=relaxed python -m sqlite_utils --load-extension=spatialite \
    sample.db "select ExportGeoJSON2('points', 'geometry', 'points-export.json')"
```
