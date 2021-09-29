# To search for patterns in a file
# Usage ruby search_files.rb <folder path> "patterns to search separated by ,"
# Example: ruby search_files.rb ~/kube_manifests "app.kubernetes.io/name,app.kubernetes.io/component,app.kubernetes.io/part-of,app.kubernetes.io/managed-by"
# Example for large number of files use tee for outputting: ruby search_files.rb ~/kube_manifests "app.kubernetes.io/name,app.kubernetes.io/component,app.kubernetes.io/part-of,app.kubernetes.io/managed-by"| tee output.txt

require 'find'
require 'terminal-table'

path=ARGV[0]
patterns=ARGV[1].split(',')

rows = []
headings = ['File', 'Pattern', 'Status']
puts "PATH #{path}"
puts "PATTERNS TO SEARCH #{patterns}"

# print details
def print_data(headings, rows)
  table = Terminal::Table.new headings: headings, rows: rows
  puts table
end

# select only files and skip directories
files = Find.find(path).select{|f| File.file?(f)}

files.each do |file|
 patterns.each do |pattern|
  match = File.foreach(file).any?{ |l| l[pattern] }
  rows << [file, pattern, match] unless match
 end
end

print_data(headings, rows)
