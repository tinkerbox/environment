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
    g.helper false
    g.stylesheets false
    g.javascripts false
  end
CODE

# Copy a sample from database.yml
run "cp config/database.yml config/database.yml.sample"
# Remove database.yml from repo
run "rm config/database.yml"

# Add standard configuration
git add: "."
git commit: %Q{ -m 'add standard configuration' }

# Add standard gems

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

run "rvm gemset create #{@app_name}"
run "rvm use #{@app_name}"


run "echo '#{@app_name}' >> .ruby-gemset"
run "echo '#{RUBY_VERSION}' >> .ruby-version"

# Bundle install above gems.
run "bundle install"

# Initialize the spec/directory
generate "rspec:install"


# Add the .env into the gitignore file
run "echo '.env' >> .gitignore"

#
run "echo --format documentation >> .rspec"

# Commit the changes into git
git add: "."
git commit: %Q{ -m 'add standard gems' }


# Add app signal

if yes? "Add appsignal?"

  gem 'appsignal'

  run "bundle install"

  api_key = ask("Enter appsignal API key:")
  generate :appsignal, api_key

  git add: "."
  git commit: %Q{ -m 'install and configure appsignal' }

end

# Configure for Heroku deployment

if yes? "Will this app be deployed to Heroku?"

  gem 'pg'

  gem_group :production do

    gem 'heroku-deflater'
    gem 'rails_12factor'
    
  end

  run "echo '$stdout.sync = true' >> config.ru"
  run "echo 'web: bundle exec rails server -p $PORT' >> Procfile"

  run "echo PORT=3000 >> .env"
  run "echo PORT=3000 >> .env.sample"

  run "bundle install"

  git add: "."
  git commit: %Q{ -m 'configure for heroku deployment' }

  #TODO: ask for existing heroku apps, or create them
  #might need changes

  if yes? "Do you have an existing heroku app?"
    herokuappname = ask ("What is the app name?")
    run "heroku git:remote -a '#{@herokuappname}"

  else
    #create a new heroku app with the app name
    run "heroku apps:create '#{@app_name}'"

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

run "bundle exec spring binstub --all"

run "echo 'require \"capybara/rails\"' | cat - spec/spec_helper.rb > temp && mv temp spec/spec_helper.rb"
run "echo 'require \"rspec/rails\"' | cat - spec/spec_helper.rb > temp && mv temp spec/spec_helper.rb"
run "echo 'require \"shoulda/matchers\"' | cat - spec/spec_helper.rb > temp && mv temp spec/spec_helper.rb"

git add: "."
git commit: %Q{ -m 'configure development and test environments' }

if yes? "Configure for code climate?"

  gem_group :test do
    gem "codeclimate-test-reporter", require: nil
  end

  run "echo 'CodeClimate::TestReporter.start' | cat - spec/spec_helper.rb > temp && mv temp spec/spec_helper.rb"
  run "echo 'require \"codeclimate-test-reporter\"' | cat - spec/spec_helper.rb > temp && mv temp spec/spec_helper.rb"

  run "bundle install"

  git add: "."
  git commit: %Q{ -m 'configure code coverage scores to be sent to CodeClimate' }

end

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
