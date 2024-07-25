#!/bin/bash
set -e

# Create a temporary file
TEMP_FILE=$(mktemp)

# Import shapefiles into PostGIS and prepare data for COPY
shp2pgsql -a -s 4326 /data/$SHAPE_FILE_NAME $TABLE_NAME |
awk -F"'" '/INSERT INTO/ {print $(NF-1)}' > $TEMP_FILE

# Use COPY to bulk insert data
psql -U $POSTGRES_USER -d $POSTGRES_DB <<-EOSQL
COPY $TABLE_NAME (geom) FROM '$TEMP_FILE' WITH (FORMAT text);
UPDATE $TABLE_NAME SET $WATER_TYPE_COLUMN_NAME = 1 WHERE $WATER_TYPE_COLUMN_NAME IS NULL;
EOSQL

# Remove temporary file
rm $TEMP_FILE
