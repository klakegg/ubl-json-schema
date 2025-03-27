require 'bundler/setup'
require 'json'

# Load entities definition
src = JSON.load_file 'target/entities.json'

# Create definitions
src.each do |id, bies|

  puts "/**"
  puts " * #{bies[0]['Definition']} "
  puts " */"

  puts "export interface #{id} {"

  if !bies[0]['ModelName'].start_with? 'UBL-CommonLibrary'
    puts "  $schema: commonSchema"
  end

  puts "  extensions?: extensions"

  bies[1..].each do |bie|
    ref = "#{bie['ComponentType'] == 'BBIE' ? "bbie#{bie['RepresentationTerm'].gsub(' ', '')}" : bie['RepresentationTerm'].gsub(' ', '')}"

    puts "  /**"
    puts "   * #{bie['Definition']} "
    puts "   */"

    if !bie['Cardinality'].end_with? '1' and bie['ComponentType'] == 'ASBIE'
      puts "  #{bie['ComponentName']}#{bie['Cardinality'].start_with?('1') ? '': '?'}: #{ref} | #{ref}[]"
    else
      puts "  #{bie['ComponentName']}#{bie['Cardinality'].start_with?('1') ? '': '?'}: #{ref}#{bie['Cardinality'].end_with?('1') ? '' : 'N'}"
    end
  end
  
  puts "}"
  puts
end

# Import handmade definitions
Dir['src/definitions/*.ts'].sort.each do |file|
  puts File.read file
  puts
end