# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "cql-model"
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tony Spataro"]
  s.date = "2013-04-24"
  s.description = "Lightweight, performant OOP wrapper for Cassandra tables; inspired by DataMapper."
  s.email = "gemspec@tracker.xeger.net"
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = [
    ".ruby-version",
    "Gemfile",
    "Gemfile.lock",
    "README.md",
    "Rakefile",
    "VERSION",
    "cql-model.gemspec",
    "cql_model.rconf",
    "lib/cql/model.rb",
    "lib/cql/model/dsl.rb",
    "lib/cql/model/query.rb",
    "lib/cql/model/query/comparison_expression.rb",
    "lib/cql/model/query/expression.rb",
    "lib/cql/model/query/insert_statement.rb",
    "lib/cql/model/query/mutation_statement.rb",
    "lib/cql/model/query/select_statement.rb",
    "lib/cql/model/query/statement.rb",
    "lib/cql/model/query/update_expression.rb",
    "lib/cql/model/query/update_statement.rb"
  ]
  s.homepage = "https://github.com/xeger/cql-model"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.0")
  s.rubygems_version = "1.8.23"
  s.summary = "Cassandra CQL model."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<cql-rb>, ["~> 1.0.0.pre4"])
      s.add_development_dependency(%q<rake>, ["~> 0.9"])
      s.add_development_dependency(%q<rspec>, ["~> 2.0"])
      s.add_development_dependency(%q<cucumber>, ["~> 1.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.8.3"])
      s.add_development_dependency(%q<debugger>, [">= 0"])
      s.add_development_dependency(%q<rdoc>, [">= 2.4.2"])
      s.add_development_dependency(%q<flexmock>, ["~> 0.8"])
      s.add_development_dependency(%q<syntax>, ["~> 1.0.0"])
      s.add_development_dependency(%q<nokogiri>, ["~> 1.5"])
    else
      s.add_dependency(%q<cql-rb>, ["~> 1.0.0.pre4"])
      s.add_dependency(%q<rake>, ["~> 0.9"])
      s.add_dependency(%q<rspec>, ["~> 2.0"])
      s.add_dependency(%q<cucumber>, ["~> 1.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.8.3"])
      s.add_dependency(%q<debugger>, [">= 0"])
      s.add_dependency(%q<rdoc>, [">= 2.4.2"])
      s.add_dependency(%q<flexmock>, ["~> 0.8"])
      s.add_dependency(%q<syntax>, ["~> 1.0.0"])
      s.add_dependency(%q<nokogiri>, ["~> 1.5"])
    end
  else
    s.add_dependency(%q<cql-rb>, ["~> 1.0.0.pre4"])
    s.add_dependency(%q<rake>, ["~> 0.9"])
    s.add_dependency(%q<rspec>, ["~> 2.0"])
    s.add_dependency(%q<cucumber>, ["~> 1.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.8.3"])
    s.add_dependency(%q<debugger>, [">= 0"])
    s.add_dependency(%q<rdoc>, [">= 2.4.2"])
    s.add_dependency(%q<flexmock>, ["~> 0.8"])
    s.add_dependency(%q<syntax>, ["~> 1.0.0"])
    s.add_dependency(%q<nokogiri>, ["~> 1.5"])
  end
end

