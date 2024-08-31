# setup-spatialite-macos

since [spatialite](https://www.gaia-gis.it/fossil/libspatialite/index) requires some setup on macOS,
this repo is a simple way to get started with spatialite on macOS.


- macos installed sqlite3 is not compiled with extension (spatialite) support
- python also needs to be installed with sqlite3 extension support (see also: [here](https://docs.datasette.io/en/stable/installation.html#a-note-about-extensions)

using brew to install sqlite3 and python3 and using these are the basis for this setup.


## setup
run:
```
make setup
```

does:
- run brew install sqlite and python3
- run pip install [sqlite-utils](https://sqlite-utils.datasette.io/en/stable/), [geojson-to-sqlite](https://github.com/simonw/geojson-to-sqlite) which are optional but useful tools for working with spatialite.



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
