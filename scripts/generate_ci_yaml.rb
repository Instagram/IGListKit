require 'yaml'

data = YAML.load_file ".swiftlint.yml"
data.delete("included")
File.open(".swiftlint_CI.yml", 'w') { |f| f.write data.to_yaml.gsub('---', '') }
