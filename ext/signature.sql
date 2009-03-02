--
-- In-database support for Repertoire faceting module.
--
-- This library adds scalable faceted indexing to the PostgreSQL database.
-- Basic approach is similar to other faceted browsers (Solr, Exhibit): an inverted bitmap index
-- allows fast computation of facet value counts, given a base context and prior facet refinements.
--
-- Bitsets can also be used to compute the result set of items.
--
-- The library consists of: 
--
--   (a) a user defined bitset datatype ('signature') for storing inverted indices
--   from facet values to items, and doing refinements and counts on items with a given
--   facet value (see signature.sql, signature.c)
--
--   (b) facilities for adding a packed (continuous) id sequence to the main item table.  packed ids
--   are used in the facet value signatures
--
--   (c) utility functions for creating/updating packed ids and facet value index tables, esp. for
--   use with Repertoire crontab support
--
--
-- Installation
--
--    (1) gem install repertoire_faceting [ builds c extensions automatically ]
--    (2) psql -Upostgres <your database> -f ext/signature.sql [ installs SQL wrapper functions ]
--    (3) [ optional ] install Repertoire crontab support [ see wiki ]
--  

SET search_path TO 'public';

CREATE OR REPLACE FUNCTION sig_in(cstring)
RETURNS signature
AS 'signature.so', 'sig_in'
LANGUAGE C STRICT;

CREATE OR REPLACE FUNCTION sig_out(signature)
RETURNS cstring
AS 'signature.so', 'sig_out'
LANGUAGE C STRICT;

CREATE TYPE signature (
	INTERNALLENGTH = VARIABLE,
	INPUT = sig_in,
	OUTPUT = sig_out,
	STORAGE = extended
);

CREATE OR REPLACE FUNCTION sig_resize( signature, INT )
  RETURNS signature
  AS 'signature.so', 'sig_resize'
  LANGUAGE C STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION sig_set( signature, INT, INT )
  RETURNS signature
  AS 'signature.so', 'sig_set'
  LANGUAGE C STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION sig_set( signature, INT )
 RETURNS signature
 AS 'signature.so', 'sig_set'
 LANGUAGE C STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION sig_get( signature, INT )
  RETURNS INT
  AS 'signature.so', 'sig_get'
  LANGUAGE C STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION sig_length( signature )
	RETURNS INT
	AS 'signature.so', 'sig_length'
	LANGUAGE C STRICT IMMUTABLE;
	
CREATE OR REPLACE FUNCTION sig_min( signature )
	RETURNS INT
	AS 'signature.so', 'sig_min'
	LANGUAGE C STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION sig_and( signature, signature )
 RETURNS signature
 AS 'signature.so', 'sig_and'
 LANGUAGE C STRICT IMMUTABLE;	

CREATE OR REPLACE FUNCTION sig_or( signature, signature )
RETURNS signature
AS 'signature.so', 'sig_or'
LANGUAGE C STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION sig_xor( signature )
 RETURNS signature
 AS 'signature.so', 'sig_xor'
 LANGUAGE C STRICT IMMUTABLE;
 
CREATE OR REPLACE FUNCTION count( signature )
	RETURNS INT
	AS 'signature.so', 'count'
	LANGUAGE C STRICT IMMUTABLE;
	
CREATE OR REPLACE FUNCTION contains( signature, INT )
  RETURNS BOOL
  AS 'signature.so', 'contains'
  LANGUAGE C STRICT IMMUTABLE;
 
-- operators for signatures

CREATE OPERATOR & (
    leftarg = signature,
    rightarg = signature,
    procedure = sig_and,
    commutator = &
);

CREATE OPERATOR | (
    leftarg = signature,
    rightarg = signature,
    procedure = sig_or,
    commutator = |
);

CREATE OPERATOR + (
    leftarg = signature,
    rightarg = int,
    procedure = sig_set
);

-- aggregate functions for faceting

CREATE AGGREGATE signature( INT )
(
	sfunc = sig_set,
	stype = signature,
	initcond = ''
);

CREATE AGGREGATE collect( signature )
(
	sfunc = sig_or,
	stype = signature
);

CREATE AGGREGATE filter( signature )
(
   sfunc = sig_and,
   stype = signature
);

-- utility functions for maintaining facet indices

CREATE OR REPLACE FUNCTION renumber_table(tbl TEXT, col TEXT) RETURNS VOID AS $$
DECLARE
  seq TEXT;
BEGIN
  seq = tbl || '_' || col || '_seq';

  -- Set up numbered column if it doesn't already exist
  SET client_min_messages = 'WARNING';
  BEGIN
    EXECUTE 'CREATE SEQUENCE ' || quote_ident(seq) || ' MINVALUE 0 ';
    EXECUTE 'ALTER TABLE ' || quote_ident(tbl) || ' ADD COLUMN ' || quote_ident(col) || ' INT4 DEFAULT nextval(''' || quote_ident(seq) || ''')';
    EXECUTE 'ALTER SEQUENCE ' || quote_ident(seq) || ' OWNED BY ' || quote_ident(tbl) || '.' || quote_ident(col);
  EXCEPTION
    WHEN duplicate_table THEN NULL;
    WHEN duplicate_column THEN NULL;
  END;
  RESET client_min_messages;

  --  Update numbered column
  EXECUTE 'ALTER SEQUENCE ' || quote_ident(tbl || '_' || col || '_seq') || ' RESTART 0';
  EXECUTE 'UPDATE ' || quote_ident(tbl) || ' SET ' || quote_ident(col) || ' = DEFAULT';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION recreate_table(tbl TEXT, select_expr TEXT) RETURNS VOID AS $$
BEGIN
  SET client_min_messages = warning;
  EXECUTE 'DROP TABLE IF EXISTS ' || quote_ident(tbl);
  EXECUTE 'CREATE TABLE ' || quote_ident(tbl) || ' AS ' || select_expr;
  RESET client_min_messages;
END;
$$ LANGUAGE plpgsql;
