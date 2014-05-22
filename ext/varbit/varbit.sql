-- ============================================================================
-- Faceting API implementing bitmap indices using PostgreSQL's built-in VARBIT
-- type, processed using the built-in language pl/pgsql.
--
-- This API is suitable for deployment on any host, since it requires no
-- PostgreSQL extensions outside the default install.
--
-- However, performance is limited to around 30,000 items in practice (in part
-- because of unnecessary duplication of varbit values when pl/pgsql evaluates
-- the count function.)
--
-- The 'signature' C-based faceting API is preferable for any install where
-- you have superuser access to the database.
--
-- Christopher York
-- MIT Hyperstudio
-- February 2014
-- ============================================================================

CREATE FUNCTION @extschema@.sig_resize( sig VARBIT, bits INT ) RETURNS VARBIT AS $$
DECLARE
  len INT;
BEGIN
  len := length(sig);
  IF bits > len THEN
    RETURN sig || repeat('0', bits - len)::VARBIT;
  ELSIF bits < len THEN
    RETURN substring(sig FROM 1 FOR bits);
  END IF;
  RETURN sig;
END $$ LANGUAGE plpgsql STRICT IMMUTABLE;

CREATE FUNCTION @extschema@.sig_set( sig VARBIT, pos INT, val INT ) RETURNS VARBIT AS $$
DECLARE
  len INT;
BEGIN
  len := length(sig);
  IF pos >= len THEN
    IF val > 0 THEN
      RETURN set_bit(@extschema@.sig_resize(sig, pos+1), pos, 1);
    ELSE
      RETURN sig;
    END IF;
  ELSE
    RETURN set_bit(sig, pos, val);
  END IF;
END $$ LANGUAGE plpgsql STRICT IMMUTABLE;

CREATE FUNCTION @extschema@.sig_set( sig VARBIT, pos INT ) RETURNS VARBIT AS $$
BEGIN
  RETURN @extschema@.sig_set(sig, pos, 1);
END $$ LANGUAGE plpgsql STRICT IMMUTABLE;

CREATE FUNCTION @extschema@.sig_get( sig VARBIT, pos INT ) RETURNS INT AS $$
DECLARE
  len INT;
BEGIN
  len := length(sig);
  IF pos >= len THEN
    RETURN 0;
  ELSE
    RETURN get_bit(sig, pos);
  END IF;
END $$ LANGUAGE plpgsql STRICT IMMUTABLE;

CREATE FUNCTION @extschema@.sig_length( sig VARBIT ) RETURNS INT AS $$
BEGIN
  RETURN length(sig);
END $$ LANGUAGE plpgsql STRICT IMMUTABLE;

CREATE FUNCTION @extschema@.sig_min( sig VARBIT ) RETURNS INT AS $$
BEGIN
  RETURN position('1' in sig) - 1;
END $$ LANGUAGE plpgsql STRICT IMMUTABLE;

CREATE FUNCTION @extschema@.sig_and( sig1 VARBIT, sig2 VARBIT ) RETURNS VARBIT AS $$
DECLARE
  len INT;
BEGIN
  len := GREATEST(length(sig1), length(sig2));
  RETURN bitand(@extschema@.sig_resize(sig1, len), @extschema@.sig_resize(sig2, len)) ;
END $$ LANGUAGE plpgsql STRICT IMMUTABLE;

CREATE FUNCTION @extschema@.sig_or( sig1 VARBIT, sig2 VARBIT ) RETURNS VARBIT AS $$
DECLARE
  len INT;
BEGIN
  len := GREATEST(length(sig1), length(sig2));
  RETURN bitor(@extschema@.sig_resize(sig1, len), @extschema@.sig_resize(sig2, len)) ;
END $$ LANGUAGE plpgsql STRICT IMMUTABLE;

CREATE FUNCTION @extschema@.sig_xor( sig1 VARBIT, sig2 VARBIT ) RETURNS VARBIT AS $$
DECLARE
  len INT;
BEGIN
  len := GREATEST(length(sig1), length(sig2));
  RETURN bitxor(@extschema@.sig_resize(sig1, len), @extschema@.sig_resize(sig2, len)) ;
END $$ LANGUAGE plpgsql STRICT IMMUTABLE;

CREATE FUNCTION @extschema@.count( sig VARBIT ) RETURNS INT AS $$
BEGIN
  -- This is, by any measure, horrific. However, it appears to be the only 
  -- way to use PostgreSQL built in functions to count bits in a bit string.
  RETURN length(replace(sig::TEXT, '0', ''));
END $$ LANGUAGE plpgsql STRICT IMMUTABLE;

CREATE FUNCTION @extschema@.contains( sig VARBIT, pos INT ) RETURNS BOOL AS $$
BEGIN
  RETURN @extschema@.sig_get(sig, pos) = 1;
END $$ LANGUAGE plpgsql STRICT IMMUTABLE;

CREATE FUNCTION @extschema@.members( sig VARBIT ) RETURNS SETOF INT AS $$
BEGIN
  FOR i IN 0 .. length(sig) - 1 LOOP
    IF @extschema@.contains(sig, i) THEN
      RETURN NEXT i;
    END IF;
  END LOOP;
END $$ LANGUAGE plpgsql STRICT IMMUTABLE;


-- operators for faceting

CREATE OPERATOR @extschema@.& (
    leftarg = VARBIT,
    rightarg = VARBIT,
    procedure = @extschema@.sig_and,
    commutator = &
);

CREATE OPERATOR @extschema@.| (
    leftarg = VARBIT,
    rightarg = VARBIT,
    procedure = @extschema@.sig_or,
    commutator = |
);

CREATE OPERATOR @extschema@.+ (
    leftarg = VARBIT,
    rightarg = int,
    procedure = @extschema@.sig_set
);


-- aggregate functions for faceting

CREATE AGGREGATE @extschema@.collect( VARBIT )
(
	sfunc = @extschema@.sig_or,
	stype = VARBIT
);

CREATE AGGREGATE @extschema@.filter( VARBIT )
(
   sfunc = @extschema@.sig_and,
   stype = VARBIT
);

CREATE AGGREGATE @extschema@.signature( INT )
(
	sfunc = @extschema@.sig_set,
  stype = VARBIT,
  initcond = '0'
);