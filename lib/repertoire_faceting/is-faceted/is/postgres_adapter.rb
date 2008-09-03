module DataMapper
  module Is
    module Faceted
        module PostgresAdapter
          module SQL
            
            def create_facet_statements(repository_name, model)
              stmts                 = []
              table_name            = model.storage_name(repository_name)
              facets                = model.facets
             
              facets.each do |property_name|
                stmts << create_facet_index_fn(table_name, property_name)
                stmts << create_facet_trigger(table_name, property_name)
              end
              
              stmts
            end
            
            def create_facet_index_fn(table_name, property_name)
              <<-EOS.compress_lines
              CREATE OR REPLACE FUNCTION faceting.#{table_name}_#{property_name}_reindex_fn() RETURNS trigger AS $$
                BEGIN
                  DROP TABLE faceting.#{table_name}_#{property_name}_index;
                  CREATE TABLE faceting.#{table_name}_#{property_name}_index AS SELECT #{property_name}, sig_collect(id) FROM #{table_name} GROUP BY #{property_name};
                END;
              $$ LANGUAGE 'plpgsql';
              EOS
            end
            
            def create_facet_trigger(table_name, property_name)
              <<-EOS.compress_lines
              CREATE TRIGGER faceting.#{table_name}_#{property_name}_reindex
                AFTER INSERT OR UPDATE OR DELETE ON #{table_name} FOR EACH STATEMENT
                EXECUTE PROCEDURE faceting.#{table_name}_#{property_name}_reindex_fn();
              EOS
            end
            
            def destroy_facet_index_statements(repository_name, model)
              stmts                 = []
              table_name            = model.storage_name(repository_name)
              facets                = model.facets
             
              facets.each do |property_name|
                stmts << "DROP TRIGGER faceting.#{table_name}_#{property_name}_reindex ON #{table_name}"
                stmts << "DROP FUNCTION faceting.#{table_name}_#{property_name}_reindex_fn()"
              end

              stmts
            end
          end

          module Migration
            def self.included(migrator)
              migrator.extend(ClassMethods)
              migrator.before_class_method :auto_migrate_down, :auto_migrate_facet_indices_down
              migrator.after_class_method  :auto_migrate_up,   :auto_migrate_facet_indices_up
            end

            module ClassMethods
              def auto_migrate_facet_indices_down(repository_name, *descendants)
                descendants = DataMapper::Resource.descendants.to_a if descendants.empty?
                descendants.each do |model|
                  if model.storage_exists?(repository_name)
                    adapter = model.repository(repository_name).adapter
                    statements = adapter.destroy_facet_index_statements(repository_name, model)
                    statements.each {|stmt| adapter.execute(stmt) }
                  end
                end
              end

              def auto_migrate_facet_indices_up(retval, repository_name, *descendants)
                descendants = DataMapper::Resource.descendants.to_a if descendants.empty?
                descendants.each do |model|
                  adapter = model.repository(repository_name).adapter
                  statements = adapter.create_facet_statements(repository_name, model)
                  statements.each {|stmt| adapter.execute(stmt) }
                end
              end
            end
          end
        end
      end
    end
  end