# script to review labels in prometheus

# Pre-requisites
# gem install terminal-table
# gem install rest-client

# Usage ruby analyze_labels.rb <prometheus_url>
# Example  ruby analyze_labels.rb http://localhost:9090


require 'json'
require 'rest-client'
require 'terminal-table'

# for debugging
# require 'pry'

@label_values = {}

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
  table = Terminal::Table.new :headings => headings, :rows => rows
  puts table
end

# analyze labels
def analyze_labels(labels)
  headings = ['Label', 'Name Length', 'Value API']
  rows = []
  labels['data'].each do |label|
    rows << [label, label.size, prometheus_query_label_value_api(label)]
  end
  puts "Total Labels: #{rows.size}"
  print_label_data(headings, rows)
  get_label_values(rows)
end

# get each label values
def get_label_values(label_rows)
    label_rows.each do |row|
        # The data section of the JSON response is a list of string label values.
        @label_values[row[0]] = get(row[2])['data']
    end
    analyze_label_values
end

def get_label_value_length(label_values)
    lengths = []
    label_values.each do |lv|
        lengths << lv.size
    end
    lengths.sort.reverse
end

# analyze label values
def analyze_label_values
    largest_in_each_label = []
    headings = ['Label', 'Label Value Lengths']
    rows = []
    @label_values.each do |label, values|
        # puts "#{label} -> #{values}"
        rows << [label, get_label_value_length(values)]
    end
    rows.each do |row|
        puts "#{row[0]} |\t#{row[1]}"
        largest_in_each_label << row[1][0]
    end
    puts "\nLargest value length from each label: #{largest_in_each_label.sort.reverse}"
end

# set labels_api
labels_api = prometheus_label_api

# get labels
labels = get(labels_api)

# analyze labels
analyze_labels(labels)
