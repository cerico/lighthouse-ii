# frozen_string_literal: true

require 'json'
require 'pg'
require 'sequel'
require 'pry'

# Given a list of files on the command line,
# Insert parts of the file into the lighthouse db
#
# Usage: ruby lighthouse_json_to_db.rb [-n] <files...>
#
# -n    Perform dry run (do not insert into databse)
# files Paths of JSON files
def run
  dry_run = false
  ARGV.each do |json_file_path|
    if json_file_path == '-n'
      dry_run = true
      next
    end

    LighthouseJsonToDb.new(file_path: json_file_path, dry_run: dry_run).run
  end
end

# Given a Lighhouse JSON file:
# 1. Find specific values in the file
# 2. Insert those values into the lighthouse postgres database
class LighthouseJsonToDb
  attr_accessor :file_path, :data, :dry_run

  def initialize(file_path:, dry_run: false)
    self.file_path = file_path
    self.data = JSON.parse(File.read(file_path))
    self.dry_run = dry_run
  end

  # Run the import
  def run
    print('DRY RUN: ') if dry_run
    puts("Inserting into lighthouse table: #{extract_data.to_json}")
    db.from(:scores).insert(extract_data)
  end

  # Extract data from the JSON structure
  def extract_data
    {
      date: dig!('fetchTime'),
      url: dig!('requestedUrl'),
      accessibility: (dig!('categories', 'accessibility', 'score').to_f * 100).to_i,
      performance: (dig!('categories', 'performance', 'score').to_f * 100).to_i,
      seo: (dig!('categories', 'seo', 'score').to_f * 100).to_i,
      best_practices: (dig!('categories', 'best-practices', 'score').to_f * 100).to_i,
    }
  end

  # Dig through the JSON data:
  #
  #     dig!('this', 'that')
  #
  # Is equivalent to:
  #
  #     data.fetch('this').fetch('that')
  #
  # But will produce more helpful error messages if data is missing.
  def dig!(*path)
    value = data.clone
    trying = []
    path.each do |key|
      trying.push(key)
      value = value.fetch(key)
    end

    value
  rescue KeyError => e
    raise(KeyError, "Can't find: \"#{trying.join('/')}\" in JSON #{file_path}.")
  end

  # Database connection
  def db
    @db ||= Sequel.connect(ENV.fetch('SCORES_DB_URL'))
  end
end

# Run the script
run
