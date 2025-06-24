# groupmember

A Puppet module for managing Unix group memberships. This module allows you to enforce that specified users are members of specified groups, with support for exclusive membership, bulk operations, and automatic group creation.

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with groupmember](#setup)
    * [What groupmember affects](#what-groupmember-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with groupmember](#beginning-with-groupmember)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

The groupmember module provides a simple and flexible way to manage Unix group memberships in Puppet. It can:

- Add users to groups while preserving existing memberships
- Enforce exclusive membership (remove users not in the specified list)
- Manage multiple groups for multiple users in bulk operations
- Automatically create groups if they don't exist
- Remove users from groups when needed

This module is particularly useful for managing administrative privileges, development team access, and service account permissions.

## Setup

### What groupmember affects

The groupmember module affects:

* Unix group memberships in `/etc/group`
* User group assignments via `usermod` and `gpasswd` commands
* Group creation when `auto_create_groups` is enabled

### Setup Requirements

This module requires:

* A Unix-like operating system with standard user management tools
* The `usermod`, `gpasswd`, `groups`, and `getent` commands available
* Appropriate permissions to modify group memberships (typically root)

### Beginning with groupmember

The simplest way to use groupmember is to include the main class and then use the defined types:

```puppet
include groupmember

groupmember::membership { 'sudo_users':
  group_name => 'sudo',
  members    => ['alice', 'bob', 'charlie'],
}
```

## Usage

### Basic group membership management

Add users to a group:

```puppet
groupmember::membership { 'admin_group':
  group_name => 'sudo',
  members    => ['user1', 'user2', 'user3'],
}
```

### Exclusive membership

Ensure only specified users are in the group (removes others):

```puppet
groupmember::membership { 'developers_only':
  group_name => 'developers',
  members    => ['dev1', 'dev2'],
  exclusive  => true,
}
```

### Bulk membership management

Add multiple users to multiple groups:

```puppet
groupmember::bulk_membership { 'admin_team':
  users  => ['admin1', 'admin2'],
  groups => ['sudo', 'wheel', 'adm'],
}
```

### Remove users from groups

```puppet
groupmember::membership { 'cleanup_old_users':
  ensure     => 'absent',
  group_name => 'old_project',
  members    => ['former_employee1', 'former_employee2'],
}
```

### Common administrative patterns

Use the convenience class for typical setups:

```puppet
class { 'groupmember::common':
  admin_users     => ['alice', 'bob'],
  developer_users => ['dev1', 'dev2', 'dev3'],
}
```

## Reference

### Classes

#### `groupmember`
The main class that enables the module's functionality.

#### `groupmember::common`
Convenience class for common group management patterns.

**Parameters:**
- `admin_users`: Array of users who should have administrative privileges
- `developer_users`: Array of users who should be in development-related groups
- `service_users`: Array of service accounts that need specific group memberships

### Defined Types

#### `groupmember::membership`
Manages membership for a single group.

**Parameters:**
- `group_name`: The name of the group to manage
- `members`: Array of usernames that should be members
- `ensure`: Whether membership should be 'present' or 'absent'
- `exclusive`: If true, removes users not in the members list

#### `groupmember::bulk_membership`
Manages membership across multiple groups for multiple users.

**Parameters:**
- `users`: Array of usernames to manage
- `groups`: Array of group names these users should be members of
- `ensure`: Whether memberships should be 'present' or 'absent'
- `auto_create_groups`: Whether to automatically create missing groups

## Limitations

In the Limitations section, list any incompatibilities, known issues, or other
warnings.

## Development

In the Development section, tell other users the ground rules for contributing
to your project and how they should submit their work.

## Release Notes/Contributors/Etc. **Optional**

If you aren't using changelog, put your release notes here (though you should
consider using changelog). You can also add any additional sections you feel are
necessary or important to include here. Please use the `##` header.

[1]: https://puppet.com/docs/pdk/latest/pdk_generating_modules.html
[2]: https://puppet.com/docs/puppet/latest/puppet_strings.html
[3]: https://puppet.com/docs/puppet/latest/puppet_strings_style.html

