require 'bundler/setup'
require 'json'

all = JSON.load_file 'target/schema_all.json'

all['definitions']
  .select { |id,d| d.fetch('required', []).include?('$schema') }
  .each do |id,d|
    # Shallow copy
    schema = all.clone

    # Add reference
    schema['$ref'] = "#/definitions/#{id}"

    # Write the JSON
    File.write "target/schemas/#{id}.json", JSON.pretty_generate(schema)
  end