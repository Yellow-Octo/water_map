#!/bin/bash
set -e

# Download and unzip the shapefile
curl -o water-polygons.zip https://osmdata.openstreetmap.de/download/water-polygons-split-4326.zip && \
    unzip -j water-polygons.zip -d /data && \
    rm water-polygons.zip

psql -U $POSTGRES_USER -d $POSTGRES_DB -f regions.sql


# Import shapefiles into PostGIS
# -I : Create a GiST index on the geometry column
# -s : SRID of the shapefile
shp2pgsql -a -s 4326 /data/water_polygons.shp regions | psql -U $POSTGRES_USER -d $POSTGRES_DB

psql -U $POSTGRES_USER -d $POSTGRES_DB -c "UPDATE regions SET waterType = 1 WHERE waterType IS NULL;"

#room in future to add freshwater

# Add indices ad the end once we have all regions in the table
psql -U $POSTGRES_USER -d $POSTGRES_DB -f regions_add_indices.sql
