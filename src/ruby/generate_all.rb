require 'bundler/setup'
require 'json'

src = JSON.load_file 'target/entities.json'

def typeify(bies)
  {
    'type' => 'object',
    'additionalProperties' => false,
    'minProperties': 1,
    'required' => 
      bies[0]['ModelName'].start_with?('UBL-CommonLibrary') ? [] : ["$schema"] + 
      bies[1..]
        .select { |bie| bie['Cardinality'].start_with? '1' }
        .map { |bie| bie['ComponentName'] },
    'properties' => 
      (bies[0]['ModelName'].start_with?('UBL-CommonLibrary') ? {} : {"$schema" => {"$ref" => "#/definitions/common_schema"}}).merge(
        bies[1..]
        .map { |bie| [bie['ComponentName'], fieldify(bie)] }
        .to_h,
      )
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

schema = {
  '$schema' => 'http://json-schema.org/draft-07/schema',
  'definitions' => src.map { |id, bies| [id, typeify(bies)] }.to_h,
}

Dir['src/definitions/*.json'].sort.each do |file|
  schema['definitions'][File.basename(file, '.json')] = JSON.load_file file
end

#File.write 'target/schema_all_pretty.json', JSON.pretty_generate(schema)
File.write 'target/schema_all.json', schema.to_json