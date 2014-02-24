-- source this file to removethe BIT-based facet APIs

-- N.B. only use this file if you loaded the faceting API by directly sourcing
-- bit.sql and utils.sql.

DROP OPERATOR & (VARBIT, VARBIT);

DROP OPERATOR | (VARBIT, VARBIT);

DROP OPERATOR + (VARBIT, INT);

DROP FUNCTION count( sig VARBIT );

DROP FUNCTION contains( sig VARBIT, pos INT );

DROP FUNCTION members( sig VARBIT );

DROP AGGREGATE signature( INT );

DROP AGGREGATE collect( VARBIT );

DROP AGGREGATE filter( VARBIT );

DROP FUNCTION sig_resize( sig VARBIT, bits INT );

DROP FUNCTION sig_set( sig VARBIT, pos INT, val INT);

DROP FUNCTION sig_set( sig VARBIT, pos INT);

DROP FUNCTION sig_get( sig VARBIT, pos INT );

DROP FUNCTION sig_length( sig VARBIT );

DROP FUNCTION sig_min( sig VARBIT );

DROP FUNCTION sig_and( sig1 VARBIT, sig2 VARBIT );

DROP FUNCTION sig_or( sig1 VARBIT, sig2 VARBIT );

DROP FUNCTION sig_xor( sig1 VARBIT, sig2 VARBIT );
