source 'https://rubygems.org'

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion,  require: false
else
  gem 'puppet',                 require: false
end

group :development, :test do
  gem 'puppet-lint',            require: false
  gem 'pry',                    require: false
  gem 'rspec',                  require: false
  gem 'rspec-puppet',           require: false
  gem 'puppetlabs_spec_helper', require: false
  gem 'serverspec',             require: false
  gem 'simplecov',              require: false
  gem 'puppet-blacksmith',      require: false
  gem 'puppet-syntax',          require: false
  gem 'beaker',
      require: false,
      git: 'https://github.com/leoc/beaker.git',
      branch: 'add-prebuilt-packages-to-docker'
  gem 'beaker-rspec',           require: false
end
