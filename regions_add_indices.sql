-- Create a B-tree index on waterType
CREATE INDEX idx_regions_watertype ON regions (waterType);

-- Create a GiST index on shape
CREATE INDEX idx_regions_shape ON regions USING GIST (shape);
