#!/bin/bash

psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" <<-EOSQL
CREATE TABLE IF NOT EXISTS $TABLE_NAME (
        id serial PRIMARY KEY,
        $GEOMETRY_COLUMN_NAME geometry(MultiPolygon, 4326),
        $WATER_TYPE_COLUMN_NAME smallint
    );
EOSQL
