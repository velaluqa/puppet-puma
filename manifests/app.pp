define puma::app(
  $app_name    = $name,
  $app_user    = 'deployment',
  $app_root    = "/srv/${name}",
  $rvm_ruby    = '',
  $use_bundler = false,
) {

  if $rvm_ruby != '' {
    $rvm_prefix =
      "source /usr/local/rvm/scripts/rvm; rvm use ${rvm_ruby} > /dev/null; "
  } else {
    $rvm_prefix = ''
  }

  user { $app_user:
    ensure   => present,
    shell    => '/bin/bash',
    password => '*',
    home     => "/home/${app_user}",
    system   => true,
  }

  ->

  group { $app_user: ensure => present }

  ->

  file { [$app_root,
          "${app_root}/current",
          "${app_root}/shared",
          "${app_root}/shared/log",
          "${app_root}/shared/tmp",
          "${app_root}/shared/config",
          "${app_root}/shared/tmp/sockets",
          "${app_root}/shared/tmp/pids",
          "/home/${app_user}"]:
    ensure => directory,
    owner  => $app_user,
    group  => $app_user,
    mode   => '0775',
  }

  ->

  file { "${app_root}/shared/config/puma.rb":
    content => template('puma/puma.rb.erb'),
    owner   => $app_user,
    group   => $app_user,
  }

  ->

  file { "/etc/init.d/${app_name}":
    content => template('puma/init.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  ->

  service { $app_name:
    ensure => running,
    enable => true,
  }
}
