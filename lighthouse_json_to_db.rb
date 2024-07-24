☁  kawajevo:lighthouse ➜ (main) ✗ cat lighthouse_json_to_db.rb
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
    db.from(:lighthouse).insert(extract_data)
  end

  # Extract data from the JSON structure
  def extract_data
    resource_summaries = dig!('audits', 'resource-summary', 'details', 'items')
    third_party_summary = resource_summaries.find { |h| h.fetch('resourceType') == 'third-party' }
    total_summary = resource_summaries.find { |h| h.fetch('resourceType') == 'total' }

    {
      date: dig!('fetchTime'),
      url: dig!('requestedUrl'),
      time_to_interactive: dig!('audits', 'interactive', 'numericValue').to_i,
      request_count: total_summary.fetch('requestCount'),
      total_size: dig!('audits', 'total-byte-weight', 'numericValue').to_i,
      third_party_request_count: third_party_summary.fetch('requestCount'),
      third_party_total_size: third_party_summary.fetch('transferSize'),
      speed_index: dig!('audits', 'speed-index', 'numericValue').to_i,
      first_contentful_paint: dig!('audits', 'first-contentful-paint', 'numericValue')&.to_i
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
    @db ||= Sequel.connect(ENV.fetch('LIGHTHOUSE_DB_URL'))
  end
end

# Run the script
run

☁  kawajevo:lighth
