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
DATA_built = signature.sql uninstall_signature.sql
DOCS = README.signature
 
SHLIB_LINK = $(BE_DLLLIBS)
 
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

#-- Repertoire specific targets
signature.sql:
	cp signature.sql.IN signature.sql

uninstall_signature.sql:
	cp uninstall_signature.sql.IN uninstall_signature.sql
