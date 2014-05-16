require 'puppet'
require 'rspec'
require 'rspec-puppet'
require 'simplecov'

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

SimpleCov.start do
  add_filter "/spec/"
end

RSpec.configure do |c|
  c.module_path = File.join(fixture_path, 'modules')
  c.manifest_dir = File.join(fixture_path, 'manifests')
  c.formatter = :documentation
end
