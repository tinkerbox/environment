require 'rvm'

rvm_ruby = ARGV[0]
app_name = ARGV[1]

puts "\n You need to specify a which rvm ruby to use." unless rvm_ruby
puts "\n You need to name your app." unless app_name

@env = RVM::Environment.new(rvm_ruby)

puts "Creating gemset #{app_name} in #{rvm_ruby}"
@env.gemset_create(app_name)

puts "Now using gemset #{app_name}"
@env.gemset_use!(app_name)

puts "Installing bundler gem."
puts "Successfully installed bundler" if @env.system("gem", "install", "bundler")
puts "Installing rails gem."
puts "Successfully installed rails" if @env.system("gem", "install", "rails")

# template_file = File.join(File.expand_path(File.dirname(__FILE__)), 'templater.rb')
system("rails new #{app_name}")