N.B.  Because repertoire faceting depends on in-database indexing modules, specs must be run against
an actual Postgres instance (not sqlite).  To create the appropriate database,

1. install the module as described in the main README
2. create and configure testing database:
     createdb -Upostgres repertoire_testing
     createlang -Upostgres plpgsql repertoire_testing
     psql -Upostgres repertoire_testing -f /opt/local/share/postgresql83/contrib/signature.sql
3. upload the testing data
     psql -Upostgres repertoire_testing -f spec/nobelists.sql 
4. run the specs