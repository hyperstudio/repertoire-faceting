# encoding: UTF-8

#
# Rake testing tasks for Repertoire Faceting
#
# N.B. Tasks mirror those of a standard Rails 4 app.  Only used for running the test suite.
#

require 'rdoc/task'
require 'pathname'

require 'bundler'
Bundler.require(:default)

# Setup

dir = Pathname.new(__FILE__).dirname
load dir + 'lib/repertoire-faceting/tasks/all.rake'

gemspec = eval(File.read("repertoire-faceting.gemspec"))

$LOAD_PATH.unshift File.expand_path(dir + 'test')

# Tasks

desc 'Build the gem'
task :build => "#{gemspec.full_name}.gem"

file "#{gemspec.full_name}.gem" => gemspec.files + ["repertoire-faceting.gemspec"] do
  system "gem build repertoire-faceting.gemspec"
  system "gem install repertoire-faceting-#{Repertoire::Faceting::VERSION}.gem"
end

desc 'Default: run tests'
task :default => "test:psql:signature"

namespace 'test:psql' do
  [:signature, :varbit, :bytea].each do |api|

    desc "Run tests for PostgreSQL #{api} binding"
    task api do
      # find current PostgreSQL API binding name
      current_api = %x( psql repertoire_testing -c'SELECT extname FROM pg_extension' ).split.grep( /(faceting\w*)/ )[0]

      # determine the extension name
      api = "faceting_#{api}".sub(/_signature/, '')

      # switch into binding to test
      %x( psql repertoire_testing -c'DROP EXTENSION #{current_api} CASCADE' ) if current_api
      %x( psql repertoire_testing -c'CREATE EXTENSION #{api}' )

      # run the tests
      Dir.glob("test/cases/**/*_test.rb") do |file|
        file.sub!(%r{test/}, '')
        require file
      end
    end
  end
end

desc 'Generate documentation'
Rake::RDocTask.new(:doc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = 'Repertoire Faceting'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.main     = 'README'
  rdoc.rdoc_files.include %w(FAQ INSTALL LICENSE README TODO)
  rdoc.rdoc_files.include('lib/**/*.rb')
end

namespace :db do

  desc 'Build the PostgreSQL test databases'
  task :create do
    %x( createdb -E UTF8 repertoire_testing )
  end

  desc 'Drop the PostgreSQL test databases'
  task :drop do
    %x( dropdb repertoire_testing )
  end

  namespace :schema do
    desc "Create the test database schema"
    task :load do
      ENV["RAILS_ENV"] = "test"
      require 'config'
      require 'connection'
      load "schema/schema.rb"
    end
  end

  namespace :fixtures do
    desc "Load fixtures into the test database."
    task :load do
      require 'config'
      %x( psql repertoire_testing -f #{FIXTURES_ROOT}/fixtures.sql )
    end
  end

  desc "Create, load, and prepare database for test suite"
  task :setup => [ 'db:faceting:extensions:install',
                   'db:create', 'db:schema:load', 'db:fixtures:load' ]
end