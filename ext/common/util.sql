-- ============================================================================
-- These functions are common to all bindings of the Repertoire faceting API
--
-- Christopher York
-- MIT Hyperstudio
-- February 2014
-- ============================================================================


-- Aggregator to measure how many bits from a loosely-packed id column would be wasted, if
-- they were all collected into a bitset signature. Returns a float between 0 (no waste)
-- and 1.0 (all waste). An example of its use:
--
-- SELECT wastage(id) FROM nobelists
--  =# 0.999999
--
-- ALTER TABLE nobelists ADD COLUMN _packed_id SERIAL
-- SELECT wastage(_packed_id) FROM nobelists
--  =# 0.015625
--
CREATE FUNCTION @extschema@.wastage_proportion( state INT[] ) RETURNS double precision AS $$
  SELECT (1.0 - (state[1]::double precision / (COALESCE(state[2], 0.0) + 1.0)))
$$ LANGUAGE sql;

CREATE FUNCTION @extschema@.wastage_accum( state INT[], val INT ) RETURNS INT[] AS $$
  SELECT ARRAY[ state[1]+1, GREATEST(state[2], val) ];
$$ LANGUAGE sql;

CREATE AGGREGATE @extschema@.wastage( INT )
(
	sfunc = @extschema@.wastage_accum,
	stype = INT[],
	finalfunc = @extschema@.wastage_proportion,
	initcond = '{0,0}'
);