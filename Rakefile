require 'rubygems'
require 'rake/gempackagetask'

require 'merb-core'
require 'merb-core/tasks/merb'

GEM_NAME = "repertoire_faceting"
GEM_VERSION = "0.3.4"
AUTHOR = "Christopher York"
EMAIL = "yorkc@mit.edu"
HOMEPAGE = "http://hyperstudio.mit.edu/repertoire"
SUMMARY = "Merb plugin that provides faceted indexing and browsing"

spec = Gem::Specification.new do |s|
  s.rubyforge_project = 'repertoire_faceting'
  s.name = GEM_NAME
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README", "LICENSE", "TODO"]
  s.summary = SUMMARY
  s.description = s.summary
  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE
  s.add_dependency('repertoire-assets')
  s.add_dependency('ruby-pg')
  s.add_dependency('merb-core')
  s.add_dependency('dm-core')
  s.add_dependency('jquery', '~>1.3.2')
#  s.extensions = ["ext/extconf.rb"]
  s.files = %w(LICENSE README Rakefile TODO ext/extconf.rb ext/Makefile ext/signature.c ext/signature.sql.IN ext/uninstall_signature.sql.IN) + Dir.glob("{lib,spec,public}/**/*")
  s.require_paths = %w(lib)
  s.post_install_message = <<-POST_INSTALL_MESSAGE
#{'*'*80}
    If this is the first time you have installed Repertoire faceting, you need
to build and install the native PostgreSQL extension.
  
  cd repertoire-faceting/ext
  sudo make install

  See the repertoire-faceting README for details.
#{'*'*80}
POST_INSTALL_MESSAGE
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "install the plugin as a gem"
task :install do
  Merb::RakeHelper.install(GEM_NAME, :version => GEM_VERSION)
end

desc "Uninstall the gem"
task :uninstall do
  Merb::RakeHelper.uninstall(GEM_NAME, :version => GEM_VERSION)
end

desc "Create a gemspec file"
task :gemspec do
  File.open("#{GEM_NAME}.gemspec", "w") do |file|
    file.puts spec.to_ruby
  end
end