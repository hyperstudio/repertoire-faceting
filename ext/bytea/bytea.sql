-- ============================================================================
-- Faceting API implementing bitmap indices using PostgreSQL's built-in BYTEA
-- type, processed using plv8 typed arrays.
--
-- This API is suitable for deployment on Heroku, where plv8 is installed by
-- default. Performance is many times better than the VARBIT-based faceting
-- API, primarily because of optimisations in memory handling in the count
-- function.
--
-- See https://code.google.com/p/plv8js/wiki/PLV8
--     https://postgres.heroku.com/blog/past/2013/6/5/javascript_in_your_postgres/
--
-- Christopher York
-- MIT Hyperstudio
-- February 2014
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS plv8;

SET bytea_output TO hex;

-- these functions are in pl/pgsql, because they involve appending bytea values,
-- which is easier done with direct access to the || operator

CREATE FUNCTION @extschema@.sig_resize( sig BYTEA, bits INT ) RETURNS BYTEA AS $$
DECLARE
  len INT;
  bytes INT;
BEGIN
  bytes := ceil(bits / 8.0)::INT;
  len := length(sig);
  IF bytes > len THEN
    -- RAISE NOTICE 'Extending signature from % to % bytes', len, bytes;
    RETURN sig || ('\x' || repeat('00', bytes - len))::BYTEA;
  ELSIF bits < len THEN
    -- no provision in PostgreSQL for truncating a BYTEA
    RETURN sig;
  END IF;
  RETURN sig;
END $$ LANGUAGE plpgsql STRICT IMMUTABLE;

CREATE FUNCTION @extschema@.sig_set( sig BYTEA, pos INT, val INT) RETURNS BYTEA AS $$
BEGIN
  RETURN set_bit(sig_resize(sig, pos+1), pos, val);
END $$ LANGUAGE plpgsql STRICT IMMUTABLE;

CREATE FUNCTION @extschema@.sig_set( sig BYTEA, pos INT) RETURNS BYTEA AS $$
BEGIN
  RETURN @extschema@.sig_set(sig, pos, 1);
END $$ LANGUAGE plpgsql STRICT IMMUTABLE;

-- these functions are in javascript, because (1) pl/pgsql is close
-- to the worst language in the world; (2) plv8's typed arrays make 
-- the count function much faster

CREATE FUNCTION @extschema@.sig_get( sig BYTEA, pos INT ) RETURNS INT AS $$
  if (pos <= sig.length * 8) {
    return sig[ Math.floor(pos / 8) ] >> (pos % 8) & 1;
  } else {
    return 0;
  }
$$ LANGUAGE plv8 STRICT IMMUTABLE;

CREATE FUNCTION @extschema@.sig_length( sig BYTEA ) RETURNS INT AS $$
  return sig.length;
$$ LANGUAGE plv8 STRICT IMMUTABLE;

CREATE FUNCTION @extschema@.sig_and(sig1 BYTEA, sig2 BYTEA) RETURNS BYTEA AS $$
  if (sig2.length < sig1.length) {
    var tmp = sig1;
    sig1 = sig2;
    sig2 = tmp;
  }
  for (var i = 0; i < sig1.length; i++) {
    sig1[i] = sig1[i] & sig2[i];
  }
  return sig1;
$$ LANGUAGE plv8 STRICT IMMUTABLE;

CREATE FUNCTION @extschema@.sig_or(sig1 BYTEA, sig2 BYTEA) RETURNS BYTEA AS $$
  if (sig2.length > sig1.length) {
    var tmp = sig1;
    sig1 = sig2;
    sig2 = tmp;
  }
  for (var i = 0; i < sig2.length; i++) {
    sig1[i] = sig1[i] | sig2[i];
  }
  return sig1;
$$ LANGUAGE plv8 STRICT IMMUTABLE;

CREATE FUNCTION @extschema@.count(sig bytea) RETURNS int4 AS $$
  var count_table = [
    0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4,
    1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
    1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
    2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
    1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
    2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
    2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
    3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
    1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
    2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
    2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
    3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
    2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
    3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
    3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
    4, 5, 5, 6, 5, 6, 6, 7, 5, 6, 6, 7, 6, 7, 7, 8,
  ];
  var count = 0; 
  for (var i = 0; i < sig.length; i++) { count += count_table[ sig[i] ]; } 
  return count;
$$ LANGUAGE plv8 STRICT IMMUTABLE;

CREATE FUNCTION @extschema@.contains( sig BYTEA, pos INT ) RETURNS BOOL AS $$
  return (pos <= sig.length * 8) && (sig[ Math.floor(pos / 8) ] >> (pos % 8) & 1);
$$ LANGUAGE plv8 STRICT IMMUTABLE;

CREATE FUNCTION @extschema@.members( sig BYTEA ) RETURNS SETOF INT AS $$
  for (var i = 0; i < sig.length; i++) {
    for (var j = 0; j < 8; j++) {
      if (sig[i] >> j & 1) {
        plv8.return_next(i * 8 + j);
      }
    }
  }
$$ LANGUAGE plv8 STRICT IMMUTABLE;


-- operators for faceting

CREATE OPERATOR @extschema@.& (
    leftarg = BYTEA,
    rightarg = BYTEA,
    procedure = @extschema@.sig_and,
    commutator = &
);

CREATE OPERATOR @extschema@.| (
    leftarg = BYTEA,
    rightarg = BYTEA,
    procedure = @extschema@.sig_or,
    commutator = |
);

CREATE OPERATOR @extschema@.+ (
    leftarg = BYTEA,
    rightarg = int,
    procedure = @extschema@.sig_set
);


-- aggregate functions for faceting

CREATE AGGREGATE @extschema@.collect( BYTEA )
(
	sfunc = @extschema@.sig_or,
	stype = BYTEA
);

CREATE AGGREGATE @extschema@.filter( BYTEA )
(
   sfunc = @extschema@.sig_and,
   stype = BYTEA
);

CREATE AGGREGATE @extschema@.signature( INT )
(
	sfunc = @extschema@.sig_set,
  stype = BYTEA,
  initcond = ''
);