N.B.  Because repertoire faceting depends on in-database indexing modules, specs must be run against
an actual Postgres instance (not sqlite).  To create the appropriate database,

1. install the module as described in the main README
2. create and configure testing database:
     createdb -Upostgres repertoire_testing
     createlang -Upostgres plpgsql repertoire_testing
     psql -Upostgres repertoire_testing -f /opt/local/share/postgresql84/contrib/signature.sql
3. upload testing data
     psql -Upostgres repertoire_testing -f spec/nobelists.sql 
4. run the core specs

To test the GIS system as well,

1. make sure PostGIS is installed on the machine [ skip if already done ]
     sudo port install postgis
		 psql -Upostgres repertoire_testing -f /opt/local/share/postgresql84/contrib/postgis.sql
		 psql -Upostgres repertoire_testing -f /opt/local/share/postgresql84/contrib/spatial_ref_sys.sql
2. upload the extended testing data
     psql -Upostgres repertoire_testing -f spec/nobelists.sql
     psql -Upostgres repertoire_testing -f spec/nobelists_gis.sql
3. run the gis specs

To stress test your database faceting configuration,

1. upload the testing data
     psql -Upostgres repertoire_testing -f spec/citizens.sql
2. run the scalability specs
