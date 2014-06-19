#-------------------------------------------------------------------------
#
# Makefile--
# Makefile for Repertoire faceting API
#
# By default, this builds against an existing PostgreSQL installation
# (the one identified by whichever pg_config is first in your path).
#
#-------------------------------------------------------------------------

API_VERSION = 0.7.3

MODULES = signature/signature
EXTENSION = signature/faceting \
            bytea/faceting_bytea \
            varbit/faceting_varbit
DATA_built = faceting--$(API_VERSION).sql \
             faceting_bytea--$(API_VERSION).sql \
             faceting_varbit--$(API_VERSION).sql
DOCS = README.faceting

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)

-include $(PGXS)
# the dash above means loading pgxs may fail silently on Heroku, but
# the API bindings will still be built:
api_bindings : $(DATA_built)

faceting--$(API_VERSION).sql: signature/signature.sql common/util.sql
	cat signature/signature.sql common/util.sql > $@

faceting_bytea--$(API_VERSION).sql: bytea/bytea.sql common/util.sql
	cat bytea/bytea.sql common/util.sql > $@

faceting_varbit--$(API_VERSION).sql: varbit/varbit.sql common/util.sql
	cat varbit/varbit.sql common/util.sql > $@
