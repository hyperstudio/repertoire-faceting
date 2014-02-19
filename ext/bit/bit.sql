-- functions for bitmap indices using PostgreSQL's built-in BIT type

CREATE FUNCTION sig_resize( sig VARBIT, bits INT ) RETURNS VARBIT AS $$
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

CREATE FUNCTION sig_set( sig VARBIT, pos INT, val INT) RETURNS VARBIT AS $$
DECLARE
  len INT;
BEGIN
  len := length(sig);
  IF pos >= len THEN
    IF val > 0 THEN
      RETURN set_bit(sig_resize(sig, pos+1), pos, 1);
    ELSE
      RETURN sig;
    END IF;
  ELSE
    RETURN set_bit(sig, pos, val);
  END IF;
END $$ LANGUAGE plpgsql STRICT IMMUTABLE;

CREATE FUNCTION sig_set( sig VARBIT, pos INT) RETURNS VARBIT AS $$
BEGIN
  RETURN sig_set(sig, pos, 1);
END $$ LANGUAGE plpgsql STRICT IMMUTABLE;

CREATE FUNCTION sig_get( sig VARBIT, pos INT ) RETURNS INT AS $$
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

CREATE FUNCTION sig_length( sig VARBIT ) RETURNS INT AS $$
BEGIN
  RETURN length(sig);
END $$ LANGUAGE plpgsql STRICT IMMUTABLE;

CREATE FUNCTION sig_min( sig VARBIT ) RETURNS INT AS $$
BEGIN
  RETURN position('1' in sig) - 1;
END $$ LANGUAGE plpgsql STRICT IMMUTABLE;

CREATE FUNCTION sig_and( sig1 VARBIT, sig2 VARBIT ) RETURNS VARBIT AS $$
DECLARE
  len INT;
BEGIN
  len := GREATEST(length(sig1), length(sig2));
  RETURN bitand(sig_resize(sig1, len), sig_resize(sig2, len)) ;
END $$ LANGUAGE plpgsql STRICT IMMUTABLE;

CREATE FUNCTION sig_or( sig1 VARBIT, sig2 VARBIT ) RETURNS VARBIT AS $$
DECLARE
  len INT;
BEGIN
  len := GREATEST(length(sig1), length(sig2));
  RETURN bitor(sig_resize(sig1, len), sig_resize(sig2, len)) ;
END $$ LANGUAGE plpgsql STRICT IMMUTABLE;

CREATE FUNCTION sig_xor( sig1 VARBIT, sig2 VARBIT ) RETURNS VARBIT AS $$
DECLARE
  len INT;
BEGIN
  len := GREATEST(length(sig1), length(sig2));
  RETURN bitxor(sig_resize(sig1, len), sig_resize(sig2, len)) ;
END $$ LANGUAGE plpgsql STRICT IMMUTABLE;

CREATE FUNCTION count( sig VARBIT ) RETURNS INT AS $$
BEGIN
  -- This is, by any measure, horrific. However, it's the only performant way to get PostgreSQL
  -- to count the number of set bits in a bit string.
  RETURN length(replace(sig::TEXT, '0', ''));
END $$ LANGUAGE plpgsql STRICT IMMUTABLE;

CREATE FUNCTION contains( sig VARBIT, pos INT ) RETURNS BOOL AS $$
BEGIN
  RETURN sig_get(sig, pos) = 1;
END $$ LANGUAGE plpgsql STRICT IMMUTABLE;

CREATE FUNCTION members( sig VARBIT ) RETURNS SETOF INT AS $$
BEGIN
  FOR i IN 0 .. length(sig) - 1 LOOP
    IF contains(sig, i) THEN
      RETURN NEXT i;
    END IF;
  END LOOP;
END $$ LANGUAGE plpgsql STRICT IMMUTABLE;


-- operators for faceting

CREATE OPERATOR & (
    leftarg = VARBIT,
    rightarg = VARBIT,
    procedure = sig_and,
    commutator = &
);

CREATE OPERATOR | (
    leftarg = VARBIT,
    rightarg = VARBIT,
    procedure = sig_or,
    commutator = |
);

CREATE OPERATOR + (
    leftarg = VARBIT,
    rightarg = int,
    procedure = sig_set
);


-- aggregate functions for faceting

CREATE AGGREGATE collect( VARBIT )
(
	sfunc = sig_or,
	stype = VARBIT
);

CREATE AGGREGATE filter( VARBIT )
(
   sfunc = sig_and,
   stype = VARBIT
);

CREATE AGGREGATE signature( INT )
(
	sfunc = sig_set,
  stype = VARBIT,
  initcond = '0'
);