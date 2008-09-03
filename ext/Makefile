#-------------------------------------------------------------------------
#
# Makefile--
#    Makefile for bitset signature type
#
# By default, this builds against an existing PostgreSQL installation
# (the one identified by whichever pg_config is first in your path).
#
#-------------------------------------------------------------------------

MODULES = signature
DATA_built = signature.sql

SHLIB_LINK = $(BE_DLLLIBS)

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
