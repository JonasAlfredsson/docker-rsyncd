# docker-rsync

A Docker image with the [rsync][1] binary running in daemon/server mode in order
to allow for clients to push/pull data to it.

Running it as `root` inside a container allows us to keep the powerful archival
features (like keeping permissions and owner) while limiting its access to the
host's file system by only mounting the paths necessary. These mounts could
also be set to read only if no files are every to be written to the share.


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






[1]: https://linux.die.net/man/1/rsync
[2]: https://www.man7.org/linux/man-pages/man5/rsyncd.conf.5.html#CONFIG_DIRECTIVES
[3]: https://stackoverflow.com/a/64937200
