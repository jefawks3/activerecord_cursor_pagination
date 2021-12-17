# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path "../lib", __dir__

require "activerecord_cursor_pagination"

ActiveRecord::Base.logger = Logger.new($stdout)

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ":memory:"
)

ActiveRecord::Migration.verbose = true

ActiveRecord::Schema.define do
  require_relative "db/schema"
end

require "database_cleaner"
require "faker"

ActiverecordCursorPagination.setup do |config|
  config.secret_key = "ea48a1aedf8995f24bdf4cee540eb28926cde42244b792b614e800029fe938461687380131b192b2a27a585b51b98" \
    "777d845ae9cf2a7ae478c3e3e3699ac5dd7"
end

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end

class Post < ApplicationRecord; end
class AdminPost < Post; end

RSpec.configure do |config|
  config.before :suite do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation
  end

  config.before do
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
