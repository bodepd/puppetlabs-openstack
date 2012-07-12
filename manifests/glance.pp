#
# == Class: openstack::glance
#
# Installs and configures Glance
# Assumes the following:
#   - Keystone for authentication
#   - keystone tenant: services
#   - keystone username: glance
#   - storage backend: file
#
# === Parameters
#
# See params.pp
#
# === Example
#
# class { 'openstack::glance':
#   glance_user_password => 'changeme',
#   db_password          => 'changeme',
#   public_address       => '192.168.1.1',
#   admin_addresss       => '192.168.1.1',
#   internal_address     => '192.168.1.1',
# }

class openstack::glance (
  $db_type              = $::openstack::params::db_type,
  $db_host              = $::openstack::params::db_host,
  $glance_db_user       = $::openstack::params::glance_db_user,
  $glance_db_dbname     = $::openstack::params::glance_db_dbname,
  $glance_user_password = $::openstack::params::glance_user_password,
  $glance_db_password   = $::openstack::params::glance_db_password,
  $public_address       = $::openstack::params::public_address,
  $admin_address        = $::openstack::params::admin_address,
  $internal_address     = $::openstack::params::internal_address,
  $verbose              = $::openstack::params::verbose
) inherits openstack::params {

  # Configure the db string
  case $db_type {
    'mysql': {
      $sql_connection = "mysql://${glance_db_user}:${glance_db_password}@${db_host}/${glance_db_dbname}"
    }
  }

  # Install and configure glance-api
  class { 'glance::api':
    log_verbose       => $verbose,
    log_debug         => $verbose,
    auth_type         => 'keystone',
    keystone_tenant   => 'services',
    keystone_user     => 'glance',
    keystone_password => $glance_user_password,
  }

  # Install and configure glance-registry
  class { 'glance::registry':
    log_verbose       => $verbose,
    log_debug         => $verbose,
    auth_type         => 'keystone',
    keystone_tenant   => 'services',
    keystone_user     => 'glance',
    keystone_password => $glance_user_password,
    sql_connection    => $sql_connection,
  }

  # Configure file storage backend
  class { 'glance::backend::file': }

  # Configure Glance to use Keystone
  class { 'glance::keystone::auth':
    password         => $glance_user_password,
    public_address   => $public_address,
    admin_address    => $admin_address,
    internal_address => $internal_address,
  }

}
