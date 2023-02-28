[![CI Status](https://github.com/nierdz/ansible-role-nextcloud/workflows/CI/badge.svg?branch=master)](https://github.com/nierdz/ansible-role-nextcloud/actions/workflows/ci.yml)
[![Ansible Role](https://img.shields.io/ansible/role/53258)](https://galaxy.ansible.com/nierdz/nextcloud)
[![Ansible Quality Score](https://img.shields.io/ansible/quality/53258)](https://galaxy.ansible.com/nierdz/nextcloud)
[![Ansible Role](https://img.shields.io/ansible/role/d/53258)](https://galaxy.ansible.com/nierdz/nextcloud)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

# Nextcloud

This **ansible** role installs [nextcloud](https://nextcloud.com/) the capistrano way. This means, the folder structure looks like this:

```
/var/wwww
└── nextcloud.local
    ├── current -> /var/www/nextcloud.local/releases/20.0.7
    │   └── nextcloud
    │       └── config
    │          └── config.php -> /var/www/shared/config.php
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

**Nextcloud** needs **PHP**, a **web server** and a **DBMS** to work. To fulfill these requirements, it's strongly recommended to use these 3 roles:

 - [geerlingguy/mysql](https://galaxy.ansible.com/geerlingguy/mysql)
 - [geerlingguy/php](https://galaxy.ansible.com/geerlingguy/php)
 - [geerlingguy/nginx](https://galaxy.ansible.com/geerlingguy/nginx)

Why particularly those roles ? Because they're pretty well maintained and some variables from these roles are used in this one, but you can still use other roles.

In production, you will also need a TLS certificate, which can be obtained using [acme.sh](https://github.com/acmesh-official/acme.sh).

## Role Variables

### `nextcloud_version`
Version of nextcloud to install.
Default: `"25.0.4"`

### `nextcloud_domain`
Domain name to use.
Default: `""`

### `nextcloud_php_user`
All nextcloud files will be owned by this user. Usually you need to set this value to `www-data`.
Default: `"{{ php_fpm_pool_user | default('www-data') }}"`

### `nextcloud_php_version`
Major version of PHP to use. Could be one of `7.4` or `8.0`.
Default: `"{{ php_default_version_debian | default('8.0') }}"`

### `nextcloud_php_bin_path`
Path to PHP binary.
Default: `/usr/bin/php`

### `nextcloud_keep_releases`
How long you want to keep old releases.
Default: `"60d"`

### `nextcloud_admin_user`
Default admin user created during installation. Once install is done, you can create another user with admin role and remove this one.
Default: `""`

### `nextcloud_admin_password`
Password of `nextcloud_admin_user`. It's strongly recommended vaulting this with [ansible-vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html)
Default: `""`

### `nextcloud_config_template`
Jinja2 template to use for the Nextcloud's `config.php`. To use a custom config template, you need to:
* create a `templates/` directory at the same level as your playbook
* create a `templates/myconfig.php.j2` file (just choose a different name from the default template)
* in your playbook set the var `nextcloud_config_template: myconfig.php.j2`
Default: `"config.php.j2"`

### `nextcloud_instanceid`
Unique instanceid. Generate a random one and keep it as long as your installation is alive.
Default: `""`

### `nextcloud_passwordsalt`
The salt used to hash all passwords. It's strongly recommended vaulting this with [ansible-vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html)
Default: `""`

### `nextcloud_secret`
Secret used by nextcloud for various purposes, e.g. to encrypt data. If you lose this string there will be data corruption. It's strongly recommended vaulting this with [ansible-vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html)
Default: `""`

### `nextcloud_dbhost`
Host to use to connect the database.
Default: `"localhost"`

### `nextcloud_dbname`
The name of the nextcloud database, which is set during installation.
Default: `"nextcloud"`


### `nextcloud_dbuser`
The user that nextcloud uses to read and write the database.
Default: `"nextcloud"`

### `nextcloud_dbpassword`
Password of `nextcloud_dbuser`. It's strongly recommended vaulting this with [ansible-vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html)
Default: `""`

### `nextcloud_deploy_to`
Main folder of your nextcloud installation.
Default: `"/var/www/{{ nextcloud_domain }}"`

### `nextcloud_datadirectory:`
Where user files are stored.
Default: `"{{ nextcloud_deploy_to }}/data"`

### `nextcloud_php_packages`
Additional PHP packages needed by nextcloud.
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

### `nextcloud_apps`
List of apps to install and enable.
Default: `[]`

### `nextcloud_no_log`
Hide sensitive data during deploy.
Default: `true`

## Working example

Here is what you should have in your `playbook.yml`:
```
- name: Configure nextcloud servers
  become: true
  hosts: nextcloud
  vars_files:
    - vault_vars/nextcloud.yml
  roles:
    - {role: acme_sh, tags: [acme_sh']} (use whatever you want to get TLS certificates)
    - {role: nginx, tags: ['nginx']}
    - {role: mysql, tags: ['mysql']}
    - {role: php, tags: ['php']}
    - {role: percona, tags: ['percona']}
    - {role: nextcloud, tags: ['nextcloud']}
  pre_tasks:
    - name: Install sury key
      apt_key:
        url: "https://packages.sury.org/php/apt.gpg"
        state: present
    - name: Add sury repositories
      apt_repository:
        repo: "deb https://packages.sury.org/php/ {{ ansible_distribution_release }} main"
        state: present
        update_cache: true
        filename: sury
    - name: Copy specific nginx configuration files
      copy:
        src: "{{ item }}"
        dest: /etc/nginx/
        owner: root
        mode: 0644
      with_fileglob:
        - nginx/*.conf
    - name: Copy /etc/nginx/dh4096.pem
      copy:
        src: nginx/dh4096.pem
        dest: /etc/nginx/dh4096.pem
        owner: www-data
        mode: 0400
```

Here is your vaulted vars inside `vault_vars/nextcloud.yml`:
```
mysql_root_password_vault: vaultmeplease
nextcloud_dbpassword_vault: vaultmeplease
nextcloud_passwordsalt_vault: vaultmeplease
nextcloud_secret_vault: vaultmeplease
nextcloud_instanceid_vault: vaultmeplease
nextcloud_admin_user_vault: admin
nextcloud_admin_password_vault: vaultmeplease
```

And your group vars in `group_vars/nextcloud.yml`:
```
# Nextcloud
nextcloud_domain: "yourdomain.com"
nextcloud_admin_user: "{{ nextcloud_admin_user_vault }}"
nextcloud_admin_password: "{{ nextcloud_admin_password_vault }}"
nextcloud_instanceid: "{{ nextcloud_instanceid_vault }}"
nextcloud_passwordsalt: "{{ nextcloud_passwordsalt_vault }}"
nextcloud_secret: "{{ nextcloud_secret_vault }}"
nextcloud_dbpassword: "{{ nextcloud_dbpassword_vault }}"
nextcloud_apps: [calendar]

# MySQL
mysql_root_password: "{{ mysql_root_password_vault }}"
mysql_bind_address: 127.0.0.1
mysql_packages:
  - mariadb-client
  - mariadb-server
  - python-mysqldb
mysql_databases:
  - name: nextcloud
    encoding: utf8mb4
    collation: utf8mb4_general_ci
mysql_users:
  - name: nextcloud
    host: "localhost"
    password: "{{ nextcloud_dbpassword }}"
    priv: "nextcloud.*:ALL"
    state: present

# Nginx
nginx_remove_default_vhost: true
nginx_service_enabled: true
nginx_service_state: started
nginx_listen_ipv6: false
nginx_vhosts:
  - listen: {{ hostvars[inventory_hostname]['ansible_default_ipv4']['address'] }}:443 ssl http2 default_server
    server_name: "{{ nextcloud_domain }}"
    state: "present"
    root: "/var/www/{{ nextcloud_domain }}/current/nextcloud"
    index: index.php
    extra_parameters: |
      add_header Referrer-Policy "no-referrer" always;
      add_header X-Content-Type-Options "nosniff" always;
      add_header X-Download-Options "noopen" always;
      add_header X-Frame-Options "SAMEORIGIN" always;
      add_header X-Permitted-Cross-Domain-Policies "none" always;
      add_header X-Robots-Tag "none" always;
      add_header X-XSS-Protection "1; mode=block" always;

      ssl_certificate /root/.acme.sh/{{ nextcloud_domain }}/fullchain.cer;
      ssl_certificate_key /root/.acme.sh/{{ nextcloud_domain }}/{{ nextcloud_domain }}.key;
      include /etc/nginx/generic.conf;
      include /etc/nginx/gzip.conf;
      include /etc/nginx/security.conf;
      include /etc/nginx/ssl.conf;

      location = /.well-known/carddav {
        return 301 $scheme://$host/remote.php/dav;
      }

      location = /.well-known/caldav {
        return 301 $scheme://$host/remote.php/dav;
      }

      client_max_body_size 512M;
      fastcgi_buffers 64 4K;

      location / {
        rewrite ^ /index.php;
      }

      location ~ ^\/(?:build|tests|config|lib|3rdparty|templates|data)\/ {
          deny all;
      }
      location ~ ^\/(?:\.|autotest|occ|issue|indie|db_|console) {
          deny all;
      }

      location ~ ^\/(?:index|remote|public|cron|core\/ajax\/update|status|ocs\/v[12]|updater\/.+|oc[ms]-provider\/.+)\.php(?:$|\/) {
        fastcgi_split_path_info ^(.+?\.php)(\/.*|)$;
        set $path_info $fastcgi_path_info;
        try_files $fastcgi_script_name =404;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $path_info;
        fastcgi_param HTTPS on;
        fastcgi_param modHeadersAvailable true;
        fastcgi_param front_controller_active true;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_intercept_errors on;
        fastcgi_request_buffering off;
      }

      location ~ ^\/(?:updater|oc[ms]-provider)(?:$|\/) {
        try_files $uri/ =404;
        index index.php;
      }

      location ~ \.(?:css|js|woff2?|svg|gif|map)$ {
        try_files $uri /index.php$request_uri;
        add_header Cache-Control "public, max-age=15778463";
        add_header Referrer-Policy "no-referrer" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Download-Options "noopen" always;
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Permitted-Cross-Domain-Policies "none" always;
        add_header X-Robots-Tag "none" always;
        add_header X-XSS-Protection "1; mode=block" always;
        access_log off;
      }

      location ~ \.(?:png|html|ttf|ico|jpg|jpeg|bcmap)$ {
        try_files $uri /index.php$request_uri;
        access_log off;
      }

# PHP
php_default_version_debian: "8.0"
php_packages:
  - php8.0-cli
  - php8.0-fpm
php_install_recommends: false
php_enable_webserver: false
php_enable_php_fpm: true
php_enable_apc: false
php_memory_limit: "512M"
php_upload_max_filesize: "512M"
php_post_max_size: "512M"
php_date_timezone: "Europe/Paris"
php_opcache_zend_extension: "opcache.so"
php_opcache_enable: "1"
php_opcache_enable_cli: "0"
php_opcache_memory_consumption: "128"
php_opcache_interned_strings_buffer: "16"
php_opcache_max_accelerated_files: "10000"
php_opcache_max_wasted_percentage: "5"
php_opcache_validate_timestamps: "0"
php_opcache_revalidate_path: "0"
php_opcache_revalidate_freq: "1"
php_opcache_max_file_size: "0"
```

### Developer documentation

[dev documentation](https://github.com/nierdz/ansible-role-nextcloud/blob/master/docs/development.md)

## License

[GPLv3](LICENCE)
