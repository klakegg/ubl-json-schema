require 'bundler/setup'
require 'json'

def typeify(bies)
  required = []
  properties = {}

  # Add and require schema reference for ABIE not part of common library
  if !bies[0]['ModelName'].start_with? 'UBL-CommonLibrary'
    required.push '$schema'
    properties.merge!({
      '$schema' => {
        '$ref': '#/definitions/common_schema',
      },
    })
  end

  # Add support for extensions in all ABIEs
  properties.merge!({
    'extensions' => {
      '$ref': '#/definitions/extensions',
    },
  })
  
  # Gather required properties
  required += bies[1..]
    .select { |bie| bie['Cardinality'].start_with? '1' }
    .map { |bie| bie['ComponentName'] }
  # Gather properties
  properties.merge! bies[1..]
    .map { |bie| [bie['ComponentName'], fieldify(bie)] }
    .to_h

  # Return the type definition
  {
    'type' => 'object',
    'additionalProperties' => false,
    'minProperties' => required.size > 0 ? nil : 1,
    'required' => required.size > 0 ? required : nil,
    'properties' => properties,
  }.compact
end

def fieldify(bie)
  ref = "#/definitions/#{bie['ComponentType'] == 'BBIE' ? "bbie_#{bie['RepresentationTerm'].gsub(' ', '').downcase}" : bie['RepresentationTerm'].gsub(' ', '')}"

  if !bie['Cardinality'].end_with? '1' and bie['ComponentType'] == 'ASBIE'
    {
      'description' => bie['Definition'],
      'oneOf' => [
        {
          '$ref' => ref,
        },
        {
          'type' => 'array',
          'items' => {
            '$ref' => "#{ref}",
          },
        },
      ],
    }
  else
    {
      'description' => bie['Definition'],
      '$ref' => "#{ref}#{bie['Cardinality'].end_with?('1') ? '' : '_n'}",
    }
  end
end

# Load entities definition
src = JSON.load_file 'target/entities.json'

# Put together the schema
schema = {
  '$schema' => 'http://json-schema.org/draft-07/schema',
  'definitions' => src.map { |id, bies| [id, typeify(bies)] }.to_h,
}

# Import handmade definitions
Dir['src/definitions/*.json'].sort.each do |file|
  schema['definitions'][File.basename(file, '.json')] = JSON.load_file file
end

#File.write 'target/schema_all_pretty.json', JSON.pretty_generate(schema)
File.write 'target/schema_all.json', schema.to_json