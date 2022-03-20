# Underworld - The DakEnviy's gentoo overlay

## Installation

### Using eselect repository - preferred method

To use this method, make sure you've emerged `app-eselect/eselect-repository` before.

To add the repo, just run:

```
# eselect repository enable underworld
```

Then run `emaint sync -r underworld` or `emerge --sync` to sync it.

### Using layman (app-portage/layman)

Add the repo and sync it using layman:

```
# layman -a underworld
# layman -s underworld
```

### Using local overlay

Create a `/etc/portage/repos.conf/underworld.conf` file containing

```
[underworld]
location = /var/db/repos/underworld
sync-type = git
sync-uri = https://github.com/DakEnviy/underworld-overlay.git
```

Then run `emerge --sync`

## Details

- sys-auth/libfprint - has drivers for new goodix devices (more: https://github.com/Infinytum/libfprint/tree/unstable)

