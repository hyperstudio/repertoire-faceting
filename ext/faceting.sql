--
-- In-database support for Repertoire faceting module.
--
-- This library adds scalable faceted indexing to the PostgreSQL database.
-- Basic approach is similar to other faceted browsers (Solr, Exhibit): an inverted bitmap index
-- allows fast computation of facet value counts, given a base context and prior facet refinements.
--
-- The same bitsets can be used to compute the result set of items.
--
-- The library consists of: 
--
--   (a) a user defined bitset datatype ('signature') for storing inverted indices
--   from facet values to items, and doing refinements and counts on items with a given
--   facet value (see signature.sql, signature.c)
--
--   (b) facilities for adding a packed id sequence to the main item table.  packed ids
--   are used in the facet value signatures
--
--   (c) functions for declaring facets and updating facet indices
--
--   (d) two usage patterns: periodic auto-index (when used with Repertoire crontab support); or
--   explicit per-item updates
--
--
-- Installation
--
--    (1) [ optional ] install Repertoire crontab support
--    (2) compile signature.c
--    (3) source signature.sql as a superuser (e.g. postgres)
--    (4) source faceting.sql normal database user
--  

-- Facet declarations table

CREATE TABLE _facets(
  context TEXT NOT NULL,
  name TEXT NOT NULL,
  value_expr TEXT,
  from_expr TEXT CHECK (from_expr IS NULL OR from_expr LIKE 'FROM %'),
  PRIMARY KEY (context, name)
);

-- Utility functions for naming facet index tables and sequences

CREATE OR REPLACE FUNCTION facet_table_name(context TEXT, name TEXT) RETURNS TEXT AS $$
BEGIN
  RETURN quote_ident('_' || context || '_' || name || '_facet');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION facet_seq_name(context TEXT) RETURNS TEXT AS $$
BEGIN
  RETURN quote_ident('_' || context || '_packed_id_seq');
END;
$$ LANGUAGE plpgsql;

-- Declare that a table will be used as faceting context  [ provides for packed ids ]

CREATE OR REPLACE FUNCTION declare_context(context TEXT) RETURNS VOID AS $$
BEGIN
  EXECUTE 'CREATE SEQUENCE ' || facet_seq_name(context);
  EXECUTE 'ALTER TABLE ' || quote_ident(context) || ' ADD COLUMN _packed_id INT UNIQUE DEFAULT nextval( ''' || facet_seq_name(context) || ''' )';
END;
$$ LANGUAGE plpgsql;

-- Update all facet counts for the given context

CREATE OR REPLACE FUNCTION reindex_facets(context TEXT) RETURNS VOID AS $$
BEGIN
  -- Pack index ids
  EXECUTE 'ALTER SEQUENCE ' || facet_seq_name(context) || ' RESTART WITH 1';
  EXECUTE 'UPDATE production SET _packed_id = nextval( ''' || facet_seq_name(context) || ''' )';
  -- Update facets for context table
  PERFORM reindex_facets(context, NULL);
END;
$$ LANGUAGE plpgsql;

-- Update all facet counts for the given context and id
-- TODO.  Should raise an error if the context is not found

CREATE OR REPLACE FUNCTION reindex_facets(context TEXT, packed_id INT) RETURNS VOID AS $$
DECLARE
  facet RECORD;
  sql TEXT;
BEGIN
  -- Update facets for context table
  FOR facet IN SELECT * FROM _facets WHERE _facets.context = context LOOP
    
    -- From expr defaults to context table
    IF (facet.from_expr IS NULL) THEN
      facet.from_expr = 'FROM ' || facet.context;
    END IF;

    -- Column expr defaults to facet name
    IF (facet.value_expr IS NULL) THEN
      facet.value_expr = facet.name;
    END IF;

    -- Remove old facet value table
    EXECUTE 'DROP TABLE IF EXISTS ' || facet_table_name(context, facet.name);
    
    -- Clause to create facet value table, with signature of ids
    sql = 'CREATE TABLE ' || facet_table_name(context, facet.name) || ' AS '
         ||   ' SELECT ' || facet.value_expr || ', sig_collect(' || context || '._packed_id) AS signature '
         ||   facet.from_expr;
    
    -- Clause to update a specific row, if necessary
    IF (packed_id IS NOT NULL) THEN
      IF (NOT like(sql, '%WHERE%')) THEN
        sql = sql || ' WHERE _packed_id = ' || quote_literal(packed_id);
      ELSE  
        sql = sql || ' AND _packed_id = ' || quote_literal(packed_id);
      END IF;
    END IF;
    
    -- Clause to collect models by facet value
    sql = sql || ' GROUP BY ' || facet.value_expr;
    
    EXECUTE sql;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

