# Documentation to help developers

## Requirements

You need to install:
- [direnv](https://github.com/direnv/direnv)
- [make](https://github.com/mirror/make)
- [mkcert](https://github.com/FiloSottile/mkcert)
- [podman](https://github.com/containers/podman)
- [pip](https://github.com/pypa/pip)

## Getting started

First, clone the repository `git clone git@github.com:nierdz/ansible-role-nextcloud.git` and go inside `cd ansible-role-nextcloud`.

As this is the first time `direnv` meets this new [.envrc](../.envrc) file you'll need to allow it to source it by typing `direnv allow`.

Run `make install` this will create a python virtual environment and install everything needed inside it. With the help of `direnv` every time you go in this repository, the virtual environment is automatically loaded.

Run `make mkcert` to create self signed certificates trusted by your browser.

Edit your `/etc/hosts` to add `127.0.0.1	nextcloud.local`.

You can then run `molecule converge` and once it's done, browse https://nextcloud.local:4343
