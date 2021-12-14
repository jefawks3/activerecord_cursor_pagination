# frozen_string_literal: true

require_relative "lib/activerecord_cursor_pagination/version"

Gem::Specification.new do |spec|
  spec.name = "activerecord_cursor_pagination"
  spec.version = ActiverecordCursorPagination::VERSION
  spec.authors = ["James Fawks"]
  spec.email = ["jefawks3@gmail.com"]

  spec.summary = "Cursor pagination for ActiveRecord"
  spec.description = "ActiveRecord extension for cursor based pagination."
  spec.homepage = "https://github.com/jefawks3/activerecord_cursor_pagination"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/jefawks3/activerecord_cursor_pagination"
  spec.metadata["changelog_uri"] = "https://github.com/jefawks3/activerecord_cursor_pagination/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Gem Dependencies
  spec.add_dependency "activerecord", ">= 5.2"
  spec.add_dependency "json", ">= 2.5"

  # Development Dependencies
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-mocks", '~> 3.4'
  spec.add_development_dependency "rubocop", "~> 1.21"
  spec.add_development_dependency 'bundler', '>= 1.15'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'faker'
end
