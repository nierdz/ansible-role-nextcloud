[![CI Status](https://github.com/nierdz/ansible-role-netxcloud/workflows/CI/badge.svg?branch=master)](https://github.com/nierdz/ansible-role-nextcloud/actions?query=workflow%3ACI)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

Nextcloud
=========

This **ansible** role install [nextcloud](https://nextcloud.com/) the capistrano way. This means, the folder structure look likes this:

```
├── data
│   ├── appdata_xxxxxxxxxxx
│   │   ├── appstore
│   │   ├── avatar
│   │   ├── css
│   │   ├── dashboard
│   │   ├── dav-photocache
│   │   ├── identityproof
│   │   ├── js
│   │   ├── preview
│   │   ├── text
│   │   └── theming
│   ├── files_external
│   │   └── rootcerts.crt
│   ├── __groupfolders
│   ├── index.html
│   ├── nextcloud.log
│   └── user
│       ├── cache
│       ├── files
│       ├── files_trashbin
│       ├── files_versions
│       └── uploads
└── nextcloud.example.com
    ├── current -> /var/www/nextcloud.example.com/releases/20.0.4
    ├── releases
    │   ├── 20.0.2
    │   ├── 20.0.3
    │   └── 20.0.4
    └── shared
        └── config
```

Requirements
------------

**Nextcloud** needs **PHP**, a **web server** and a **DBMS** to work. To fulfill these requirements here is some roles you can use:

 - [geerlingguy/mysql](https://galaxy.ansible.com/geerlingguy/mysql)
 - [geerlingguy/php](https://galaxy.ansible.com/geerlingguy/php)
 - [geerlingguy/nginx](https://galaxy.ansible.com/geerlingguy/nginx)

In production, you will also need a TLS certificate which can be obtained using [certbot](https://certbot.eff.org/) and this role [geerlingguy/nginx](https://galaxy.ansible.com/geerlingguy/certbot). This part is covered in example playbook.

Role Variables
--------------

TODO

Example Playbook
----------------

Here is a fully functional playbook to install **certbot**, **mysql**, **php**, **nginx** and **nextcloud**:

```yaml
---
- name: Configure nextcloud server
  become: true
  hosts: nextcloud
  roles:
    - { role: certbot, tags: ['certbot'] }
    - { role: nginx,
        tags: ['nginx'],
        nginx_default_vhost_path: '/etc/nginx/conf.d/default.conf',
        nginx_vhost_path: '/etc/nginx/conf.d'
    }
    - { role: mysql, tags: ['mysql'] }
    - { role: php, tags: ['php'] }
    - { role: nextcloud, tags: ['nextcloud'] }
  pre_tasks:
    - name: Install sury key
      apt_key:
        url: "https://packages.sury.org/php/apt.gpg"
        state: present
    - name: Add sury repositories
      apt_repository:
        repo: "deb https://packages.sury.org/php/ {{ ansible_distribution_release }} main"
        state: present
        update_cache: yes
        filename: sury
    - name: Install nginx apt key
      apt_key:
        url: "https://nginx.org/keys/nginx_signing.key"
        state: present
    - name: Add nginx Repository
      apt_repository:
        repo: "deb http://nginx.org/packages/mainline/debian {{ ansible_distribution_release }} nginx"
        state: present
        update_cache: true
        filename: nginx
```

License
-------

[GPLv3](LICENCE)
