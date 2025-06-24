# Example usage of the groupmember module
#
# This file demonstrates various ways to use the groupmember module
# to manage group memberships

# Basic usage - Add users to a single group
groupmember::membership { 'sudo_admins':
  group_name => 'sudo',
  members    => ['alice', 'bob', 'charlie'],
}

# Exclusive membership - Only specified users in the group
groupmember::membership { 'developers_exclusive':
  group_name => 'developers',
  members    => ['dev1', 'dev2', 'dev3'],
  exclusive  => true,
}

# Remove users from a group
groupmember::membership { 'remove_from_temp':
  ensure     => 'absent',
  group_name => 'temp_group',
  members    => ['olduser1', 'olduser2'],
}

# Bulk membership management - Add users to multiple groups
groupmember::bulk_membership { 'admin_team':
  users  => ['admin1', 'admin2'],
  groups => ['sudo', 'wheel', 'adm', 'systemd-journal'],
}

# System groups for service accounts
groupmember::membership { 'service_accounts':
  group_name => 'service',
  members    => ['nginx', 'apache', 'mysql'],
}
