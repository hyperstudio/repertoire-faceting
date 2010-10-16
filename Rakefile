# encoding: UTF-8

require 'rake/testtask'
require 'rake/rdoctask'

require __FILE__ + '/../lib/repertoire-faceting/version'

gemspec = eval(File.read("repertoire-faceting.gemspec"))

def run_without_aborting(modes, *tasks)
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

task :build => "#{gemspec.full_name}.gem"

file "#{gemspec.full_name}.gem" => gemspec.files + ["repertoire-faceting.gemspec"] do
  system "gem build repertoire-faceting.gemspec"
  system "gem install repertoire-faceting-#{Repertoire::Faceting::VERSION}.gem"
end

desc 'Default: run tests'
task :default => :test

desc 'Run postgresql and mysql tests'
task :test do
  tasks = %w(test_postgresql test_mysql)
  run_without_aborting(*tasks)
end

%w( postgresql mysql ).each do |adapter|
  Rake::TestTask.new("test_#{adapter}") do |t|
    connection_path = "test/connections/#{adapter}"
    t.libs << "test" << connection_path
    t.test_files = Dir.glob( "test/cases/**/*_test.rb").sort
    t.verbose = true
    t.warning = true
  end
end

desc 'Generate documentation for Repertoire Faceting.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Repertoire Faceting'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('FAQ')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
