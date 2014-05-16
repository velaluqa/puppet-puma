require 'spec_helper'

describe 'puma::app', type: :define do
  let(:title) { 'redmine' }

  context 'with default parameters' do
    it 'should ensure user' do
      should contain_user('deployment').
              with(:ensure => :present,
                   :home => '/home/deployment')
    end

    it 'should ensure user' do
      should contain_group('deployment').
              with(:ensure => :present)
    end

    it 'should contain necessary directories' do
      options = {
        :ensure => :directory,
        :owner  => 'deployment',
        :group  => 'deployment',
        :mode   => '0775',
      }
      should contain_file('/srv/redmine').with(options)
      should contain_file('/srv/redmine/shared').with(options)
      should contain_file('/srv/redmine/shared/tmp').with(options)
      should contain_file('/srv/redmine/shared/config').with(options)
      should contain_file('/srv/redmine/shared/tmp/sockets').with(options)
    end

    it 'should configure puma.rb' do
      should contain_file('/srv/redmine/shared/config/puma.rb').
              with(:owner => 'deployment',
                   :group => 'deployment')
    end

    it 'should setup init.d script' do
      should contain_file("/etc/init.d/redmine").
              with(:owner => 'root',
                   :group => 'root',
                   :mode  => '0755')
    end

    it 'should ensure running service' do
      should contain_service('redmine').
              with(:ensure => :running,
                   :enable => true)
    end
  end

  context 'with custom parameters' do
    let(:params) do
      {
        :app_name => 'whatTheRedmine',
        :app_user => 'myuser',
        :app_root => '/srv/customRedmine'
      }
    end

    it 'should ensure user' do
      should contain_user('myuser').
              with(:ensure => :present,
                   :home => '/home/myuser')
    end

    it 'should ensure user' do
      should contain_group('myuser').
              with(:ensure => :present)
    end

    it 'should contain necessary directories' do
      options = {
        :ensure => :directory,
        :owner  => 'myuser',
        :group  => 'myuser',
        :mode   => '0775',
      }
      should contain_file('/srv/customRedmine').with(options)
      should contain_file('/srv/customRedmine/shared').with(options)
      should contain_file('/srv/customRedmine/shared/tmp').with(options)
      should contain_file('/srv/customRedmine/shared/config').with(options)
      should contain_file('/srv/customRedmine/shared/tmp/sockets').with(options)
    end

    it 'should configure puma.rb' do
      should contain_file('/srv/customRedmine/shared/config/puma.rb').
              with(:owner => 'myuser',
                   :group => 'myuser')
    end

    it 'should setup init.d script' do
      should contain_file("/etc/init.d/whatTheRedmine").
              with(:owner => 'root',
                   :group => 'root',
                   :mode  => '0755')
    end

    it 'should ensure running service' do
      should contain_service('whatTheRedmine').
              with(:ensure => :running,
                   :enable => true)
    end
  end
end
