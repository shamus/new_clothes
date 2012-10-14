require 'new_clothes'

$LOAD_PATH << File.join(File.dirname(__FILE__), 'support', "models")
Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].each do |f|
  require f
end
