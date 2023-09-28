require 'json'
require 'fileutils'

FileUtils.mkdir_p 'target'

JSON.load_file('data/versions.json').each do |ver|

  data = JSON.load_file "data/#{ver['version']}-#{ver['variant']}.library.json"
  result = JSON.load_file 'template/schema.json'

  #elements = Array::new

  data['components'].each do |component|
    definition = {
      'type' => 'object',
      'additionalProperties' => false,
      'required' => Array::new,
      'properties' => Hash::new,
    }

    component['children'].each do |child|
      prefix = child['kind'] == 'bbie' ? 'base' : ''

      if child['card'].end_with? '1'
        definition['properties'][child['element']] = {
          "$ref" => "#/definitions/#{prefix}#{child['comp'].gsub(' ', '')}"
        }
      else
        definition['properties'][child['element']] = {
          'oneOf' => [
            {
              "$ref" => "#/definitions/#{prefix}#{child['comp'].gsub(' ', '')}"
            },
            {
              "type" => 'array',
              "items" => {
                "$ref" => "#/definitions/#{prefix}#{child['comp'].gsub(' ', '')}"
              }
            }
          ]
          
        }
      end

      definition['required'].append(child['element']) if child['card'].start_with? '1'
    end

    # Append
    #elements.append component['element']
    result['definitions'][component['element']] = definition
    result['properties'][component['element']] = {
      '$ref' => "#/definitions/#{component['element']}",
    }
  end

  #puts elements

  File.write "target/#{ver['version']}-#{ver['variant']}.schema.pretty.json", JSON.pretty_generate(result)
  File.write "target/#{ver['version']}-#{ver['variant']}.schema.json", JSON.generate(result)
end