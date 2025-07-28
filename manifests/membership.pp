# @summary Enforces group membership for specified users
#
# This defined type takes an array of usernames and ensures they are members
# of the specified group. It reads the current group membership from /etc/group
# and adds any missing users to the group.
#
# @param group_name
#   The name of the group to manage membership for
#
# @param members
#   Array of usernames that should be members of the group
#
# @param ensure
#   Whether the group membership should be present or absent
#
# @param exclusive
#   If true, removes any users from the group that are not in the members array
#   If false, only adds users to the group without removing existing members
#
# @example Add users to sudo group
#   groupmember::membership { 'sudo_users':
#     group_name => 'sudo',
#     members    => ['alice', 'bob', 'charlie'],
#   }
#
# @example Exclusive membership management
#   groupmember::membership { 'developers':
#     group_name => 'developers',
#     members    => ['dev1', 'dev2'],
#     exclusive  => true,
#   }
#
define groupmember::membership (
  String $group_name,
  Array[String] $members,
  Enum['present', 'absent'] $ensure = 'present',
  Boolean $exclusive = false,
) {
  # Ensure the group exists before managing membership
  group { $group_name:
    ensure => present,
  }

  if $ensure == 'present' {
    # Add each user to the group
    $members.each |String $username| {
      exec { "add_${username}_to_${group_name}":
        command => "/usr/sbin/usermod -a -G ${group_name} ${username}",
        unless  => "/bin/groups ${username} | /bin/grep -q '\\b${group_name}\\b'",
        require => Group[$group_name],
        onlyif  => "/usr/bin/getent passwd ${username}",
      }
    }

    # If exclusive mode is enabled, remove users not in the members list
    if $exclusive {
      # Get current group members and remove those not in our list
      exec { "exclusive_membership_${group_name}":
        command => "/bin/bash -c '
          current_members=\$(getent group ${group_name} | cut -d: -f4 | tr \",\" \" \")
          target_members=\"${members.join(' ')}\"
          
          for user in \$current_members; do
            if [[ \" \$target_members \" != *\" \$user \"* ]] && [[ -n \"\$user\" ]]; then
              echo \"Removing \$user from ${group_name}\"
              gpasswd -d \"\$user\" \"${group_name}\" || true
            fi
          done
        '",
        require => Group[$group_name],
        # Only run if there are users to potentially remove
        onlyif  => "/usr/bin/getent group ${group_name} | /bin/grep -v -q ${members.join(' ')}",
      }
    }
  } else {
    # Remove all specified users from the group
    $members.each |String $username| {
      exec { "remove_${username}_from_${group_name}":
        command => "/usr/sbin/gpasswd -d ${username} ${group_name}",
        onlyif  => [
          "/usr/bin/getent passwd ${username}",
          "/bin/groups ${username} | /bin/grep -q '\\b${group_name}\\b'",
        ],
        require => Group[$group_name],
      }
    }
  }
}
