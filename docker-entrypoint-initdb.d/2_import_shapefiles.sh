#!/bin/bash
set -e

# Import shapefiles into PostGIS
# -I : Create a GiST index on the geometry column
# -s : SRID of the shapefile
shp2pgsql -a -s 4326 /data/water_polygons.shp regions | psql -U $POSTGRES_USER -d $POSTGRES_DB
psql -U $POSTGRES_USER -d $POSTGRES_DB -c "UPDATE regions SET waterType = 1 WHERE waterType IS NULL;"
