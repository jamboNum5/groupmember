# @summary Manages multiple group memberships for users
#
# This defined type can manage multiple groups at once and automatically
# detect existing groups from /etc/group to enforce membership.
#
# @param users
#   Array of usernames to manage group membership for
#
# @param groups
#   Array of group names these users should be members of
#
# @param ensure
#   Whether the group memberships should be present or absent
#
# @param auto_create_groups
#   Whether to automatically create groups if they don't exist
#
# @example Manage multiple users across multiple groups
#   groupmember::bulk_membership { 'admin_users':
#     users  => ['alice', 'bob'],
#     groups => ['sudo', 'wheel', 'adm'],
#   }
#
define groupmember::bulk_membership (
  Array[String] $users,
  Array[String] $groups,
  Enum['present', 'absent'] $ensure = 'present',
  Boolean $auto_create_groups = true,
) {

  # Ensure all groups exist if auto_create_groups is true
  if $auto_create_groups and $ensure == 'present' {
    $groups.each |String $group_name| {
      group { $group_name:
        ensure => present,
      }
    }
  }

  # Create membership resources for each group
  $groups.each |String $group_name| {
    if $auto_create_groups {
      groupmember::membership { "${name}_${group_name}":
        ensure     => $ensure,
        group_name => $group_name,
        members    => $users,
        require    => Group[$group_name],
      }
    } else {
      groupmember::membership { "${name}_${group_name}":
        ensure     => $ensure,
        group_name => $group_name,
        members    => $users,
      }
    }
  }
}
