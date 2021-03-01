[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/nierdz/ansible-role-nextcloud/CI)](https://github.com/nierdz/ansible-role-nextcloud/actions/workflows/ci.yml)
[![Ansible Role](https://img.shields.io/ansible/role/53258)](https://galaxy.ansible.com/nierdz/nextcloud)
[![Ansible Quality Score](https://img.shields.io/ansible/quality/53258)](https://galaxy.ansible.com/nierdz/nextcloud)
[![Ansible Role](https://img.shields.io/ansible/role/d/53258)](https://galaxy.ansible.com/nierdz/nextcloud)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

# Nextcloud

This **ansible** role install [nextcloud](https://nextcloud.com/) the capistrano way. This means, the folder structure look likes this:

```
/var/wwww
└── nextcloud.local
    ├── current -> /var/www/nextcloud.local/releases/20.0.7
    │   └── nextcloud
    ├── data
    │   ├── admin
    │   ├── appdata_somerandomshit
    │   ├── files_external
    │   ├── index.html
    │   └── nextcloud.log
    ├── releases
    │   ├── 20.0.5
    │   ├── 20.0.6
    │   └── 20.0.7
    └── shared
        └── config.php
```

For now, this role only supports **MySQL** as backend. It uses **redis** with default configuration as local and distributed caching as well as transactional file locking.

## Requirements

**Nextcloud** needs **PHP**, a **web server** and a **DBMS** to work. To fulfill these requirements it's strongly recommended to use these 3 roles:

 - [geerlingguy/mysql](https://galaxy.ansible.com/geerlingguy/mysql)
 - [geerlingguy/php](https://galaxy.ansible.com/geerlingguy/php)
 - [geerlingguy/nginx](https://galaxy.ansible.com/geerlingguy/nginx)

Why particulary those roles ? Because they're pretty well maintained and some variables from theses roles are used in this one but you can still use another roles.

In production, you will also need a TLS certificate which can be obtained using [acme.sh](https://github.com/acmesh-official/acme.sh). This part is covered in example playbook.

## Role Variables

### `nextcloud_version`
Version of nextcloud to install.
Default: `"20.0.7"`

### `nextcloud_domain`
Domain name to use.
Default: `""`

### `nextcloud_php_user`
All nextcloud files will be owned by this user. Usually you need to set this value to `www-data`.
Default: `"{{ php_fpm_pool_user | default('www-data') }}"`

### `nextcloud_php_version`
Major version of php to use. Could be one of `7.2`, `7.3`, `7.4` or `8.0`.
Default: `"{{ php_default_version_debian | default('7.4') }}"`

### `nextcloud_keep_releases`
How long you want to keep old releases.
Default: `"60d"`

### `nextcloud_admin_user`
Default admin user created during installation. Once install is done you can create another user with admin role and remove this one.
Default: `""`

### `nextcloud_admin_password`
Password of `nextcloud_admin_user`. It's strongy recommended to vault this with [ansible-vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html)
Default: `""`

### `nextcloud_instanceid`
Unique instanceid. Generate a random one and keep it as long as your installation is alive.
Default: `""`

### `nextcloud_passwordsalt`
The salt used to hash all passwords. It's strongy recommended to vault this with [ansible-vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html)
Default: `""`

### `nextcloud_secret`
Secret used by nextcloud for various purposes, e.g. to encrypt data. If you lose this string there will be data corruption. It's strongy recommended to vault this with [ansible-vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html)
Default: `""`

### `nextcloud_dbhost`
Host to use to connect the database.
Default: `"localhost"`

### `nextcloud_dbname`
The name of the nextcloud database which is set during installation.
Default: `"nextcloud"`


### `nextcloud_dbuser`
The user that nextcloud uses to read and write the database.
Default: `"nextcloud"`

### `nextcloud_dbpassword`
Password of `nextcloud_dbuser`. It's strongy recommended to vault this with [ansible-vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html)
Default: `""`

### `nextcloud_deploy_to`
Main folder of your nextcloud installation.
Default: `"/var/www/{{ nextcloud_domain }}"`

### `nextcloud_datadirectory:`
Where user files are stored.
Default: `"{{ nextcloud_deploy_to }}/data"`

### `nextcloud_php_packages`
Additional php packages needed by nextcloud.
Default:
```
- php-pear
- php{{ nextcloud_php_version }}-bcmath
- php{{ nextcloud_php_version }}-bz2
- php{{ nextcloud_php_version }}-curl
- php{{ nextcloud_php_version }}-gd
- php{{ nextcloud_php_version }}-gmp
- php{{ nextcloud_php_version }}-imagick
- php{{ nextcloud_php_version }}-intl
- php{{ nextcloud_php_version }}-json
- php{{ nextcloud_php_version }}-mbstring
- php{{ nextcloud_php_version }}-mysql
- php{{ nextcloud_php_version }}-redis
- php{{ nextcloud_php_version }}-xml
- php{{ nextcloud_php_version }}-zip
```

### `nextcloud_packages`
Additional packages needed by nextcloud.
Default:
```
- redis-server
- redis-tools
- unzip
```

## Example Playbook
You can refer to [prepare.yml](molecule/default/prepare.yml) and [converge.yml](molecule/default/converge.yml) to see a working example.

## License

[GPLv3](LICENCE)
