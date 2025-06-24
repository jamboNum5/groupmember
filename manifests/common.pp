# @summary Utility functions for group management
#
# This class provides common group management patterns and utilities
#
# @param admin_users
#   Array of users who should have administrative privileges
#
# @param developer_users  
#   Array of users who should be in development-related groups
#
# @param service_users
#   Array of service accounts that need specific group memberships
#
# @example Configure common group memberships
#   class { 'groupmember::common':
#     admin_users     => ['alice', 'bob'],
#     developer_users => ['dev1', 'dev2', 'dev3'],
#   }
#
class groupmember::common (
  Array[String] $admin_users = [],
  Array[String] $developer_users = [],
  Array[String] $service_users = [],
) {

  # Administrative users - typically need sudo, wheel, and system access
  if !empty($admin_users) {
    groupmember::bulk_membership { 'system_admins':
      users  => $admin_users,
      groups => ['sudo', 'wheel', 'adm', 'systemd-journal'],
    }
  }

  # Developer users - typically need access to logs, docker, etc.
  if !empty($developer_users) {
    groupmember::bulk_membership { 'developers':
      users  => $developer_users,
      groups => ['docker', 'systemd-journal'],
    }
  }

  # Service users - typically need specific system group access
  if !empty($service_users) {
    groupmember::membership { 'service_accounts':
      group_name => 'service',
      members    => $service_users,
    }
  }
}
