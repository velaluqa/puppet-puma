define puma::app(
  $app_name    = $name,
  $app_user    = 'deployment',
  $app_root    = "/srv/${name}",
  $db_adapter  = 'UNSET',
  $db_name     = 'UNSET',
  $db_user     = 'UNSET',
  $db_password = 'UNSET',
  $db_host     = 'localhost',
  $db_socket   = 'UNSET',
  $db_port     = '3306',
  $rvm_ruby    = '',
) {

  if $rvm_ruby != '' {
    $rvm_prefix = "source /usr/local/rvm/scripts/rvm; rvm use ${rvm_ruby} > /dev/null; "
  } else {
    $rvm_prefix = ''
  }

  user {
    $app_user:
      ensure     => present,
      shell      => '/bin/bash',
      password   => '*',
      home       => "/home/${app_user}",
      system     => true,
  }

  group { $app_user:
    ensure => present,
    require => User[$app_user],
  }

  file { $app_root:
    ensure  => directory,
    owner   => $app_user,
    group   => $app_user,
    mode    => '0775',
    require => Group[$app_user],
  }

  file { ["${app_root}/shared", "${app_root}/shared/config"]:
    ensure => directory,
    owner  => $app_user,
    group  => $app_user,
    mode   => '0775',
  }

  file { "${app_root}/shared/config/puma.rb":
    content => template("puma/puma.rb.erb"),
    owner => $app_user,
    group => $app_user,
    require => File["${app_root}/shared/config"],
  }

  file { "/etc/init.d/redmine":
    content => template("puma/init.erb"),
    owner => "root",
    group => "root",
    mode => "0755",
  }

  if $db_adapter != 'UNSET' {
    if $db_password == 'UNSET' {
      fail('db_password is required for database.yml')
    }

    if $db_user == 'UNSET' {
      $db_user_real = $app_user
    } else {
      $db_user_real = $db_user
    }

    if $db_name == 'UNSET' {
      $db_name_real = regsubst($app_name, '-', '_', 'G')
    } else {
      $db_name_real = $db_name
    }

    case $db_adapter {
      "mysql": {
        mysql::db { $db_name_real :
          user     => $db_user_real,
          password => $db_password,
          host     => $db_host,
          grant    => ['all'],
          before   => File["${app_name}-database.yml"],
        }
      }
      "pgsql": {
        postgresql::database { $db_name_real:
          require => Class['postgresql::server'],
          locale  => $locale,
        }

        postgresql::database_user { $db_user_real:
          password_hash => postgresql_password($db_user_real, $db_password),
          superuser     => true, # suggested fix by gitlab ticket list for postgres
          require       => Postgresql::Database[$db_name_real],
        }

        postgresql::database_grant { "GRANT ${$db_user_real} - ALL - ${db_name_real}":
          privilege => 'ALL',
          db        => $db_name_real,
          role      => $db_user_real,
          require   => [Postgresql::Database[$db_name_real], Postgresql::Database_user[$db_user_real]],
          before    => File["${app_name}-database.yml"],
        }
      }
    }

    file { "${app_name}-database.yml":
      ensure  => file,
      path    => "${app_root}/shared/config/database.yml",
      owner   => $app_user,
      group   => $app_user,
      content => template('puma/database.yml.erb'),
      mode    => '0644',
      require => File["${app_root}/shared/config"],
    }
  }

  service { $app_name:
    ensure => running,
    enable => true,
  }
}
