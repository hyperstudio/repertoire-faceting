# encoding: UTF-8

require 'rake/testtask'
require 'rake/rdoctask'
require 'pathname'

require 'bundler'
Bundler.require(:default)

dir = Pathname.new(__FILE__).dirname
load dir + 'lib/repertoire-faceting/tasks/all.rake'

$:.unshift File.expand_path(dir + 'test')

gemspec = eval(File.read("repertoire-faceting.gemspec"))

def run_without_aborting(*tasks)
  errors = []

  tasks.each do |task|
    begin
      Rake::Task[task].invoke
    rescue Exception
      errors << task
    end
  end

  abort "Errors running #{errors.join(', ')}" if errors.any?
end

desc 'Build the gem'
task :build => "#{gemspec.full_name}.gem"

file "#{gemspec.full_name}.gem" => gemspec.files + ["repertoire-faceting.gemspec"] do
  system "gem build repertoire-faceting.gemspec"
  system "gem install repertoire-faceting-#{Repertoire::Faceting::VERSION}.gem"
end

desc 'Default: run tests'
task :default => :test

desc 'Run tests for supported databases (currently only Postgresql)'
task :test do
  tasks = %w(test_postgresql )
  run_without_aborting(*tasks)
end

%w( postgresql ).each do |adapter|
  Rake::TestTask.new("test_#{adapter}") do |t|
    connection_path = "test/connections/#{adapter}"
    t.libs << "test" << connection_path
    t.test_files = Dir.glob( "test/cases/**/*_test.rb").sort
    t.verbose = true
    t.warning = true
  end
end

desc 'Generate documentation'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Repertoire Faceting'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('FAQ')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

namespace :db do
  
  desc 'Build the PostgreSQL test databases'
  task :create do
    %x( createdb -E UTF8 repertoire_testing
        createlang plpgsql repertoire_testing
        psql repertoire_testing -f #{dir}/ext/signature.sql
     )
  end

  desc 'Drop the PostgreSQL test databases'
  task :drop do
    %x( dropdb repertoire_testing )
  end
  
end
