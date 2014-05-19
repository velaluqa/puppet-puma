require 'beaker-rspec'
require 'pry'

hosts.each do |host|
  # Install Puppet
  install_package host, 'rubygems'
  # TODO: Fix this for various types of linux distributions or unix derivatives.
  on host,
     'DEBIAN_FRONTEND=noninteractive apt-get install --yes -q openssl libssl-dev'
  on host, 'gem install puppet --no-ri --no-rdoc'
  on host, "mkdir -p #{host['distmoduledir']}"
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module
    puppet_module_install(:source => proj_root, :module_name => 'puma')
  end
end
