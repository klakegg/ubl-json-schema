require 'json'
require 'nokogiri'

# Load the XML
xml = Nokogiri::XML File.open 'target/entities.gc'

# Simplify a row
def simplify(row)
  # Create a simple hash
  row.xpath('Value')
    .map { |value| [value['ColumnRef'], value.xpath('SimpleValue').text] }
    .to_h
end

# Loop through all ABIEs
models = xml.xpath('//Row[Value[@ColumnRef="ComponentType"]/SimpleValue = "ABIE"]').map { |abie|
  # Simplify the ABIE
  parent = simplify abie
  
  # Loop through all BIEs of the ABIE
  [parent['ComponentName'], 
    xml.xpath("//Row[Value[@ColumnRef='ObjectClass']/SimpleValue = '#{parent['ObjectClass']}']")
    # Simplify the BIE
    .map { |row| simplify row }
  ]
}.to_h

# Write the JSON
File.write 'target/entities.json', JSON.pretty_generate(models)