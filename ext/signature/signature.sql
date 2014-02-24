-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION faceting" to load this the default faceting API.\quit

-- functions for bitmap indices using datatype written in C

CREATE TYPE @extschema@.signature;

-- basic i/o functions for signatures

CREATE FUNCTION @extschema@.sig_in(cstring)
  RETURNS signature
  AS 'signature.so', 'sig_in'
  LANGUAGE C STRICT;

CREATE FUNCTION @extschema@.sig_out(signature)
  RETURNS cstring
  AS 'signature.so', 'sig_out'
  LANGUAGE C STRICT;

-- signature postgresql type

CREATE TYPE @extschema@.signature (
	INTERNALLENGTH = VARIABLE,
	INPUT = sig_in,
	OUTPUT = sig_out,
	STORAGE = extended
);

-- functions for signatures

CREATE FUNCTION @extschema@.sig_resize( signature, INT )
  RETURNS signature
  AS 'signature.so', 'sig_resize'
  LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION @extschema@.sig_set( signature, INT, INT )
  RETURNS signature
  AS 'signature.so', 'sig_set'
  LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION @extschema@.sig_set( signature, INT )
  RETURNS signature
  AS 'signature.so', 'sig_set'
  LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION @extschema@.sig_get( signature, INT )
  RETURNS INT
  AS 'signature.so', 'sig_get'
  LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION @extschema@.sig_length( signature )
	RETURNS INT
	AS 'signature.so', 'sig_length'
	LANGUAGE C STRICT IMMUTABLE;
	
CREATE FUNCTION @extschema@.sig_min( signature )
	RETURNS INT
	AS 'signature.so', 'sig_min'
	LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION @extschema@.sig_and( signature, signature )
  RETURNS signature
  AS 'signature.so', 'sig_and'
  LANGUAGE C STRICT IMMUTABLE;	

CREATE FUNCTION @extschema@.sig_or( signature, signature )
  RETURNS signature
  AS 'signature.so', 'sig_or'
  LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION @extschema@.sig_xor( signature )
  RETURNS signature
  AS 'signature.so', 'sig_xor'
  LANGUAGE C STRICT IMMUTABLE;
 
CREATE FUNCTION @extschema@.count( signature )
	RETURNS INT
	AS 'signature.so', 'count'
	LANGUAGE C STRICT IMMUTABLE;
	
CREATE FUNCTION @extschema@.contains( signature, INT )
  RETURNS BOOL
  AS 'signature.so', 'contains'
  LANGUAGE C STRICT IMMUTABLE;	
	
CREATE FUNCTION @extschema@.members( signature )
RETURNS SETOF INT
AS 'signature.so', 'members'
LANGUAGE C STRICT IMMUTABLE;
  
CREATE FUNCTION @extschema@.sig_cmp( signature, signature )
  RETURNS INT
  AS 'signature.so', 'sig_cmp'
  LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION @extschema@.sig_lt( signature, signature )
  RETURNS BOOL
  AS 'signature.so', 'sig_lt'
  LANGUAGE C STRICT IMMUTABLE;
 
CREATE FUNCTION @extschema@.sig_lte( signature, signature )
  RETURNS BOOL
  AS 'signature.so', 'sig_lte'
  LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION @extschema@.sig_eq( signature, signature )
  RETURNS BOOL
  AS 'signature.so', 'sig_eq'
  LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION @extschema@.sig_gt( signature, signature )
  RETURNS BOOL
  AS 'signature.so', 'sig_gt'
  LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION @extschema@.sig_gte( signature, signature )
  RETURNS BOOL
  AS 'signature.so', 'sig_gte'
  LANGUAGE C STRICT IMMUTABLE;

-- operators for signatures

CREATE OPERATOR @extschema@.& (
    leftarg = signature,
    rightarg = signature,
    procedure = @extschema@.sig_and,
    commutator = &
);

CREATE OPERATOR @extschema@.| (
    leftarg = signature,
    rightarg = signature,
    procedure = @extschema@.sig_or,
    commutator = |
);

CREATE OPERATOR @extschema@.+ (
    leftarg = signature,
    rightarg = int,
    procedure = @extschema@.sig_set
);
 
CREATE OPERATOR @extschema@.< (
   leftarg = signature, rightarg = signature, procedure = sig_lt,
   commutator = > , negator = >= ,
   restrict = scalarltsel, join = scalarltjoinsel
);

CREATE OPERATOR @extschema@.<= (
   leftarg = signature, rightarg = signature, procedure = sig_lte,
   commutator = >= , negator = > ,
   restrict = scalarltsel, join = scalarltjoinsel
);

CREATE OPERATOR @extschema@.= (
   leftarg = signature, rightarg = signature, procedure = sig_eq,
   commutator = = , negator = <> ,
   restrict = eqsel, join = eqjoinsel
);

CREATE OPERATOR >= (
   leftarg = signature, rightarg = signature, procedure = sig_gte,
   commutator = <= , negator = < ,
   restrict = scalargtsel, join = scalargtjoinsel
);

CREATE OPERATOR @extschema@.> (
   leftarg = signature, rightarg = signature, procedure = sig_gt,
   commutator = < , negator = <= ,
   restrict = scalargtsel, join = scalargtjoinsel
);

-- index operator classes for signatures

CREATE OPERATOR CLASS @extschema@.signature_ops
    DEFAULT FOR TYPE signature USING btree AS
        OPERATOR        1       < ,
        OPERATOR        2       <= ,
        OPERATOR        3       = ,
        OPERATOR        4       >= ,
        OPERATOR        5       > ,
        FUNCTION        1       sig_cmp(signature, signature);

-- aggregate functions for faceting

CREATE AGGREGATE @extschema@.collect( signature )
(
	sfunc = @extschema@.sig_or,
	stype = signature
);

CREATE AGGREGATE @extschema@.filter( signature )
(
   sfunc = @extschema@.sig_and,
   stype = signature
);

CREATE AGGREGATE @extschema@.signature( INT )
(
	sfunc = @extschema@.sig_set,
	stype = signature,
  initcond = '0'
);