require 'new_clothes'

$LOAD_PATH << File.join(File.dirname(__FILE__), 'support', "models")
Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].each do |f|
  next if f =~ %r|/spec/support/models|
  require f
end
