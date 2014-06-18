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

run "cp config/database.yml config/database.yml.sample"
#TODO: remove database.yml from repo

git add: "."
git commit: %Q{ -m 'add standard configuration' }

# add standard gems

gem 'slim-rails'

gem_group :development, :test do

  gem 'factory_girl_rails', '~> 4.0'
  gem 'rspec-rails', '~> 3.0.0.beta'
  gem 'dotenv-rails'
  
end

file '.env', <<-CODE
  SECRET_TOKEN=please_replace
CODE

file '.env.sample', <<-CODE
  SECRET_TOKEN=please_replace
CODE

run "echo '.env' >> .gitignore"

git add: "."
git commit: %Q{ -m 'add standard gems' }

# add app signal

if yes?("Add appsignal?", :limited_to => %w[y n])

  gem 'appsignal'

  api_key = ask("Enter appsignal API key:")
  generate :appsignal, api_key

end

git add: "."
git commit: %Q{ -m 'install and configure appsignal' }

# configure for Heroku deployment

if yes?("Will this app be deployed to Heroku?", :limited_to => %w[y n])

  gem 'pg'

  gem_group :production do

    gem 'heroku-deflater'
    gem 'rails_12factor'
    
  end

  run "echo 'config.ru' >> $stdout.sync = true"
  run "echo 'web: bundle exec rails server -p $PORT' >> Procfile"
  run "echo PORT=3000 >> .env"

  git add: "."
  git commit: %Q{ -m 'configure for heroku deployment' }

  #TODO: ask for existing heroku apps, or create them

end

# configure test environment

file '.rspec', <<-CODE
  --color
  --format documentation
CODE

gem_group :test do

  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'guard-rspec', '~> 4.2.8', require: false
  gem 'pry-rails'
  gem 'pry-remote'
  gem 'quiet_assets'
  gem 'spring'

  gem 'rb-fchange', require: false
  gem 'rb-fsevent', require: false
  gem 'rb-inotify', require: false
  gem 'rb-readline', require: false

  gem 'capybara'
  gem "codeclimate-test-reporter", require: nil
  gem 'database_cleaner'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  
  gem 'terminal-notifier-guard' # OSX
  
end

# push to GitHub

if yes?("Initialize GitHub repository?")
  
  git_uri = `git config remote.origin.url`.strip
  
  unless git_uri.size == 0
  
    say "Repository already exists:"
    say "#{git_uri}"
    
  else
    
    #TODO: change this for organization repository
    username = ask "What is your GitHub username?"
    run "curl -u #{username} -d '{\"name\":\"#{app_name}\"}' https://api.github.com/user/repos"
    git remote: %Q{ add origin git@github.com:#{username}/#{app_name}.git }
    git push: %Q{ origin master }
    
  end
  
end

#TODO: run "bundle exec guard init rspec"

