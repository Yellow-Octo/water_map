#!/bin/bash
set -e

start_time=$(date +%s)

# Set the batch size
BATCH_SIZE=200

# Set table to UNLOGGED, import data, then set back to LOGGED
psql -U $POSTGRES_USER -d $POSTGRES_DB <<-EOSQL
ALTER TABLE $TABLE_NAME SET UNLOGGED;
EOSQL

# Import shapefiles into PostGIS
shp2pgsql -a -s 4326 /data/$SHAPE_FILE_NAME $TABLE_NAME |
awk -v batch_size=$BATCH_SIZE -F"'" '
BEGIN {
    count = 0
}
/INSERT INTO/ {
    if (count % batch_size == 0) {
        if (count > 0) print ";"
        printf "INSERT INTO '"$TABLE_NAME"' (geom) VALUES "
    } else {
        printf ", "
    }
    printf "('\''" $(NF-1) "'\'')"
    count++
}
END {
    if (count > 0) print ";"
}' |
psql -U $POSTGRES_USER -d $POSTGRES_DB

psql -U $POSTGRES_USER -d $POSTGRES_DB <<-EOSQL
UPDATE $TABLE_NAME SET $WATER_TYPE_COLUMN_NAME = 1 WHERE $WATER_TYPE_COLUMN_NAME IS NULL;
EOSQL

# Set table back to LOGGED
psql -U $POSTGRES_USER -d $POSTGRES_DB <<-EOSQL
ALTER TABLE $TABLE_NAME SET LOGGED;
EOSQL


end_time=$(date +%s)
duration=$((end_time - start_time))
echo -e "\033[34mImport completed in $(awk -v t=$duration 'BEGIN{t=int(t); printf "%dm%ds", t/60, t%60}')\033[0m"
