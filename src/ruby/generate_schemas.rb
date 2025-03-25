require 'bundler/setup'
require 'json'

ALL = JSON.load_file 'target/schema_all.json'

def get_deps(id, deps = [])
  if ALL['definitions'][id].include? 'properties'
    ALL['definitions'][id]['properties'].each do |k,d|
      ref = nil

      if d.include? '$ref'
        ref = d['$ref'].split('/').last
      elsif d.include? 'oneOf'
        ref = d['oneOf'][0]['$ref'].split('/').last
      end

      if ref and !deps.include? ref
        deps.push ref
        get_deps ref, deps
      end

    end
  end

  deps
end

ALL['definitions']
  .select { |id,d| d.fetch('required', []).include?('$schema') }
  .each do |id,d|
    # Shallow copy
    schema = ALL.clone

    # Detect dependencies
    deps = get_deps id, [id]

    # Add reference and detected dependencies
    schema['$ref'] = "#/definitions/#{id}"
    schema['definitions'] = ALL['definitions'].select { |k,v| deps.include? k }

    # Write the JSON
    #File.write "target/schemas/#{id}_pretty.json", JSON.pretty_generate(schema)
    File.write "target/schemas/#{id}.json", JSON.generate(schema)
  end