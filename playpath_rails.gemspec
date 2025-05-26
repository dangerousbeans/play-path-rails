# frozen_string_literal: true

require_relative "lib/playpath_rails/version"

Gem::Specification.new do |spec|
  spec.name = "playpath_rails"
  spec.version = PlaypathRails::VERSION
  spec.authors = ["Joran Kikke"]
  spec.email = ["joran.k@gmail.com"]

  spec.summary     = "Sync ActiveRecord models with the Items API at playpath.io"
  spec.description = <<~DESC.chomp
    Provides integration between ActiveRecord and the Items API at playpath.io,
    enabling automatic synchronization of records between your Rails application
    and Playpath's Items service.
  DESC
  spec.homepage    = "https://playpath.io"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/playpath/playpath_rails"
  spec.metadata["changelog_uri"] = "https://github.com/playpath/playpath_rails/blob/main/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "https://github.com/playpath/playpath_rails/issues"
  spec.metadata["documentation_uri"] = "https://rubydoc.info/gems/playpath_rails"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "activerecord", ">= 5.2", "< 8.0"
  spec.add_dependency "activesupport", ">= 5.2", "< 8.0"

  # Development dependencies
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-rails", "~> 6.0"
  spec.add_development_dependency "rubocop", "~> 1.0"
  spec.add_development_dependency "rubocop-rails", "~> 2.0"
  spec.add_development_dependency "rubocop-rspec", "~> 2.0"
  spec.add_development_dependency "webmock", "~> 3.0"
  spec.add_development_dependency "simplecov", "~> 0.22"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
