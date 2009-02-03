--
-- Basic datatype support ('signature') for Repertoire faceting module.
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

CREATE OR REPLACE FUNCTION sig_contains( signature, INT )
  RETURNS BOOL
  AS 'signature.so', 'sig_contains'
  LANGUAGE C STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION sig_length( signature )
	RETURNS INT
	AS 'signature.so', 'sig_length'
	LANGUAGE C STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION sig_count( signature )
	RETURNS INT
	AS 'signature.so', 'sig_count'
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

 -- aggregate functions for faceting

 CREATE AGGREGATE sig_collect( int )
 (
 	sfunc = sig_set,
 	stype = signature,
 	initcond = ''
 );

 CREATE AGGREGATE sig_collect( signature )
 (
 	sfunc = sig_or,
 	stype = signature
 );

 CREATE AGGREGATE sig_filter( signature )
 (
     sfunc = sig_and,
     stype = signature
 );