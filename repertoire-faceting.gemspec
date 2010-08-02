Gem::Specification.new do |s|
  s.name = %q{repertoire-faceting}
  s.version = "0.3.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Christopher York"]
  s.date = %q{2009-12-08}
  s.description = %q{Merb/Postgresql plugin that provides faceted indexing and browsing}
  s.email = %q{yorkc@mit.edu}
  s.extra_rdoc_files = [
    "LICENSE",
     "README",
     "TODO"
  ]
  s.files = [
    ".gitignore",
     "FAQ",
     "LICENSE",
     "README",
     "Rakefile",
     "SNIPPETS",
     "TODO",
     "VERSION",
     "ext/Makefile",
     "ext/README.signature",
     "ext/extconf.rb",
     "ext/signature.c",
     "ext/signature.sql.IN",
     "ext/uninstall_signature.sql.IN",
     "lib/repertoire_faceting.rb",
     "lib/repertoire_faceting/adapters/postgres_adapter.rb",
     "lib/repertoire_faceting/faceting_functions.rb",
     "lib/repertoire_faceting/is-faceted.rb",
     "lib/repertoire_faceting/is-faceted/is/faceted.rb",
     "lib/repertoire_faceting/is-faceted/is/version.rb",
     "public/images/repertoire-faceting/spinner_sm.gif",
     "public/javascripts/protovis.js",
     "public/javascripts/rep.faceting.js",
     "public/javascripts/rep.faceting/context.js",
     "public/javascripts/rep.faceting/facet.js",
     "public/javascripts/rep.faceting/facet_widget.js",
     "public/javascripts/rep.faceting/nested_facet.js",
     "public/javascripts/rep.faceting/results.js",
     "public/javascripts/rep.protovis-facets.js",
     "public/stylesheets/rep.faceting.css",
     "repertoire_faceting.gemspec",
     "spec/README.spec",
     "spec/citizens.sql",
     "spec/nobelists.sql",
     "spec/repertoire_faceting_spec.rb",
     "spec/scalability_spec.rb",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/repertoire/repertoire-faceting}
  s.post_install_message = %q{    ********************************************************************************
        If this is the first time you have installed Repertoire faceting, you need
    to build and install the native PostgreSQL extension.

      cd repertoire-faceting/ext
      sudo make install

      See the repertoire-faceting README for details.
    ********************************************************************************
}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Merb/Postgresql plugin that provides faceted indexing and browsing}
  s.test_files = [
    "spec/repertoire_faceting_spec.rb",
     "spec/scalability_spec.rb",
     "spec/spec_helper.rb"
  ]
  
  s.add_dependency('repertoire-assets', '>= 0.2.0')
  s.add_dependency('rep.jquery', '>=1.3.2')
  s.add_dependency('rep.ajax.toolkit', '>=0.3.0')
end

