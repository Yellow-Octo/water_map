#!/bin/bash
set -e

# Import shapefiles into PostGIS
# -a : Append to the existing table
# -s : SRID of the shapefile
shp2pgsql -a -s 4326 /data/$SHAPE_FILE_NAME $TABLE_NAME | awk -F"'" '/INSERT INTO/ {print "INSERT INTO '"$TABLE_NAME"' (geom) VALUES ('\''" $(NF-1) "'\'');"}' | psql -U $POSTGRES_USER -d $POSTGRES_DB
psql -U $POSTGRES_USER -d $POSTGRES_DB <<-EOSQL
UPDATE $TABLE_NAME SET $WATER_TYPE_COLUMN_NAME = 1 WHERE $WATER_TYPE_COLUMN_NAME IS NULL;
EOSQL
