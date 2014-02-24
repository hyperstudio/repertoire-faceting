-- utility functions for maintaining facet indices

-- Utility function to drop and recreate a table, given an sql select statement
--
CREATE FUNCTION @extschema@.recreate_table(tbl TEXT, select_expr TEXT) RETURNS VOID AS $$
BEGIN
  SET client_min_messages = warning;
  EXECUTE 'DROP TABLE IF EXISTS ' || quote_ident(tbl);
  EXECUTE 'CREATE TABLE ' || quote_ident(tbl) || ' AS ' || select_expr;
  RESET client_min_messages;
END;
$$ LANGUAGE plpgsql;

-- Utility function to add or update a packed id column on a table
-- 
-- If provided, the threshold indicates a percentage of acceptable wastage or "scatter" 
-- in the ids, which keeps the packing algorithm from running until absolutely needed.
-- 
-- Because ids only become scattered when model rows are deleted, this means repacking
-- will occur very infrequently.  The default threshold is 15%.
--
CREATE FUNCTION @extschema@.renumber_table(tbl TEXT, col TEXT) RETURNS BOOLEAN AS $$
BEGIN
  RETURN renumber_table(tbl, col, 0.15);
END;
$$ LANGUAGE plpgsql;


CREATE FUNCTION @extschema@.renumber_table(tbl TEXT, col TEXT, threshold REAL) RETURNS BOOLEAN AS $$
DECLARE
  seq TEXT;
  wastage REAL;
  renumber BOOLEAN;
BEGIN
  seq = tbl || '_' || col || '_seq';

  -- Drop numbered column if it already exists
  SET client_min_messages = 'WARNING';
  BEGIN
    IF signature_wastage(tbl, col) <= threshold THEN
      renumber := false;
    ELSE
      renumber := true;
      EXECUTE 'DROP INDEX IF EXISTS ' || quote_ident(tbl || '_' || col || '_ndx');
      EXECUTE 'ALTER TABLE ' || quote_ident(tbl) || ' DROP COLUMN ' || quote_ident(col);
      EXECUTE 'DROP SEQUENCE IF EXISTS ' || quote_ident(seq);
    END IF;
  EXCEPTION
    WHEN undefined_column THEN renumber := true;
  END;
  RESET client_min_messages;

  --  Create numbered column & its index
  IF renumber THEN
    EXECUTE 'CREATE SEQUENCE ' || quote_ident(seq) || ' MINVALUE 0 ';
    EXECUTE 'ALTER TABLE ' || quote_ident(tbl) || ' ADD COLUMN ' || quote_ident(col) || ' INT4 DEFAULT nextval(''' || quote_ident(seq) || ''')';
    EXECUTE 'ALTER SEQUENCE ' || quote_ident(seq) || ' OWNED BY ' || quote_ident(tbl) || '.' || quote_ident(col);
    EXECUTE 'CREATE INDEX ' || quote_ident(tbl || '_' || col || '_ndx') || ' ON ' || quote_ident(tbl) || '(' || col || ')';
  END IF;

  RETURN renumber;
END;
$$ LANGUAGE plpgsql;


-- Utility function to measure how many bits from a loosely-packed id column would be wasted,
-- if they were all collected into a bitset signature. Returns a float between 0 (no waste) 
-- and 1.0 (all waste).
--
CREATE FUNCTION @extschema@.signature_wastage(tbl TEXT, col TEXT) RETURNS REAL AS $$
DECLARE
  max REAL;
  count REAL;
BEGIN
  EXECUTE 'SELECT count(*) FROM ' || quote_ident(tbl)
          INTO count;
  EXECUTE 'SELECT max(' || quote_ident(col) || ') FROM ' || quote_ident(tbl)
          INTO max;
  RETURN 1.0 - (count / (COALESCE(max, 0) + 1));
END;
$$ LANGUAGE plpgsql;


-- Utility function to identify columns for a nested facet index
--
CREATE FUNCTION @extschema@.nest_levels(tbl TEXT) RETURNS SETOF TEXT AS $$
  SELECT quote_ident(a.attname::TEXT)
    FROM pg_attribute a LEFT JOIN pg_attrdef d ON a.attrelid = d.adrelid AND a.attnum = d.adnum
    WHERE a.attrelid = $1::regclass
      AND NOT a.attname IN ('signature', 'level')
      AND a.attnum > 0 AND NOT a.attisdropped
    ORDER BY a.attnum;
$$ LANGUAGE sql;


--Utility function to expand nesting in facet indices
--
-- Initially a facet index will include only leaves of the
-- nesting tree.  This function adds all interior nodes
-- with their respective aggregate signatures, and adds a
-- postgresql index to the nested facet value.
--
-- e.g. given the nested facet values
--  {USA,Florida}  '10'
--  {USA,Iowa}     '01'
--
-- the function interpolates
--  {USA}          '11'
--
-- N.B. expand_nesting may only be called once on a table
--      it refuses to add internal node duplicates
--
CREATE FUNCTION @extschema@.expand_nesting(tbl TEXT) RETURNS VOID AS $$
DECLARE
  cols  TEXT[];
  len   INT;
  aggr  TEXT;
BEGIN
  -- determine column names
  SELECT array_agg(col) INTO cols FROM nest_levels(tbl) AS col;
  len := array_length(cols, 1);
  
  -- add unique index on facet value columns
  aggr := array_to_string(cols, ', ');
  EXECUTE 'CREATE UNIQUE INDEX ' || quote_ident(tbl) || '_ndx  ON ' || quote_ident(tbl) || '(' || aggr || ')';
    
  -- expand each level in turn
  FOR i IN REVERSE (len-1)..1 LOOP
    aggr := array_to_string(cols[1:i], ', ');
    EXECUTE 'INSERT INTO ' || quote_ident(tbl) || '(' || aggr || ', level, signature)'
         || ' SELECT ' || aggr || ', ' || i || ' AS level, collect(signature)'
         || ' FROM ' || quote_ident(tbl)
         || ' GROUP BY ' || aggr;
  END LOOP;
  
  -- root node
  EXECUTE 'INSERT INTO ' || quote_ident(tbl) || '(level, signature)'
       || ' SELECT 0 AS level, collect(signature) FROM ' || quote_ident(tbl);
END;
$$ LANGUAGE plpgsql;
