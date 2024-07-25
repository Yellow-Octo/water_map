#!/bin/bash
set -e

# Record start time
start_time=$(date +%s)

# Create a temporary file
TEMP_FILE=$(mktemp)

# Import shapefiles into PostGIS and prepare data for COPY
shp2pgsql -a -s 4326 /data/$SHAPE_FILE_NAME $TABLE_NAME |
awk -F"'" '/INSERT INTO/ {print $(NF-1)}' > $TEMP_FILE

# Use COPY to bulk insert data with optimizations
psql -U $POSTGRES_USER -d $POSTGRES_DB <<-EOSQL

ALTER TABLE $TABLE_NAME SET UNLOGGED;

BEGIN;
COPY $TABLE_NAME (geom) FROM '$TEMP_FILE' WITH (FORMAT text);
COMMIT;

ALTER TABLE $TABLE_NAME SET LOGGED;

UPDATE $TABLE_NAME SET $WATER_TYPE_COLUMN_NAME = 1 WHERE $WATER_TYPE_COLUMN_NAME IS NULL;
EOSQL

# Remove temporary file
rm $TEMP_FILE

end_time=$(date +%s)
duration=$((end_time - start_time))
echo "Import completed in $(awk -v t=$duration 'BEGIN{t=int(t); printf "%dm%ds", t/60, t%60}')"
