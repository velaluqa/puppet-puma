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
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to_not eq(1)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to eq(0)
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
    end
  end

  describe 'configuring rack with bundler' do
    it 'should work without errors' do
      pp = <<PP
package { 'bundler':
    ensure   => 'installed',
    provider => 'gem',
}

puma::app { 'redmine':
  use_bundler => true,
  require     => Package['bundler'],
}
file { "/srv/redmine/current/Gemfile":
  content => "source 'https://rubygems.org'\n\n\ngem 'puma'\ngem 'sinatra'",
  require => File['/srv/redmine/current'],
  before  => Service['redmine'],
}
file { "/srv/redmine/current/Gemfile.lock":
  content => "GEM\n  remote: https://rubygems.org/\n  specs:\n    puma (2.8.2)\n      rack (>= 1.1, < 2.0)\n    rack (1.5.2)\n    rack-protection (1.5.3)\n      rack\n    sinatra (1.4.5)\n      rack (~> 1.4)\n      rack-protection (~> 1.4)\n      tilt (~> 1.3, >= 1.3.4)\n    tilt (1.4.1)\n\n\nPLATFORMS\n  ruby\n\nDEPENDENCIES\n  puma\n  sinatra",
  require => File['/srv/redmine/current'],
  before  => Service['redmine'],
}
exec { 'install-app-bundle':
  command => 'bundle install --deployment --without development test',
  unless  => 'bundle check',
  cwd     => '/srv/redmine/current/',
  require => [Package['bundler'], User['deployment'], File['/srv/redmine/current/Gemfile'], File['/srv/redmine/current/Gemfile.lock']],
  before  => Service['redmine'],
  user    => 'deployment',
  path    => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/', '/usr/local/bin'],
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
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to_not eq(1)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to eq(0)
    end

    describe file('/etc/init.d/redmine') do
      it { should be_file }
      it { should contain('BUNDLE_PREFIX=" bundle exec"') }
    end

    describe service('redmine') do
      it { should be_enabled }
    end
  end
end
