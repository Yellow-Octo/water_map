# Water Map
This docker image creates a postgis database that contains geometries of the world's oceans. You can query the database for whether a given lat & lng is salt water. 

In the future, freshwater can also be added but for now we only are inserting salt water geometries. 

## data source
Water shape files are taken from cleaned up data. They have split up the data into 1 degree squares. They source it from openstreetmap but have done some processing to clean up abberations.
https://osmdata.openstreetmap.de/data/water-polygons.html

We host our own copy of the zip file in the releases section for consistency during builds

## Example query
```postgresql
-- Boston docks
SELECT EXISTS (
    SELECT 1
    FROM public.regions
    WHERE ST_Intersects(
            geom,
            ST_SetSRID(ST_MakePoint(-71.03096089695921, 42.34720586744334), 4326)
          )
      AND watertype = 1
) AS is_in_ocean;
-- false

-- Boston Harbor
SELECT EXISTS (
    SELECT 1
    FROM public.regions
    WHERE ST_Intersects(
            geom,
            ST_SetSRID(ST_MakePoint(-70.988669, 42.340958), 4326)
          )
      AND watertype = 1
) AS is_in_ocean;
-- true
```
