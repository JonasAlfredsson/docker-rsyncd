# docker-rsyncd

A Docker image with the [rsync][1] binary running in daemon/server mode in order
to allow for clients to push/pull data to it.

Running it as `root` inside a container allows us to keep the powerful archival
features (like keeping permissions and owner) while limiting its access to the
host's file system by only mounting the paths necessary. These mounts could
also be set to read only if no files are every to be written to the share.

> This container is primarily used by [this Ansible role][5].

## Usage

The service reads the default config file located at `/etc/rsyncd.conf`, which
in turn reads any additional `*.inc` an `*.conf` files found in the
`/etc/rsyncd.d/` folder. By host mounting your custom configs into this
directory they will be automatically included.

However, please read up on the difference between how
[`*.inc` an `*.conf` files][2] are handled, or look into the
[examples directory](./examples/) and the [`rsyncd.conf`](./rsyncd.conf) file,
to get a better understanding on what will happen.

The image may then be tested/started like this:

```
docker run -it --network=host \
	-v $(PWD)/examples:/etc/rsyncd.d:ro \
	jonasal/rsync:latest
```

> I recommend using `--network=host` to get some nicer printouts in the logs,
> but it is up to you if you prefer to port forward instead (port `873`).


## Good to Know

### Logging
Since the service is running inside a container its output goes straight to
`stdout` to then be caught by Docker. By default this container set the `-v`
flag and `--log-file-format='%o %h [%a] %m (%u) %f %l'` as `CMD` arguments.
This is very easy to override by providing your own CMD which will replace
what is set in the [Dockerfile](./Dockerfile).

### Using chroot
Since this image defaults to `use chroot = yes` it might be necessary to
provide the `--cap-add=SYS_CHROOT` [flag][3] if you run into any weird error
messages. I did not need to, but this is here just in case.

### Authorizing Users
Through the use of the `secrets file` it is possible to create username+password
combinations that may be used to enable authentication to the shares. The
username and password defined here has nothing to do with the username or
password of the user on the system (they don't even need to exist as a user on
the system). Instead the `user` and `group` values the files/transfers will get
is defined by the `uid` and `gid` options in the configuration. This means that
it is possible to "impersonate" other system users if configured wrongly.

While this allows us to force any connecting user to use the extremely
restricted `nobody/nogroup` user (to protect us from unwanted access to
sensitive files) it also means that all files will be created by the same
user. This might not always be desired behavior so an option is to use the
[RSYNC_USER_NAME][4] environment variable like this:

```conf
uid = %RSYNC_USER_NAME%
gid = *
```

This will make so that the rsync user, with username "jonas", gets assigned the
system `uid` of "jonas". However, in contrast to the case when the `uid/gid`
is statically assigned this share now only allows users which exists on the
system, else it will fail with `@ERROR: invalid uid`.

Furthermore, for this to work as intended the `/etc/passwd` file needs to be
readable from within the container, else it will not be possible for rsync to
look up the IDs of the usernames. This can be solved by adding the following
mounts to the Docker run command:

```
docker run -it --rm
    -v '/etc/passwd:/etc/passwd:ro' \
    -v '/etc/group:/etc/group:ro' \
    jonasal/rsyncd:local
```





[1]: https://linux.die.net/man/1/rsync
[2]: https://www.man7.org/linux/man-pages/man5/rsyncd.conf.5.html#CONFIG_DIRECTIVES
[3]: https://stackoverflow.com/a/64937200
[4]: https://download.samba.org/pub/rsync/rsyncd.conf.html#uid
[5]: https://github.com/JonasAlfredsson/ansible-role-rsync_server
