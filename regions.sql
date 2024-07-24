-- water.sql
CREATE TABLE IF NOT EXISTS regions (
    gid serial PRIMARY KEY,
    shape geometry(MultiPolygon, 4326),
    waterType integer
);
