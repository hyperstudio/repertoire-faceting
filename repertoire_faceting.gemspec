# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{repertoire_faceting}
  s.version = "0.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Christopher York"]
  s.date = %q{2009-03-24}
  s.description = %q{Merb plugin that provides faceted indexing and browsing}
  s.email = %q{yorkc@mit.edu}
  s.extensions = ["ext/extconf.rb"]
  s.extra_rdoc_files = ["README", "LICENSE", "TODO"]
  s.files = ["LICENSE", "README", "Rakefile", "TODO", "ext/extconf.rb", "ext/Makefile", "ext/signature.c", "ext/signature.sql.IN", "ext/uninstall_signature.sql.IN", "lib/repertoire_faceting", "lib/repertoire_faceting/adapters", "lib/repertoire_faceting/adapters/data_objects_adapter.rb", "lib/repertoire_faceting/collection.rb", "lib/repertoire_faceting/faceting_methods.rb", "lib/repertoire_faceting/is-faceted", "lib/repertoire_faceting/is-faceted/is", "lib/repertoire_faceting/is-faceted/is/faceted.rb", "lib/repertoire_faceting/is-faceted/is/version.rb", "lib/repertoire_faceting/is-faceted.rb", "lib/repertoire_faceting/model.rb", "lib/repertoire_faceting/types", "lib/repertoire_faceting/types/array.rb", "lib/repertoire_faceting.rb", "spec/repertoire_faceting_spec.rb", "spec/spec_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://hyperstudio.mit.edu/repertoire}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{repertoire_faceting}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Merb plugin that provides faceted indexing and browsing}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<ruby-pg>, [">= 0"])
      s.add_runtime_dependency(%q<merb-core>, [">= 0"])
      s.add_runtime_dependency(%q<dm-core>, [">= 0"])
    else
      s.add_dependency(%q<ruby-pg>, [">= 0"])
      s.add_dependency(%q<merb-core>, [">= 0"])
      s.add_dependency(%q<dm-core>, [">= 0"])
    end
  else
    s.add_dependency(%q<ruby-pg>, [">= 0"])
    s.add_dependency(%q<merb-core>, [">= 0"])
    s.add_dependency(%q<dm-core>, [">= 0"])
  end
end
