# Underworld - the DakEnviy's gentoo overlay

## Installation

### Using eselect repository - preferred method

To use this method, make sure you've emerged `app-eselect/eselect-repository` before.

To add the repo, just run:

```
# eselect repository add underworld git https://github.com/DakEnviy/underworld-overlay.git
```

Then run `emaint sync -r underworld` to sync it.

### Using layman (app-portage/layman)

Add the repo using layman:

```
# layman -o https://raw.githubusercontent.com/DakEnviy/underworld-overlay/master/repositories.xml -f -a underworld
```

Then run `layman -s underworld`

### Using local overlay

Create a `/etc/portage/repos.conf/underworld.conf` file containing

```
[underworld]
location = /var/db/repos/underworld
sync-type = git
sync-uri = https://github.com/DakEnviy/underworld-overlay.git
```

Then run `emerge --sync`

