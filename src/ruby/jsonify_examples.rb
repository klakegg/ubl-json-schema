require 'bundler/setup'
require 'json'
require 'yaml'

Dir['src/example/*.yaml'].each do |file|
  src = YAML.load_file file

  File.write "target/example/#{File.basename(file, '.yaml')}.json", JSON.pretty_generate(src)
end