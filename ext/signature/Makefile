#-------------------------------------------------------------------------
#
# Makefile--
# Makefile for Repertoire bitset signature type
#
# By default, this builds against an existing PostgreSQL installation
# (the one identified by whichever pg_config is first in your path).
#
#-------------------------------------------------------------------------
 
MODULES = signature
EXTENSION = faceting
DATA = ./faceting--0.5.7.sql # TODO...  ../utils/utils.sql
DOCS = README.faceting

SHLIB_LINK = $(BE_DLLLIBS)
 
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)