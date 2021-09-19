# script to review labels in prometheus

# Pre-requisites
# gem install concurrent-ruby
# gem install terminal-table
# gem install rest-client

# Usage ruby analyze_labels.rb <prometheus_url>, default is http://localhost:9090
# Example  ruby analyze_labels.rb http://localhost:9090
# Example pipe output to file ruby analyze_labels.rb | tee output_analyze_labels

require 'json'
require 'logger'
require 'rest-client'
require 'terminal-table'

# uncomment for debugging and add binding.pry for breakpoints
# require 'pry'

@label_values = {}
@analysis = []

def logger
  Logger.new($stdout)
end

def get(api)
  response = RestClient.get(api)
  JSON.parse(response)
end

# https://prometheus.io/docs/prometheus/latest/querying/api/#getting-label-names
# GET /api/v1/labels
def prometheus_label_api
  prom_url = ARGV[0].strip if ARGV[0]
  prom_url = 'http://localhost:9090' unless ARGV[0]
  prom_url.concat('/', '/api/v1/labels')
end

# https://prometheus.io/docs/prometheus/latest/querying/api/#querying-label-values
# GET /api/v1/label/<label_name>/values
def prometheus_query_label_value_api(label)
  prom_url = ARGV[0].strip if ARGV[0]
  prom_url = 'http://localhost:9090' unless ARGV[0]
  prom_url.concat('/', "/api/v1/label/#{label}/values")
end

# print details
def print_label_data(headings, rows)
  table = Terminal::Table.new headings: headings, rows: rows
  puts table
end

# analyze labels
def analyze_labels(labels)
  headings = ['Label', 'Name Length', 'Value API']
  rows = []
  name_lengths = []
  labels['data'].each do |label|
    rows << [label, label.size, prometheus_query_label_value_api(label)]
  end
  rows.select { |row| name_lengths << row[1] }

  @analysis << "Total Labels: #{rows.size}"
  @analysis << "Largest Label Name Length: #{name_lengths.sort.reverse[0]}"

  print_label_data(headings, rows)
  get_label_values(rows)
end

# get each label values
def get_label_values(label_rows)
  logger.info 'Getting Label Values, it will take sometime depending on number of labels'
  label_rows.each do |row|
    # The data section of the JSON response is a list of string label values.
    @label_values[row[0]] = get(row[2])['data']
  end
  analyze_label_values
end

# get length of each label value
def get_label_value_length(label_values)
  lengths = []
  label_values.each do |lv|
    lengths << lv.size
  end
  lengths
end

# analyze label values
def analyze_label_values
  largest_in_each_label = []
  rows = []
  puts '----------------------------------------------------------'
  logger.debug "\nLabel and corresponding values"
  puts '----------------------------------------------------------'
  @label_values.each do |label, values|
    logger.debug "| #{label} \t|  #{values} |"
    rows << [label, get_label_value_length(values)]
  end

  puts '----------------------------------------------------------'
  logger.debug 'Labels and corresponding value lengths'
  puts '----------------------------------------------------------'
  rows.each do |row|
    logger.debug "| #{row[0]} |\t#{row[1]} |"
    largest_in_each_label << row[1].sort.reverse[0]
  end
  @analysis << "Largest value length from label values: #{largest_in_each_label.sort.reverse[0]}"
end

# set labels_api
labels_api = prometheus_label_api

# get labels
logger.info 'Getting all labels'
labels = get(labels_api)

# analyze labels
logger.info 'Analyzing labels'
analyze_labels(labels)

# print analyzed data
puts "\nAnalysis:"
@analysis.each do |a|
    puts a
end
