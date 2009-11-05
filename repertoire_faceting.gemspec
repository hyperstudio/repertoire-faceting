# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{repertoire_faceting}
  s.version = "0.3.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Christopher York"]
  s.date = %q{2009-11-04}
  s.description = %q{Merb plugin that provides faceted indexing and browsing}
  s.email = %q{yorkc@mit.edu}
  s.extra_rdoc_files = ["README", "LICENSE", "TODO"]
  s.files = ["LICENSE", "README", "Rakefile", "TODO", "ext/extconf.rb", "ext/Makefile", "ext/signature.c", "ext/signature.sql.IN", "ext/uninstall_signature.sql.IN", "lib/repertoire_faceting", "lib/repertoire_faceting/adapters", "lib/repertoire_faceting/adapters/postgres_adapter.rb", "lib/repertoire_faceting/faceting_functions.rb", "lib/repertoire_faceting/is-faceted", "lib/repertoire_faceting/is-faceted/is", "lib/repertoire_faceting/is-faceted/is/faceted.rb", "lib/repertoire_faceting/is-faceted/is/version.rb", "lib/repertoire_faceting/is-faceted.rb", "lib/repertoire_faceting.rb", "spec/citizens.sql", "spec/nobelists.sql", "spec/README.spec", "spec/repertoire_faceting_spec.rb", "spec/scalability_spec.rb", "spec/spec_helper.rb", "public/images", "public/images/repertoire-faceting", "public/images/repertoire-faceting/spinner_sm.gif", "public/javascripts", "public/javascripts/protovis-3.1", "public/javascripts/protovis-3.1/protovis-d3.1.js", "public/javascripts/protovis.js", "public/javascripts/rep.faceting.js", "public/javascripts/rep.protovis-facets.js", "public/stylesheets", "public/stylesheets/rep.faceting.css"]
  s.homepage = %q{http://hyperstudio.mit.edu/repertoire}
  s.post_install_message = %q{********************************************************************************
    If this is the first time you have installed Repertoire faceting, you need
to build and install the native PostgreSQL extension.
  
  cd repertoire-faceting/ext
  sudo make install

  See the repertoire-faceting README for details.
********************************************************************************
}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{repertoire_faceting}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Merb plugin that provides faceted indexing and browsing}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<repertoire-assets>, [">= 0"])
      s.add_runtime_dependency(%q<ruby-pg>, [">= 0"])
      s.add_runtime_dependency(%q<merb-core>, [">= 0"])
      s.add_runtime_dependency(%q<dm-core>, [">= 0"])
      s.add_runtime_dependency(%q<jquery>, ["~> 1.3.2"])
    else
      s.add_dependency(%q<repertoire-assets>, [">= 0"])
      s.add_dependency(%q<ruby-pg>, [">= 0"])
      s.add_dependency(%q<merb-core>, [">= 0"])
      s.add_dependency(%q<dm-core>, [">= 0"])
      s.add_dependency(%q<jquery>, ["~> 1.3.2"])
    end
  else
    s.add_dependency(%q<repertoire-assets>, [">= 0"])
    s.add_dependency(%q<ruby-pg>, [">= 0"])
    s.add_dependency(%q<merb-core>, [">= 0"])
    s.add_dependency(%q<dm-core>, [">= 0"])
    s.add_dependency(%q<jquery>, ["~> 1.3.2"])
  end
end
