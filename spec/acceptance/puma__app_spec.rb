require 'spec_helper_acceptance'

describe 'puma::app class' do
  describe 'configuring rack without bundler and rvm' do
    it 'should work without errors' do
      pp = <<PP
package { ['sinatra', 'puma']:
    ensure   => 'installed',
    provider => 'gem',
}

puma::app { "redmine":
  require => Package['sinatra', 'puma'],
}

file { "/srv/redmine/current/config.ru":
  content => "require 'sinatra'; class App < Sinatra::Base; get '/' do '<html><body>Test file!</body></html>'; end; end; run App",
  require => File['/srv/redmine/current'],
  before => Service["redmine"],
}
file { "/srv/redmine/current/tmp":
  ensure => link,
  target => '../shared/tmp',
  force => true,
  require => File['/srv/redmine/current'],
  before => Service["redmine"],
}
file { "/srv/redmine/current/log":
  ensure => link,
  target => '../shared/log',
  force => true,
  require => File['/srv/redmine/current'],
  before => Service["redmine"],
}
file { "/srv/redmine/current/config":
  ensure => link,
  target => '../shared/config',
  force => true,
  require => File['/srv/redmine/current'],
  before => Service["redmine"],
}
PP

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe file('/srv/redmine/shared/config/puma.rb') do
      it { should be_file }
      it { should contain('application_path = \'/srv/redmine/current\'') }
      it { should contain('pidfile "#{application_path}/tmp/pids/puma.pid"') }
      it { should contain('state_path "#{application_path}/tmp/pids/puma.state"') }
      it { should contain('stdout_redirect "#{application_path}/log/puma.stdout.log", "#{application_path}/log/puma.stderr.log"') }
      it { should contain('bind "unix://#{application_path}/tmp/sockets/puma.socket"') }
    end

    describe file('/etc/init.d/redmine') do
      it { should be_file }
      it { should contain('APP_ROOT="/srv/redmine/current"') }
      it { should contain('APP_USER="deployment"') }
      it { should contain('NAME="redmine"') }
      it { should contain('DESC="redmine"') }
    end

    describe service('redmine') do
      it { should be_enabled }
      it { should be_running }
    end
  end
end
