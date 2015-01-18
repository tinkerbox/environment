#WARNING: this is a work in progress, do not use

# initial commit

git :init
git add: "."
git commit: %Q{ -m 'initial commit' }

# add standard configuration

environment "config.time_zone = 'Singapore'"
environment "config.active_record.default_timezone = :local"

environment <<-CODE
  config.generators do |g|
    g.test_framework :rspec,
      fixtures: true,
      view_specs: false,
      helper_specs: false,
      routing_specs: true,
      controller_specs: true,
      request_specs: false
    
    g.fixture_replacement :factory_girl, dir: "spec/factories"

    g.helper false
    g.stylesheets false
    g.javascripts false
  end
CODE

run "cp config/database.yml config/database.yml.sample"
#TODO: remove database.yml from repo

git add: "."
git commit: %Q{ -m 'add standard configuration' }

# add standard gems

gem 'slim-rails'

gem_group :development, :test do

  gem 'factory_girl_rails', '~> 4.0'
  gem 'rspec-rails', '~> 3.0.0'
  gem 'dotenv-rails'
  
end

file '.env', <<-CODE
CODE

file '.env.sample', <<-CODE
CODE

copy_file "https://raw.githubusercontent.com/tinkerbox/environment/master/src/factories_spec.rb", "spec/models/factories_spec.rb"

run "echo '#{@app_name}' >> .ruby-gemset"
run "echo '#{RUBY_VERSION}' >> .ruby-version"

run "bundle install"

generate "rspec:install"

run "echo '.env' >> .gitignore"
run "echo --format documentation >> .rspec"

git add: "."
git commit: %Q{ -m 'add standard gems' }

# add app signal

if yes? "Add appsignal?"

  gem 'appsignal'

  run "bundle install"

  api_key = ask("Enter appsignal API key:")
  generate :appsignal, api_key

  git add: "."
  git commit: %Q{ -m 'install and configure appsignal' }

end

# add new relic

if yes? "Add New Relic?"

  gem 'newrelic_rpm'

  run "bundle install"

  api_key = ask("Enter New Relic API key:")

  copy_file "https://raw.githubusercontent.com/tinkerbox/environment/master/src/newrelic.yml", "config/newrelic.yml"

  run "echo NEW_RELIC_LICENSE_KEY=#{api_key} >> .env"
  run "echo NEW_RELIC_LICENSE_KEY=#{api_key} >> .env.sample"

  git add: "."
  git commit: %Q{ -m 'install and configure new relic' }

end

# configure for Heroku deployment

if yes? "Will this app be deployed to Heroku?"

  gem 'unicorn'

  gem_group :production do

    gem 'heroku-deflater'
    gem 'rails_12factor'
    
  end

  run "echo '$stdout.sync = true' >> config.ru"
  run "echo 'web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb' >> Procfile"

  run "echo PORT=3000 >> .env"
  run "echo PORT=3000 >> .env.sample"

  run "bundle install"

  git add: "."
  git commit: %Q{ -m 'configure for heroku deployment' }

  copy_file "https://raw.githubusercontent.com/tinkerbox/environment/master/src/unicorn.rb", "config/unicorn.rb"


  #TODO: ask for existing heroku apps, or create them

end

# configure development & test environments

gem_group :development do

  gem 'better_errors'
  gem 'binding_of_caller'

  gem 'guard'
  gem 'guard-rspec', require: false

  gem 'pry-rails'
  gem 'pry-remote'

  gem 'quiet_assets'

  gem 'rb-fchange', require: false
  gem 'rb-fsevent', require: false
  gem 'rb-inotify', require: false
  gem 'rb-readline', require: false

end

gem_group :test do

  gem 'capybara'
  
  
  gem 'database_cleaner' # more config required
  gem 'selenium-webdriver' # more config required
  gem 'shoulda-matchers', require: false
  
  gem 'terminal-notifier-guard' # for OSX
  
end

run "bundle install"

run "bundle exec guard init"
run "guard init rspec"

run "rm spec/spec_helper.rb"

run "echo 'require \"capybara/rails\"' | cat - spec/rails_helper.rb > temp && mv temp spec/rails_helper.rb"
run "echo 'require \"shoulda/matchers\"' | cat - spec/rails_helper.rb > temp && mv temp spec/rails_helper.rb"

gsub_file "spec/rails_helper.rb", "# Remove this line if you're not using ActiveRecord or ActiveRecord fixtures", <<-CODE
  RSpec.configure do |config|
    config.include FactoryGirl::Syntax::Methods
  end
CODE

gsub_file 'spec/rails_helper.rb', 'config.fixture_path = "#{::Rails.root}/spec/fixtures"', ''

git add: "."
git commit: %Q{ -m 'configure development and test environments' }

if yes? "Configure for code climate?"

  gem_group :test do
    gem "codeclimate-test-reporter", require: nil
  end

  run "echo 'CodeClimate::TestReporter.start' | cat - spec/rails_helper.rb > temp && mv temp spec/rails_helper.rb"
  run "echo 'require \"codeclimate-test-reporter\"' | cat - spec/rails_helper.rb > temp && mv temp spec/rails_helper.rb"

  run "bundle install"

  git add: "."
  git commit: %Q{ -m 'configure code coverage scores to be sent to CodeClimate' }

end

if yes? "Generate binstubs?"

  run "bundle install --binstubs"

  git add: "."
  git commit: %Q{ -m 'generate binstubs' }

end


# run "echo '#{@app_name}' >> .ruby-gemset"

# push to GitHub

# if yes? "Initialize GitHub repository?"
  
#   git_uri = `git config remote.origin.url`.strip
  
#   unless git_uri.size == 0
  
#     say "Repository already exists:"
#     say "#{git_uri}"
    
#   else
    
#     #TODO: change this for organization repository
#     username = ask "What is your GitHub username?"
#     run "curl -u #{username} -d '{\"name\":\"#{app_name}\"}' https://api.github.com/user/repos"
#     git remote: %Q{ add origin git@github.com:#{username}/#{app_name}.git }
#     git push: %Q{ origin master }
    
#   end
  
# end
